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
# TO RUN ASSEMBLER: python assembler.py FILE_NAME_HERE.rsc
#
# OPTIONS:
#   -o : CHOOSE OUTPUT FILE NAME, DEFAULT IS rsc_out.txt
#


import sys

###############################################################
#
#                         TOKEN CLASS
#   
#       CLASS FOR EACH TOKEN OF AN INSTRUCTION. HAS A VALUE
#       AND TYPE ASSOCIATED WITH IT.
#
###############################################################

class Token:
    
    def __init__(self, value, token_type):
        self.value = value;
        self.type = token_type;

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
#  NOTES: THE OUTPUT IS A LINKED LIST OF TOKENS
#
#  EXAMPLE:
#  NEXT INSTRUCTION LIST: ["ADD", "x1", "x2", "x3"]
#  TOKEN LIST: T(ADD)->T(x1)->T(x2)->T(x3)
#
###############################################################

def tokenize(instructions_list):
    pass

if __name__ == "__main__":
    
    option = None
    
    if len(sys.argv) <= 1:
        print("\nERROR: NO FILE SPECIFIED\n")
        quit()
    
    if len(sys.argv) > 2:
        option = sys.argv[2]
        
        if option != "-o":
            print("\nERROR: INVALID OPTION\n")
            quit()
            
        if len(sys.argv) < 4:
            print("\nERROR: NO OUTPUT FILE NAME PROVIDED\n")
            quit()
            
    in_file_name = sys.argv[1]
    out_file_name = "rsc_out.txt"
    if option != None:
        out_file_name = sys.argv[3]
    
    try:
        with open(in_file_name, "r") as inst_file:
            with open(out_file_name, "w+") as output_file:      
                instructions = parse(inst_file)
                #tokens = tokenize(instructions)
                #machine_code = translate(tokens)
                print(instructions)
            
    except FileNotFoundError:
        print(f"\nERROR: FILE {in_file_name} DOES NOT EXIST\n")
        quit()


