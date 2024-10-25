# Simple assembler for the Dire-WolVes RISC-V Processor
# TODO: Labels and jump address calculation
################ INSTRUCTIONS SYNTAX #######################
#
# MNEMONICS ARE NOT CASE SENSITVE
# REGISTER x1 IS USED FOR RETURN ADDRESSES IN THE JR AND RET INSTRUCTIONS
#
# PHYSICAL INSTRUCTIONS:
# LUI rd, imm
# AUIPC rd, offset
# JAL rd, offset
# JALR rd, rs1, offset
# BEQ rs1, rs2, offset
# BNE rs1, rs2, offset
# BLT rs1, rs2, offset
# BGE rs1, rs2, offset
# BLTU rs1, rs2, offset
# BGEU rs1, rs2, offset
# LB rd, rs1(offset)
# LH rd, rs1(offset)
# LW rd, rs1(offset)
# LBU rd, rs1(offset)
# LHU rd, rs1(offset)
# SB rs2, rs1(offset)
# SH rs2, rs1(offset)
# SW rs2, rs1(offset)
# ADDI rd, rs1, imm
# SLTI rd, rs1, imm
# SLTUI rd, rs1, imm
# XORI rd, rs1, imm
# ORI rd, rs1, imm
# ANDI rd, rs1, imm
# SLLI rd, rs1, imm
# SRLI rd, rs1, imm
# SRAI rd, rs1, imm
# ADD rd, rs1, rs2
# SUB rd, rs1, rs2
# SLL rd, rs1, rs2
# SLT rd, rs1, rs2
# SLTU rd, rs1, rs2
# XOR rd, rs1, rs2
# SRL rd, rs1, rs2
# SRA rd, rs1, rs2
# OR rd, rs1, rs2
# AND rd, rs1, rs2
# MUL rd, rs1, rs2
# MULH rd, rs1, rs2
# MULHSU rd, rs1, rs2
# MULHU rd, rs1, rs2
# DIV rd, rs1, rs2
# DIVU rd, rs1, rs2
# REM rd, rs1, rs2
# REMU rd, rs1, rs2
#
# pseudo INSTRUCTIONS
# NOP
#
############################################################
#               ASSEMBLER PROCEDURE                        #
############################################################
#                                                          #
#           PARSE -> TOKENIZE -> TRANSLATE                 #
#                                                          #
############################################################
#
# TO RUN ASSEMBLER: python asm.py FILE_NAME_HERE.rsc
#
# OPTIONS:
#   -o : CHOOSE OUTPUT FILE NAME, DEFAULT IS rsc_out
#   -b : OUTPUT FILE AS BINARY, DEFAULT IS PLAIN TEXT
#

import sys
from enum import Enum

###############################################################
#
#                   CONSTANT DEFINITIONS
#
###############################################################

OP_IMM   = "0010011"
OP_R3    = "0110011"
OP_BR    = "1100011"
OP_LD    = "0000011"
OP_ST    = "0100011"

OP_LUI   = "0110111"
OP_AUIPC = "0010111"

OP_JAL   = "1101111"
OP_JALR  = "1100111"

###############################################################
#
#                         TOKEN CLASS
#   
#       CLASS FOR EACH TOKEN OF AN INSTRUCTION. HAS A VALUE
#       AND TYPE ASSOCIATED WITH IT.
#
###############################################################

TokenType = Enum("TokenType", ["MNEMONIC", "REG", "IMM", "NULL"])

class Token:
    
    def __init__(self, value = None, token_type = TokenType.NULL, line_number = -1):
        self.value = value
        self.type = token_type
        self.line = line_number
        
    def __str__(self):
        return f"Token - Value: {self.value}, Type: {self.type}"
        
    def __repr__(self):
        return f"Token - Value: {self.value}, Type: {self.type}"    
        
###############################################################
#
#                         DICTIONARIES
#   
#     DICTIONARIES TO STORE REGISTER BINARY, INSTRUCTION
#     FORMAT, AND PSEUDO INSTRUCTIONS.
#
###############################################################

register_dict = {
    "zero"  : "00000", "x0"    : "00000", "x1"    : "00001", "x2"    : "00010", "x3"    : "00011",
    "x4"    : "00100", "x5"    : "00101", "x6"    : "00110", "x7"    : "00111", "x8"    : "01000",
    "x9"    : "01001", "x10"   : "01010", "x11"   : "01011", "x12"   : "01100", "x13"   : "01101",
    "x14"   : "01110", "x15"   : "01111", "x16"   : "10000", "x17"   : "10001", "x18"   : "10010",
    "x19"   : "10011", "x20"   : "10100", "x21"   : "10101", "x22"   : "10110", "x23"   : "10111",
    "x24"   : "11000", "x25"   : "11001", "x26"   : "11010", "x27"   : "11011", "x28"   : "11100",
    "x29"   : "11101", "x30"   : "11110", "x31"   : "11111"
}

immediate_sizes = {
    OP_IMM   : 12,
    OP_R3    : 0,
    OP_BR    : 13,
    OP_LD    : 12,
    OP_ST    : 12,
    OP_LUI   : 20,
    OP_AUIPC : 20,
    OP_JAL   : 21,
    OP_JALR  : 12,
}

OPCODE = 0
FUNCT3 = 1
FUNCT7 = 2
FORMAT = 3
POS    = 4

RD  = 0
RS1 = 1
RS2 = 2

# FORMAT: [ OPCODE, FUCT3, FUCT7, [FORMAT], [REG POSITIONS] ] (IF APPLICABLE)     [REG POSITIONS] = [RD, RS1, RS2]
instruction_dict = {
    "LUI"       : [OP_LUI,   None,  None,      [TokenType.REG, TokenType.IMM],                [0, None, None]],
    "AUIPC"     : [OP_AUIPC, None,  None,      [TokenType.REG, TokenType.IMM],                [0, None, None]],
    "JAL"       : [OP_JAL,   None,  None,      [TokenType.REG, TokenType.IMM],                [0, None, None]],
    "JALR"      : [OP_JALR,  "000", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None]],
    "BEQ"       : [OP_BR,    "000", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [None, 0, 1]],
    "BNE"       : [OP_BR,    "001", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [None, 0, 1]],
    "BLT"       : [OP_BR,    "100", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [None, 0, 1]],
    "BGE"       : [OP_BR,    "101", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [None, 0, 1]],
    "BLTU"      : [OP_BR,    "110", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [None, 0, 1]],
    "BGEU"      : [OP_BR,    "111", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [None, 0, 1]],
    "LB"        : [OP_LD,    "000", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None]],
    "LH"        : [OP_LD,    "001", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None]],
    "LW"        : [OP_LD,    "010", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None]],
    "LBU"       : [OP_LD,    "100", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None]],
    "LHU"       : [OP_LD,    "101", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None]],
    "SB"        : [OP_ST,    "000", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [None, 1, 0]],
    "SH"        : [OP_ST,    "001", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [None, 1, 0]],
    "SW"        : [OP_ST,    "010", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [None, 1, 0]],
    "ADDI"      : [OP_IMM,   "000", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None]],
    "SLTI"      : [OP_IMM,   "010", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None]],
    "SLTUI"     : [OP_IMM,   "011", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None]],
    "XORI"      : [OP_IMM,   "100", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None]],
    "ORI"       : [OP_IMM,   "110", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None]],
    "ANDI"      : [OP_IMM,   "111", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None]],
    "SLLI"      : [OP_IMM,   "001", "0000000", [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None]],
    "SRLI"      : [OP_IMM,   "101", "0000000", [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None]],
    "SRAI"      : [OP_IMM,   "101", "0100000", [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None]],
    "ADD"       : [OP_R3,    "000", "0000000", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2]],
    "SUB"       : [OP_R3,    "000", "0100000", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2]],
    "SLL"       : [OP_R3,    "001", "0000000", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2]],
    "SLT"       : [OP_R3,    "010", "0000000", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2]],
    "SLTU"      : [OP_R3,    "011", "0000000", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2]],
    "XOR"       : [OP_R3,    "100", "0000000", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2]],
    "SRL"       : [OP_R3,    "101", "0000000", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2]],
    "SRA"       : [OP_R3,    "101", "0100000", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2]],
    "OR"        : [OP_R3,    "110", "0000000", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2]],
    "AND"       : [OP_R3,    "111", "0000000", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2]],
    "MUL"       : [OP_R3,    "000", "0000001", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2]],
    "MULH"      : [OP_R3,    "001", "0000001", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2]],
    "MULHSU"    : [OP_R3,    "010", "0000001", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2]],
    "MULHU"     : [OP_R3,    "011", "0000001", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2]],
    "DIV"       : [OP_R3,    "100", "0000001", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2]],
    "DIVU"      : [OP_R3,    "101", "0000001", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2]],
    "REM"       : [OP_R3,    "110", "0000001", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2]],
    "REMU"      : [OP_R3,    "111", "0000001", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2]]
}



PFORMAT = 0
PMAP = 1
PTRANSLATE = 2

# FORMAT: [[PFORMAT], [MAPPING], [TRANSLATION], [FORMAT]]        MAPPING = FOLLOWS INDICES OF TRANSLATION, CONTAINS INDICES OF PFORMAT (START AT 1 SINCE MNEMONIC IGNORED)
pseudo_instruction_dict = {
    "NOP" : [[None], [None], ["ADDI", "zero", "zero", "0"], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM]],
    "LI" : [],
    "LA" : [],
    "MV" : [[TokenType.REG, TokenType.REG], [1, 2], ["ADDI", TokenType.REG, TokenType.REG, 0], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM]], # TODO: REFACTOR FORMAT LISTS TO REFERENCE A STANDARD SET AND THE DICT OF NORMAL INSTS
    "NOT" : [[TokenType.REG, TokenType.REG], [1, 2], ["XORI", TokenType.REG, TokenType.REG, -1], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM]],
    "NEG" : [[TokenType.REG, TokenType.REG], [1, 2], ["SUB", TokenType.REG, "x0", TokenType.REG], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.REG]],
    "SEQZ" : [[TokenType.REG, TokenType.REG], [1, 2], ["SLTIU", TokenType.REG, TokenType.REG, 1], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM]],
    "SNEZ" : [[TokenType.REG, TokenType.REG], [1, 2], ["SLTU", TokenType.REG, "x0", TokenType.REG], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.REG]],
    "SLTZ" : [[TokenType.REG, TokenType.REG], [1, 2], ["SLT", TokenType.REG, TokenType.REG, "x0"], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.REG]],
    "SGTZ" : [[TokenType.REG, TokenType.REG], [1, 2], ["SLT", TokenType.REG, "x0", TokenType.REG], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.REG]],
    "BEQZ" : [[TokenType.REG, TokenType.IMM], [1, 2], ["BEQ", TokenType.REG, "x0", TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM]],
    "BNEZ" : [[TokenType.REG, TokenType.IMM], [1, 2], ["BNE", TokenType.REG, "x0", TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM]],
    "BLEZ" : [[TokenType.REG, TokenType.IMM], [1, 2], ["BGE", "x0", TokenType.REG, TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM]],
    "BGEZ" : [[TokenType.REG, TokenType.IMM], [1, 2], ["BGE", TokenType.REG, "x0", TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM]],
    "BLTZ" : [[TokenType.REG, TokenType.IMM], [1, 2], ["BLT", TokenType.REG, "x0", TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM]],
    "BGTZ" : [[TokenType.REG, TokenType.IMM], [1, 2], ["BLT", "x0", TokenType.REG, TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM]],
    "BGT" : [[TokenType.REG, TokenType.REG, TokenType.IMM], [2, 1, 3], ["BLT", TokenType.REG, TokenType.REG, TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM]],
    "BLE" : [[TokenType.REG, TokenType.REG, TokenType.IMM], [2, 1, 3], ["BGE", TokenType.REG, TokenType.REG, TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM]],
    "BGTU" : [[TokenType.REG, TokenType.REG, TokenType.IMM], [2, 1, 3], ["BLTU", TokenType.REG, TokenType.REG, TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM]],
    "BLEU" : [[TokenType.REG, TokenType.REG, TokenType.IMM], [2, 1, 3], ["BLTU", TokenType.REG, TokenType.REG, TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM]],
    "J" : [[TokenType.IMM], [1], ["JAL", "x0", TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.IMM]],
    "JR" : [[TokenType.IMM], [1], ["JAL", "x1", TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.IMM]],
    "RET" : [[None], [None], ["JALR", "x0", "x1", "0"], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM]]
}

###############################################################
#
#                  PARSE INSTRUCTIONS IN FILE
#
#  INPUT: FILE TO READ
#  OUTPUT: LIST OF LIST OF STRINGS
#  NOTES: THE OUTPUT IS A LIST OF LISTS, WITH EACH INTERNAL
#         LIST HOLDING EACH PART OF A SINGLE INSTRUCTION
#         ALSO PARSES PSEUDO INSTRUCTIONS, REPLACING WITH
#         INSTRUCTION EQUIVALENT
#
#  EXAMPLE:
#  NEXT INSTRUCTION READ: ADD x1, x2, x3
#  LIST OF STRINGS REPRESENTATION: ["ADD", "x1", "x2", "x3"]
#
###############################################################

def parse(instruction_lines):
    instruction_list = []
    for i in range(len(instruction_lines)):
        instruction = instruction_lines[i]
        instruction_split = instruction.split(" ")
        parsed_instruction = []
        for component in instruction_split:
            parsed_component = component.replace(",", "").replace("\n", "").replace(")", "").split("(")
            parsed_instruction.extend(parsed_component)
        instruction_list.append(parsed_instruction)
    return instruction_list

###############################################################
#
#          TOKENIZE INSTRUCTIONS FROM LIST OF LISTS
#
#  INPUT: LIST OF LIST OF STRINGS
#  OUTPUT: TOKEN LIST
#  NOTES: THE OUTPUT IS A LIST OF TOKENS
#
#  EXAMPLE:
#  NEXT INSTRUCTION LIST: ["ADD", "x1", "x2", "x3"]
#  TOKEN LIST: [T(ADD), T(x1), T(x2), T(x3)]
#
###############################################################

def tokenize(instructions_list, instruction_lines):
    token_list = []
    for idx, instruction in enumerate(instructions_list):
        tokens = []
        if instruction[0] == "": continue
        for operand in instruction:
            if (register_dict.get(operand) != None):
                tokens.append(Token(operand, TokenType.REG, idx))
            elif(instruction_dict.get(operand.upper()) != None or pseudo_instruction_dict.get(operand.upper()) != None):
                tokens.append(Token(operand.upper(), TokenType.MNEMONIC, idx))
            elif(operand.isnumeric()):
                tokens.append(Token(int(operand), TokenType.IMM, idx))
            else:
                instruction_line = instruction_lines[idx]
                op_type = "MNEMONIC" if instruction.index(operand) == 0 else "OPERAND"
                pos = 27 + len(f"{idx}") + instruction_line.find(operand) + len(op_type)
                print(f"\nERROR: INVALID {op_type} - line {idx}: {instruction_line}")
                print("^\n".rjust(pos))
                sys.exit()
            # INVALID TODO: POTENTIALLY ADD LABELS FOR JUMPS
        token_list.append(tokens)
    return token_list

###############################################################
#
#          VALIDATE TOKENS OF EACH INSTRUCTION
#
#  INPUT: LIST OF LIST OF TOKENS
#  OUTPUT: NONE
#  NOTES: HAS NO OUTPUT, BUT RAISES ERRORS WHEN TOKENS
#         DON'T MEET THE INSTRUCTION REQUIREMENTS. ALSO
#         VERIFIES pseudo INSTRUCTION SYNTAX.
#
#  EXAMPLE:
#  NEXT TOKEN LIST: [T(ADD), T(x1), T(x2), T(x3)]
#  OUTPUT: NOTHING
#
###############################################################
def validate(token_list, instruction_lines):
    for tokens in token_list:
        idx = tokens[0].line
        instruction_line = instruction_lines[idx].replace("\n", "")
        
        mnemonic = tokens[0]
        mnemonic_name = mnemonic.value
        if (pseudo_instruction_dict.get(mnemonic_name) != None):
            inst_format = pseudo_instruction_dict[mnemonic_name][PFORMAT]
            mnemonic_name = pseudo_instruction_dict[mnemonic_name][PTRANSLATE][0]
        else:
            inst_format = instruction_dict[mnemonic_name][FORMAT]
        opcode = instruction_dict[mnemonic_name][OPCODE]
        
        operands = tokens[1:]
        if (inst_format[0] != None):
            if len(operands) != len(inst_format):
                pos = 40 + len(f"{idx}") + len(instruction_line)
                print(f"\nERROR: INVALID OPERAND COUNT - line {idx}: {instruction_line}")
                print("^\n".rjust(pos))
                sys.exit()
                
            for operand, op_format in zip(operands, inst_format):
                if operand.type == TokenType.IMM and op_format == TokenType.REG and operand.value < 32:
                    operand.type = TokenType.REG
                elif operand.type == TokenType.IMM and op_format == TokenType.IMM:
                    imm_size = immediate_sizes[opcode]
                    max_imm = 2**imm_size - 1
                    if operand.value > max_imm:
                        pos = 40 + len(f"{idx}") + instruction_line.find(f"{operand.value}")
                        print(f"\nERROR: INVALID IMMEDIATE SIZE - line {idx}: {instruction_line}")
                        print("^".rjust(pos))
                        print(f"MAX IMM SIZE: {max_imm}\n")
                        sys.exit()
                elif operand.type != op_format:
                    pos = 9 + len(f"{idx}") + instruction_line.find(f"{operand.value}")
                    print(f"\nERROR: INVALID OPERAND TYPE - EXPECTED {op_format}, GOT {operand.type}")
                    print(f"line {idx}: {instruction_line}")
                    print("^\n".rjust(pos))
                    sys.exit()
            
###############################################################
#
#          TRANSLATE TOKENS OF EACH INSTRUCTION
#
#  INPUT: LIST OF LIST OF TOKENS
#  OUTPUT: LIST OF BINARY MACHINE CODE OF EACH INSTRUCTION
#
#  EXAMPLE:
#  NEXT TOKEN LIST: [T(ADD), T(x1), T(x2), T(x3)]
#  OUTPUT: 00000000001100010000000010110011
#
###############################################################
def translate(token_list):
    machine_code = []
    for tokens in token_list:
        mnemonic = tokens[0]
        
        if pseudo_instruction_dict.get(mnemonic.value) != None:
            pseudo_instruction = pseudo_instruction_dict[mnemonic.value]
            pseudo_translation = pseudo_instruction[PTRANSLATE]
            pseudo_format = pseudo_instruction[FORMAT]
            pseudo_mapping = pseudo_instruction[PMAP]
            pseudo_tokens = [Token() for i in range(len(pseudo_format))]

            idx = 0;
            for i in range(len(pseudo_format)):
                if isinstance(pseudo_translation[i], str) or isinstance(pseudo_translation[i], int):
                    pseudo_tokens[i].value = pseudo_translation[i]
                    pseudo_tokens[i].type = pseudo_format[i]
                    pseudo_tokens[i].line = mnemonic.line
                else:
                    pseudo_tokens[i] = (tokens[pseudo_mapping[idx]])
                    idx = idx + 1;
            tokens = pseudo_tokens
            mnemonic = pseudo_tokens[0]
        
        fields = instruction_dict[mnemonic.value]
        opcode = fields[OPCODE]
        funct3 = fields[FUNCT3]
        funct7 = fields[FUNCT7]
        
        immediate = None
        imm_size = immediate_sizes[opcode]
        inst_registers = []
        for token in tokens:
            if token.type == TokenType.IMM:
                imm_val = token.value if token.value > 0 else 2**imm_size + token.value
                immediate = format(imm_val, f'0{imm_size}b') # TODO: CHECK IMMEDIATE SIZES AND JUMP CALCULATIONS
            elif token.type == TokenType.REG:
                inst_registers.append(token.value)
        
        for i in range(len(inst_registers)):
            register = inst_registers[i]
            if isinstance(register, str):
                inst_registers[i] = register_dict[register]
            else:
                inst_registers[i] = list(register_dict.values())[register + 1]
            
        registers = [None for i in range(3)]
        reg_positions = fields[POS]
        for idx, register in enumerate(inst_registers):
            registers[reg_positions.index(idx)] = register
        reg_dest = registers[RD]
        reg_src_1 = registers[RS1]
        reg_src_2 = registers[RS2]
        
        inst_code = ""
        if opcode == OP_IMM or opcode == OP_LD or opcode == OP_JALR:
            if mnemonic in ["SLLI", "SRLI", "SRAI"]:
                inst_code += funct7 + immediate[7:] + reg_src_1 + funct3 + reg_dest + opcode
            else:
                inst_code += immediate + reg_src_1 + funct3 + reg_dest + opcode
        elif opcode == OP_R3:
            inst_code += funct7 + reg_src_2 + reg_src_1 + funct3 + reg_dest + opcode
        elif opcode == OP_BR:
            inst_code += immediate[0] + immediate[2:8] + reg_src_2 + reg_src_1 + funct3 + immediate[8:12] + immediate[1] + opcode
        elif opcode == OP_ST:
            inst_code += immediate[:7] + reg_src_2 + reg_src_1 + funct3 + immediate[7:] + opcode    
        elif opcode == OP_LUI or opcode == OP_AUIPC:
            inst_code += immediate + reg_dest + opcode
        elif opcode == OP_JAL:
            inst_code += immediate[0] + immediate[10:20] + immediate[9] + immediate[1:9] + reg_dest + opcode
        machine_code.append(inst_code) 
    return machine_code

# AVAILABLE OPTIONS FOR THE ASSEMBLER
options = ["-o", "-b"]

if __name__ == "__main__":
    
    if len(sys.argv) <= 1:
        print("\nERROR: NO FILE SPECIFIED\n")
        sys.exit()
        
    in_file_name = sys.argv[1]
    in_extension = in_file_name[in_file_name.find("."):]
    if in_extension != ".rsc":
        print(f"\nERROR: INVALID INPUT FILE FORMAT, EXPECTED A .rsc FILE. GOT A {in_extension} FILE\n")
        sys.exit()
    
    out_file_name = "rsc_out"
    out_extension = ".txt"
    out_mode = "w+"
    if len(sys.argv) > 2:
        idx = 2
        while idx < len(sys.argv):
            option = sys.argv[idx]
            if not option in options:
                pos = 32 + sum(len(arg) for arg in sys.argv[:idx + 1]) + len(sys.argv) - 1
                print(f"\nERROR: INVALID OPTION - python {' '.join(sys.argv)}")
                print("^\n".rjust(pos))
                sys.exit()
                
            if option == "-o":
                idx = idx + 1
                if idx == len(sys.argv):
                    print("\nERROR: NO OUTPUT FILE NAME PROVIDED\n")
                    sys.exit()
                    
                out_file_name = sys.argv[idx]
                if not out_file_name[0].isalpha():
                    pos = 32 + sum(len(arg) for arg in sys.argv[:idx + 1]) + len(sys.argv) - 1
                    print(f"\nERROR: INVALID FILE NAME - python {' '.join(sys.argv)}")
                    print("^\n".rjust(pos))
                    sys.exit()
            
            elif option == "-b":
                out_extension = ".bin"
                out_mode = "wb+"
            
            idx = idx + 1
    
    if out_file_name[out_file_name.find("."):] == out_extension:
        out_file_name = out_file_name[:out_file_name.find(".")]
    elif out_file_name.find(".") != -1:
        pos = 47 + sum(len(arg) for arg in sys.argv[:sys.argv.index(out_file_name)]) + len(sys.argv) + out_file_name.find(".")
        print(f"\nERROR: INVALID OUTPUT FILE EXTENSION - python {' '.join(sys.argv)}")
        print("^\n".rjust(pos))
        sys.exit()
    
    try:
        with open(in_file_name, "r") as inst_file:
            with open(out_file_name + out_extension, out_mode) as output_file:  
                file_instructions = inst_file.readlines()    
                instructions = parse(file_instructions)
                tokens = tokenize(instructions, file_instructions)
                validate(tokens, file_instructions)
                machine_code = translate(tokens)
                for code in machine_code:
                    if out_mode == "wb+":
                        code = bytes(int(code[i:i+8], 2) for i in range(0, len(code), 8))
                        output_file.write(code)
                    else:
                        output_file.write(f"{code}\n")
    except FileNotFoundError:
        print(f"\nERROR: FILE {in_file_name} DOES NOT EXIST\n")
        sys.exit()


