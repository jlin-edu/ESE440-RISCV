# Simple assembler for the Dire-WolVes RISC-V Processor
# Author: Alec Merves
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
# PSUEDO INSTRUCTIONS:
# NOP
# LI rd, imm
# LA rd, imm
# MV rd, rs1
# NOT rd, rs1
# NEG rd, rs1
# SEQZ rd, rs1
# SNEZ rd, rs1
# SLTZ rd, rs1
# SGTZ rd, rs1
# BEQZ rs1, imm
# BNEZ rs1, imm
# BLEZ rs1, imm
# BGEZ rs1, imm
# BLTZ rs1, imm
# BGTZ rs1, imm
# BGT rs1, rs2, imm
# BLE rs1, rs2, imm
# BGTU rs1, rs2, imm
# BLEU rs1, rs2, imm
# J imm
# JR imm
# RET
#
############################################################
#               ASSEMBLER PROCEDURE                        #
############################################################
#                                                          #
#     SYMBOL SCAN -> PARSE -> TOKENIZE -> TRANSLATE        #
#                                                          #
############################################################
#
# TO RUN ASSEMBLER: python asm.py FILE_NAME_HERE.rsc
#
# OPTIONS:
#   -o : CHOOSE OUTPUT FILE NAME, DEFAULT IS rsc_out
#   -b : OUTPUT FILE AS BINARY, DEFAULT IS PLAIN TEXT
#
######################################################################################
# 
#                    Future Additions/Changes (Potential)
#
# Create offset token with property of allowing labels
# Have error handling as a seperate function
# Have errors point to whole offender Ex: offender
#                                         ^^^^^^^^
# Refactor to be a class with methods, more OOP
# allow code on same line as label? potential
# Optimize LI and LA to see if the necessary immediate fits in 12 bits 
# Allow not specifying file extension in command
# Add debug code to print itermediate stages?
# Option to specify file length
# Pad rest of memory with NOPs
# Allow register names (a0, sp, etc) 
# Variable names?
# Extra features from https://michaeljclark.github.io/asm.html
# COMMENTS!!!!!!!!!!!!!!!!!!!!!!
# Optimal jump address calculator, such as using auipc and jal etc
# More pseudo instructions (inc, dec, clr, push(?), pop(?))
# Optimal li (use lui or not depending on imm size)
# Macros??
# FIX HOW FILES ARE SPCIFIED (ALLOW SUB DIRECTORIES)
# ALLOW -o without name to specify same file name
# HAVE WAY TO ASSEMBLE MULTIPLE FILES AT ONCE (LISTING, * Operator etc)
# Option to output in hex for debugging
# Output is in the same directory as the input file
# Option to change output directory
#
######################################################################################
#                       
#                              DOCUMENTATION(ISH)
#
# Added support for binary and hex numbers, and negative numbers
#
#
#
######################################################################################

import sys
from enum import Enum
from numpy import binary_repr

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

hex_chars = set("ABCDEFabcdef0123456789")

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
    
    def __init__(self, value = None, token_type = TokenType.NULL):
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
    OP_LUI   : 32,
    OP_AUIPC : 32,
    OP_JAL   : 21,
    OP_JALR  : 12,
    "LOAD"   : 32
}

OPCODE = 0
FUNCT3 = 1
FUNCT7 = 2
FORMAT = 3
POS    = 4
LABEL  = 5

RD  = 0
RS1 = 1
RS2 = 2

# FORMAT: [ OPCODE, FUCT3, FUCT7, [FORMAT], [REG POSITIONS], LABEL ALLOWED ] (IF APPLICABLE)     [REG POSITIONS] = [RD, RS1, RS2]
instruction_dict = {
    "LUI"       : [OP_LUI,   None,  None,      [TokenType.REG, TokenType.IMM],                [0, None, None], False],
    "AUIPC"     : [OP_AUIPC, None,  None,      [TokenType.REG, TokenType.IMM],                [0, None, None], True ],
    "JAL"       : [OP_JAL,   None,  None,      [TokenType.REG, TokenType.IMM],                [0, None, None], True ],
    "JALR"      : [OP_JALR,  "000", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None],    True ],
    "BEQ"       : [OP_BR,    "000", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [None, 0, 1],    True ],
    "BNE"       : [OP_BR,    "001", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [None, 0, 1],    True ],
    "BLT"       : [OP_BR,    "100", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [None, 0, 1],    True ],
    "BGE"       : [OP_BR,    "101", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [None, 0, 1],    True ],
    "BLTU"      : [OP_BR,    "110", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [None, 0, 1],    True ],
    "BGEU"      : [OP_BR,    "111", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [None, 0, 1],    True ],
    "LB"        : [OP_LD,    "000", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None],    False],
    "LH"        : [OP_LD,    "001", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None],    False],
    "LW"        : [OP_LD,    "010", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None],    False],
    "LBU"       : [OP_LD,    "100", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None],    False],
    "LHU"       : [OP_LD,    "101", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None],    False],
    "SB"        : [OP_ST,    "000", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [None, 1, 0],    False],
    "SH"        : [OP_ST,    "001", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [None, 1, 0],    False],
    "SW"        : [OP_ST,    "010", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [None, 1, 0],    False],
    "ADDI"      : [OP_IMM,   "000", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None],    False],
    "SLTI"      : [OP_IMM,   "010", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None],    False],
    "SLTUI"     : [OP_IMM,   "011", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None],    False],
    "XORI"      : [OP_IMM,   "100", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None],    False],
    "ORI"       : [OP_IMM,   "110", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None],    False],
    "ANDI"      : [OP_IMM,   "111", None,      [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None],    False],
    "SLLI"      : [OP_IMM,   "001", "0000000", [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None],    False],
    "SRLI"      : [OP_IMM,   "101", "0000000", [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None],    False],
    "SRAI"      : [OP_IMM,   "101", "0100000", [TokenType.REG, TokenType.REG, TokenType.IMM], [0, 1, None],    False],
    "ADD"       : [OP_R3,    "000", "0000000", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2],       False],
    "SUB"       : [OP_R3,    "000", "0100000", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2],       False],
    "SLL"       : [OP_R3,    "001", "0000000", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2],       False],
    "SLT"       : [OP_R3,    "010", "0000000", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2],       False],
    "SLTU"      : [OP_R3,    "011", "0000000", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2],       False],
    "XOR"       : [OP_R3,    "100", "0000000", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2],       False],
    "SRL"       : [OP_R3,    "101", "0000000", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2],       False],
    "SRA"       : [OP_R3,    "101", "0100000", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2],       False],
    "OR"        : [OP_R3,    "110", "0000000", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2],       False],
    "AND"       : [OP_R3,    "111", "0000000", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2],       False],
    "MUL"       : [OP_R3,    "000", "0000001", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2],       False],
    "MULH"      : [OP_R3,    "001", "0000001", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2],       False],
    "MULHSU"    : [OP_R3,    "010", "0000001", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2],       False],
    "MULHU"     : [OP_R3,    "011", "0000001", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2],       False],
    "DIV"       : [OP_R3,    "100", "0000001", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2],       False],
    "DIVU"      : [OP_R3,    "101", "0000001", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2],       False],
    "REM"       : [OP_R3,    "110", "0000001", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2],       False],
    "REMU"      : [OP_R3,    "111", "0000001", [TokenType.REG, TokenType.REG, TokenType.REG], [0, 1, 2],       False]
}

PFORMAT    = 0
PMAP       = 1
PTRANSLATE = 2
PLABEL     = 4

# FORMAT: [[PFORMAT], [MAPPING], [TRANSLATION], [FORMAT], LABEL ALLOWED]        MAPPING = FOLLOWS INDICES OF TRANSLATION, CONTAINS INDICES OF PFORMAT (START AT 1 SINCE MNEMONIC IGNORED)
pseudo_instruction_dict = {
    "NOP" : [[None], [None], ["ADDI", "zero", "zero", "0"], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM], False],
    "LI" : [[TokenType.REG, TokenType.IMM], [], ["LOAD"], [], False],
    "LA" : [[TokenType.REG, TokenType.IMM], [], ["LOAD"], [], True],
    "MV" : [[TokenType.REG, TokenType.REG], [1, 2], ["ADDI", TokenType.REG, TokenType.REG, 0], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM], False], # TODO: REFACTOR FORMAT LISTS TO REFERENCE A STANDARD SET AND THE DICT OF NORMAL INSTS
    "NOT" : [[TokenType.REG, TokenType.REG], [1, 2], ["XORI", TokenType.REG, TokenType.REG, -1], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM], False],
    "NEG" : [[TokenType.REG, TokenType.REG], [1, 2], ["SUB", TokenType.REG, "x0", TokenType.REG], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.REG], False],
    "SEQZ" : [[TokenType.REG, TokenType.REG], [1, 2], ["SLTIU", TokenType.REG, TokenType.REG, 1], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM], False],
    "SNEZ" : [[TokenType.REG, TokenType.REG], [1, 2], ["SLTU", TokenType.REG, "x0", TokenType.REG], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.REG], False],
    "SLTZ" : [[TokenType.REG, TokenType.REG], [1, 2], ["SLT", TokenType.REG, TokenType.REG, "x0"], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.REG], False],
    "SGTZ" : [[TokenType.REG, TokenType.REG], [1, 2], ["SLT", TokenType.REG, "x0", TokenType.REG], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.REG], False],
    "BEQZ" : [[TokenType.REG, TokenType.IMM], [1, 2], ["BEQ", TokenType.REG, "x0", TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM], True],
    "BNEZ" : [[TokenType.REG, TokenType.IMM], [1, 2], ["BNE", TokenType.REG, "x0", TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM], True],
    "BLEZ" : [[TokenType.REG, TokenType.IMM], [1, 2], ["BGE", "x0", TokenType.REG, TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM], True],
    "BGEZ" : [[TokenType.REG, TokenType.IMM], [1, 2], ["BGE", TokenType.REG, "x0", TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM], True],
    "BLTZ" : [[TokenType.REG, TokenType.IMM], [1, 2], ["BLT", TokenType.REG, "x0", TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM], True],
    "BGTZ" : [[TokenType.REG, TokenType.IMM], [1, 2], ["BLT", "x0", TokenType.REG, TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM], True],
    "BGT" : [[TokenType.REG, TokenType.REG, TokenType.IMM], [2, 1, 3], ["BLT", TokenType.REG, TokenType.REG, TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM], True],
    "BLE" : [[TokenType.REG, TokenType.REG, TokenType.IMM], [2, 1, 3], ["BGE", TokenType.REG, TokenType.REG, TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM], True],
    "BGTU" : [[TokenType.REG, TokenType.REG, TokenType.IMM], [2, 1, 3], ["BLTU", TokenType.REG, TokenType.REG, TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM], True],
    "BLEU" : [[TokenType.REG, TokenType.REG, TokenType.IMM], [2, 1, 3], ["BLTU", TokenType.REG, TokenType.REG, TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM], True],
    "J" : [[TokenType.IMM], [1], ["JAL", "x0", TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.IMM], True],
    "JR" : [[TokenType.IMM], [1], ["JAL", "x1", TokenType.IMM], [TokenType.MNEMONIC, TokenType.REG, TokenType.IMM], True],
    "RET" : [[None], [None], ["JALR", "x0", "x1", "0"], [TokenType.MNEMONIC, TokenType.REG, TokenType.REG, TokenType.IMM], False]
}

###############################################################
#
#                  PARSE INSTRUCTIONS IN FILE
#
#  INPUT: FILE TO READ
#  OUTPUT: LIST OF LIST OF STRINGS
#  NOTES: THE OUTPUT IS A LIST OF LISTS, WITH EACH INTERNAL
#         LIST HOLDING EACH PART OF A SINGLE INSTRUCTION
#         AND THE INSTRUCTION LINE
#
#  EXAMPLE:
#  NEXT INSTRUCTION READ: ADD x1, x2, x3
#  LIST OF STRINGS REPRESENTATION: ["ADD", "x1", "x2", "x3", [line_num, "instruction"]]
#
###############################################################

def parse(instruction_lines):
    instruction_list = []
    symbols = {}
    blank_lines = 0
    for idx in range(len(instruction_lines)):
        instruction = instruction_lines[idx].replace("\n", "").rstrip().lstrip()
        line_num = idx + 1
        if instruction == "": 
            blank_lines += 1
            continue
        p_count = 0
        for i in range(len(instruction)):
            p_count += 1 if instruction[i] == '(' else 0
            p_count -= 1 if instruction[i] == ')' else 0
            if p_count < 0:
                pos = 46 + len(f"{idx}") + i
                print(f"\nERROR: MISSING OPENING PARENTHESIS - line {line_num}: {instruction}")
                print("^\n".rjust(pos))
                sys.exit()
        if (p_count > 0):
            pos = 46 + len(f"{idx}") + len(instruction)
            print(f"\nERROR: MISSING CLOSING PARENTHESIS - line {line_num}: {instruction}")
            print("^\n".rjust(pos))
            sys.exit()
        instruction_split = instruction.split(" ")
        parsed_instruction = []
        if len(instruction_split) == 1 and not instruction_split[0].upper() in ["NOP", "RET"]: # Handle symbols
            if instruction[-1] == ':': # Labels
                symbols[instruction[:-1]] = idx - len(symbols) - blank_lines
            else:
                print(f"\nERROR: INVALID SYMBOL - line {line_num}: {instruction}\n")
                sys.exit()
        else:
            for component in instruction_split:
                parsed_component = component.replace(",", "").replace(")", "").split("(")
                parsed_instruction.extend(parsed_component)
            parsed_instruction.append([line_num, instruction])
            instruction_list.append(parsed_instruction)
    return instruction_list, symbols

###############################################################
#
#          TOKENIZE INSTRUCTIONS FROM LIST OF LISTS
#
#  INPUT: LIST OF LIST OF STRINGS
#  OUTPUT: TOKEN LIST
#  NOTES: THE OUTPUT IS A LIST OF TOKENS WTIH THE LINE INFO
#
#  EXAMPLE:
#  NEXT INSTRUCTION LIST: ["ADD", "x1", "x2", "x3", [line_num, "instruction"]]
#  TOKEN LIST: [T(ADD), T(x1), T(x2), T(x3), [line_num, "instruction"]]
#
###############################################################

def tokenize(instructions_list):
    token_list = []
    for instruction in instructions_list:
        tokens = []
        for operand in instruction[:-1]:
            if register_dict.get(operand) != None: # Register
                tokens.append(Token(operand, TokenType.REG))
            elif instruction_dict.get(operand.upper()) != None or pseudo_instruction_dict.get(operand.upper()) != None: # Mnemonic
                tokens.append(Token(operand.upper(), TokenType.MNEMONIC))
            elif operand.isnumeric() or (operand[1:].isnumeric() and operand[0] == '-'): # Immediate/offset
                tokens.append(Token(int(operand), TokenType.IMM))
            elif operand[:2] == "0b" and operand[2:].isnumeric(): # Binary immediates
                tokens.append(Token(int(operand[2:], 2), TokenType.IMM))
            elif operand[:2] == "0x" and not (set(operand[2:]) - set(hex_chars)): # Hex immediates
                tokens.append(Token(int(operand[2:], 16), TokenType.IMM))
            elif operand in symbols.keys(): # Label
                tokens.append(Token(operand, TokenType.IMM))
            else:
                line_num, instruction_line = instruction[-1]
                op_type = "MNEMONIC" if instruction.index(operand) == 0 else "OPERAND"
                pos = 27 + len(f"{line_num}") + instruction_line.find(operand) + len(op_type)
                print(f"\nERROR: INVALID {op_type} - line {line_num}: {instruction_line}")
                print("^\n".rjust(pos))
                sys.exit()
        tokens.append(instruction[-1])
        token_list.append(tokens)
    return token_list

###############################################################
#
#          VALIDATE TOKENS OF EACH INSTRUCTION
#
#  INPUT: LIST OF LIST OF TOKENS
#  OUTPUT: NONE
#  NOTES: HAS NO OUTPUT, BUT RAISES ERRORS WHEN TOKENS
#         DON'T MEET THE INSTRUCTION REQUIREMENTS.
#
#  EXAMPLE:
#  NEXT TOKEN LIST: [T(ADD), T(x1), T(x2), T(x3), [line_num, "instruction"]]
#  OUTPUT: NOTHING
#
###############################################################
def validate(token_list):
    for tokens in token_list:      
        line_num, instruction_line = tokens[-1];
        
        mnemonic = tokens[0]
        mnemonic_name = mnemonic.value
        is_pseudo = pseudo_instruction_dict.get(mnemonic_name) != None
        if is_pseudo:
            dict_entry = pseudo_instruction_dict[mnemonic_name]
            inst_format = dict_entry[PFORMAT]
            mnemonic_name = dict_entry[PTRANSLATE][0]
        else:
            dict_entry = instruction_dict[mnemonic_name]
            inst_format = dict_entry[FORMAT]
        opcode = instruction_dict[mnemonic_name][OPCODE] if mnemonic_name != "LOAD" else "LOAD"
        
        operands = tokens[1:-1]
        if (inst_format[0] != None):
            if len(operands) != len(inst_format):
                pos = 8 + len(f"{line_num}") + len(instruction_line)
                print(f"\nERROR: INVALID OPERAND COUNT - GOT {len(operands)} - EXPECTED {len(inst_format)}")
                print(f"line {line_num}: {instruction_line}")
                print("^\n".rjust(pos))
                sys.exit()
                
            for operand, op_format in zip(operands, inst_format):
                if operand.type == TokenType.IMM and op_format == TokenType.REG and operand.value < 32: # Account for using register numbers
                    operand.type = TokenType.REG
                elif operand.type == TokenType.IMM and op_format == TokenType.IMM: # Check immediate types
                    if isinstance(operand.value, int): # Integer immediate - check size
                        imm_size = immediate_sizes[opcode]
                        max_imm = 2**imm_size - 1
                        if operand.value > max_imm:
                            pos = 40 + len(f"{line_num}") + instruction_line.find(f"{operand.value}")
                            print(f"\nERROR: INVALID IMMEDIATE SIZE - line {line_num}: {instruction_line}")
                            print("^".rjust(pos))
                            print(f"MAX IMM SIZE: {max_imm}\n")
                            sys.exit()
                    elif not ((is_pseudo and dict_entry[PLABEL]) or dict_entry[LABEL]): # Label - check if valid for instruction
                        pos = 9 + len(f"{line_num}") + instruction_line.find(operand.value)
                        print(f"\nERROR: INVALID OPERAND TYPE - EXPECTED IMMEDIATE, GOT LABEL")
                        print(f"line {line_num}: {instruction_line}")
                        print(f"^\n".rjust(pos))
                elif operand.type != op_format:
                    pos = 9 + len(f"{line_num}") + instruction_line.find(f"{operand.value}")
                    print(f"\nERROR: INVALID OPERAND TYPE - EXPECTED {op_format}, GOT {operand.type}")
                    print(f"line {line_num}: {instruction_line}")
                    print("^\n".rjust(pos))
                    sys.exit()

###############################################################
#
#      REPLACE PSEUDO INSTRUCTIONS WITH REAL INSTRUCTIONS
#
#  INPUT: LIST OF LIST OF TOKENS
#  OUTPUT: LIST OF LIST OF TOKENS
#  NOTES: HAS SIMILAR OUTPUT, EXCEPT ALL PSEUDO INSTRUCTIONS
#         HAVE BEEN REPLACED. 
#
#  EXAMPLE:
#  NEXT TOKEN LIST: [T(NOT), T(x1), T(x2), [line_num, "instruction"]]
#  OUTPUT: [T(XORI), T(x1), T(x2) T(-1), [line_num, "instruction"]]
#
###############################################################
def replace_pseudo(token_list, symbols):
    extra_lines = 0
    new_token_list = []
    for line_num, tokens in enumerate(token_list):
        mnemonic = tokens[0]
        if pseudo_instruction_dict.get(mnemonic.value) != None:
            pseudo_instruction = pseudo_instruction_dict[mnemonic.value]
            pseudo_translation = pseudo_instruction[PTRANSLATE]
            pseudo_format = pseudo_instruction[FORMAT]
            pseudo_mapping = pseudo_instruction[PMAP]
            
            if pseudo_translation[0] == "LOAD": # LI OR LA
                reg_token = tokens[1]
                target_addr = tokens[2].value
                if isinstance(target_addr, str): # Label for LA
                    split_imm = [target_addr, target_addr]
                else:
                    split_imm = [target_addr, 0]
                    split_imm[1] = target_addr & 0xFFF
                    split_imm[0] -= split_imm[1] if split_imm[1] < 2**11 else -split_imm[1]
                
                lui_tokens = [Token() for i in range(len(instruction_dict["LUI"][FORMAT]) + 1)]
                lui_tokens.append(tokens[-1])
                lui_tokens[0].value = "LUI"
                lui_tokens[0].type = TokenType.MNEMONIC
                lui_tokens[1] = reg_token
                lui_tokens[2].value = split_imm[0]
                lui_tokens[2].type = TokenType.IMM
                new_token_list.append(lui_tokens)
                
                addi_tokens = [Token() for i in range(len(instruction_dict["ADDI"][FORMAT]) + 1)]
                addi_tokens.append(tokens[-1])
                addi_tokens[0].value = "ADDI"
                addi_tokens[0].type = TokenType.MNEMONIC
                addi_tokens[1] = reg_token
                addi_tokens[2] = reg_token
                addi_tokens[3].value = split_imm[1]
                addi_tokens[3].type = TokenType.IMM
                new_token_list.append(addi_tokens)
                
                for label, line in symbols.items():
                    if line > line_num: # Label after current instruction
                        symbols[label] = line + 1
                extra_lines += 1
            else:
                pseudo_tokens = [Token() for i in range(len(pseudo_format))]
                pseudo_tokens.append(tokens[-1])

                idx = 0;
                for i in range(len(pseudo_format)):
                    if isinstance(pseudo_translation[i], str) or isinstance(pseudo_translation[i], int):
                        pseudo_tokens[i].value = int(pseudo_translation[i]) if pseudo_translation[i].isnumeric() else pseudo_translation[i]
                        pseudo_tokens[i].type = pseudo_format[i]
                    else:
                        pseudo_tokens[i] = tokens[pseudo_mapping[idx]]
                        idx = idx + 1
                new_token_list.append(pseudo_tokens)   
        else: new_token_list.append(tokens)
    return new_token_list

###############################################################
#
#          TRANSLATE TOKENS OF EACH INSTRUCTION
#
#  INPUT: LIST OF LIST OF TOKENS
#  OUTPUT: LIST OF BINARY MACHINE CODE OF EACH INSTRUCTION
#
#  EXAMPLE:
#  NEXT TOKEN LIST: [T(ADD), T(x1), T(x2), T(x3), [line_num, "instruction"]]
#  OUTPUT: 00000000001100010000000010110011
#
###############################################################
def translate(token_list, symbols):
    machine_code = []
    for idx, tokens in enumerate(token_list):
        mnemonic = tokens[0]
        fields = instruction_dict[mnemonic.value]
        opcode = fields[OPCODE]
        funct3 = fields[FUNCT3]
        funct7 = fields[FUNCT7]
        
        immediate = None
        imm_size = immediate_sizes[opcode]
        inst_registers = []
        for token in tokens[1:-1]:
            if token.type == TokenType.IMM:
                if isinstance(token.value, str):
                    if mnemonic.value == "ADDI":
                        imm_val = (symbols[token.value] * 4) & 0xFFF
                    elif mnemonic.value == "LUI":
                        lsb = (symbols[token.value] * 4) & 0xFFF
                        imm_val = symbols[token.value] * 4
                        imm_val -= lsb if lsb < 2**11 else -lsb
                    else:
                        imm_val = (symbols[token.value] - idx) * 4
                else: imm_val = token.value
                    
                if imm_val >= 2**imm_size:
                    line_num, instruction_line = tokens[-1]
                    print(f"\nERROR: LABEL OUT OF RANGE - LIMIT: {2**imm_size}, GOT: {imm_val}")
                    print(f"line {line_num}: {instruction_line}\n")
                    sys.exit()
                immediate = binary_repr(imm_val, imm_size)
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
            if mnemonic.value in ["SLLI", "SRLI", "SRAI"]:
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
            inst_code += immediate[:20] + reg_dest + opcode
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
                    print("\nERROR: NO OUTPUT FILE NAME PROVIDED\n") # TODO: MAYBE ALLOW NO NAME TO BE PROVIDED, DEFAULT IS SAME NAME AS INPUT FILE
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
                instructions, symbols = parse(file_instructions)
                tokens = tokenize(instructions)
                validate(tokens)
                tokens_ptrans = replace_pseudo(tokens, symbols)
                machine_code = translate(tokens_ptrans, symbols)
                for code in machine_code:
                    if out_mode == "wb+":
                        code = bytes(int(code[i:i+8], 2) for i in range(0, len(code), 8))
                        output_file.write(code)
                    else:
                        output_file.write(f"{code}\n")
    except FileNotFoundError:
        print(f"\nERROR: FILE {in_file_name} DOES NOT EXIST\n")
        sys.exit()


