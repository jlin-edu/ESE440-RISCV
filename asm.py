# Simple assembler for the Dire-WolVes RISC-V Processor
# TODO: Labels and jump address calculation
# TODO: pseudo instructions
################ INSTRUCTIONS SYNTAX #######################
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
#   -o : CHOOSE OUTPUT FILE NAME, DEFAULT IS rsc_out.txt
#

import sys
from enum import Enum
from collections import deque

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

TokenType = Enum("TokenType", ["MNEMONIC", "REG", "IMM"])

class Token:
    
    def __init__(self, value, token_type):
        self.value = value
        self.type = token_type
        
    def __str__(self):
        return f"Token - Value: {self.value}, Type: {self.type}"
        
    def __repr__(self):
        return f"Token - Value: {self.value}, Type: {self.type}"    
        
###############################################################
#
#                         DICTIONARIES
#   
#     DICTIONARIES TO STORE REGISTER BINARY AND INSTRUCTION
#     FORMAT.
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
    "SLTIU"     : [OP_IMM,   "011", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None]],
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

###############################################################
#
#                  PARSE INSTRUCTIONS IN FILE
#
#  INPUT: FILE TO READ
#  OUTPUT: LIST OF LIST OF STRINGS
#  NOTES: THE OUTPUT IS A LIST OF LISTS, WITH EACH INTERNAL
#         LIST HOLDING EACH PART OF A SINGLE INSTRUCTION
#
#  EXAMPLE:
#  NEXT INSTRUCTION READ: ADD x1, x2, x3
#  LIST OF STRINGS REPRESENTATION: ["ADD", "x1", "x2", "x3"]
#
###############################################################

def parse(input_file):
    instruction_list = []
    instruction = input_file.readline()
    while (instruction != ""):
        instruction_split = instruction.split(" ")
        parsed_instruction = []
        for i, component in enumerate(instruction_split):
            parsed_component = component.replace(",", "").replace("\n", "").replace(")", "").split("(")
            parsed_instruction.extend(parsed_component)
        instruction_list.append(parsed_instruction)
        instruction = input_file.readline()
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

def tokenize(instructions_list):
    token_list = []
    for instruction in instructions_list:
        tokens = []
        for operand in instruction:
            if (register_dict.get(operand, -1) != -1):
                tokens.append(Token(operand, TokenType.REG))
            elif(instruction_dict.get(operand, -1) != -1):
                tokens.append(Token(operand, TokenType.MNEMONIC))
            elif(operand.isnumeric()):
                tokens.append(Token(int(operand), TokenType.IMM))
            else:
                print("\nERROR: INVALID OPERAND\n")
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
#         DON'T MEET THE INSTRUCTION REQUIREMENTS
#
#  EXAMPLE:
#  NEXT TOKEN LIST: [T(ADD), T(x1), T(x2), T(x3)]
#  OUTPUTS VALID
#
###############################################################
def validate(token_list):
    for tokens in token_list:
        mnemonic = tokens[0]
        if mnemonic.type != TokenType.MNEMONIC:
            print("\nERROR: INVALID MNEMONIC\n") # TODO: HAVE ERROR POINT TO LINE WITH ISSUE
            sys.exit()
            
        inst_format = instruction_dict[mnemonic.value][FORMAT]
        operands = tokens[1:]
        if len(operands) != len(inst_format):
            print("\nERROR: INVALID OPERAND COUNT\n") # TODO: HAVE ERROR POINT TO LINE WITH ISSUE TODO: ERROR HANDLING FUNCTION WITH ERROR CODES
            sys.exit()
            
        for position in zip(operands, inst_format):
            operand, op_format = position
            if operand.type == TokenType.IMM and op_format == TokenType.REG and operand.value < 32:
                operand.type = TokenType.REG
            elif operand.type != op_format:
                print(f"\nERROR: INVALID OPERAND TYPE\nEXPECTED {op_format}, GOT {operand.type}\n")
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
        
        fields = instruction_dict[mnemonic.value]
        opcode = fields[OPCODE]
        funct3 = fields[FUNCT3]
        funct7 = fields[FUNCT7]
        
        immediate = None
        imm_size = immediate_sizes[opcode]
        inst_registers = []
        for token in tokens:
            if token.type == TokenType.IMM:
                immediate = format(token.value, f'0{imm_size}b') # TODO: CHECK IMMEDIATE SIZES AND JUMP CALCULATIONS
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


if __name__ == "__main__":
    
    option = None
    
    if len(sys.argv) <= 1:
        print("\nERROR: NO FILE SPECIFIED\n")
        sys.exit()
        
    in_file_name = sys.argv[1]
    if in_file_name[-4:] != ".rsc":
        print("\nERROR: INVALID INPUT FILE FORMAT\n") # TODO: HANDLE BETTER ERROR REPORTING WITH FILE NAME
        sys.exit()
    
    if len(sys.argv) > 2:
        option = sys.argv[2]
        
        if option != "-o":
            print("\nERROR: INVALID OPTION\n")
            sys.exit()
            
        if len(sys.argv) < 4:
            print("\nERROR: NO OUTPUT FILE NAME PROVIDED\n")
            sys.exit()
            
    
    out_file_name = "rsc_out.txt" # TODO: ADD OPTION TO OUTPUT A BINARY FILE -b
    if option != None:
        out_file_name = sys.argv[3]
    
    try:
        with open(in_file_name, "r") as inst_file:
            with open(out_file_name, "w+") as output_file:      
                instructions = parse(inst_file)
                tokens = tokenize(instructions)
                validate(tokens)
                machine_code = translate(tokens)
                for code in machine_code:
                    output_file.write(f"{code}\n")
    except FileNotFoundError:
        print(f"\nERROR: FILE {in_file_name} DOES NOT EXIST\n")
        sys.exit()


