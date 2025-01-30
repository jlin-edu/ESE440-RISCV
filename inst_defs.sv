// INCLUDE HEADERS!!!!!!

`ifndef DEFINITIONS
`define DEFINITIONS

// ===============================

`define MAX_32 32'hFFFFFFFF // might move to different file

// ===============================

// OPCODE DEFINITIONS
`define OP_SIZE 7
`define OP_RANGE `OP_SIZE-1:0
`define OP_FIELD 6:0

`define OP_IMM 7'b0010011
`define OP_R3 7'b0110011	   
`define OP_BR 7'b1100011
`define OP_LD 7'b0000011 
`define OP_ST 7'b0100011

`define OP_LUI 7'b0110111
`define OP_AUIPC 7'b0010111 

`define OP_JAL 7'b1101111
`define OP_JALR 7'b1100111

// ===============================

// FUNCT3 DEFINITIONS
`define FUNCT_3_SIZE 3
`define FUNCT_3_RANGE `FUNCT_3_SIZE-1:0
`define FUNCT_3_FIELD 14:12

// IMM DEFINITIONS
`define ADDI 3'b000
`define SLTI 3'b010
`define SLTIU 3'b011
`define XORI 3'b100
`define ORI 3'b110
`define ANDI 3'b111
`define SLLI 3'b001
`define SRLI_SRAI 3'b101

// R3 DEFINITIONS
`define ADD_SUB 3'b000
`define SLL 3'b001
`define SLT 3'b010
`define SLTU 3'b011
`define XOR 3'b100
`define SRL_SRA 3'b101
`define OR 3'b110
`define AND 3'b111

// BR DEFINITIONS
`define BEQ 3'b000
`define BNE 3'b001
`define BLT 3'b100
`define BGE 3'b101
`define BLTU 3'b110
`define BGEU 3'b111

// LD DEFINITIONS
`define LB 3'b000
`define LH 3'b001
`define LW 3'b010
`define LBU 3'b100
`define LHU 3'b101

// ST DEFINITIONS
`define SB 3'b000
`define SH 3'b001
`define SW 3'b010

// M DEFINITIONS
`define MUL 3'b000
`define MULH 3'b001
`define MULHSU 3'b010
`define MULHU 3'b011
`define DIV 3'b100
`define DIVU 3'b101
`define REM 3'b110
`define REMU 3'b111

// ===============================

// FUNCT7 DEFINITIONS
`define FUNCT_7_SIZE 7
`define FUNCT_7_RANGE `FUNCT_7_SIZE-1:0
`define FUNCT_7_FIELD 31:25

`define DEFAULT_7 7'b0000000

// IMM DEFINITIONS
`define SRLI 7'b0000000
`define SRAI 7'b0100000

// R3 DEFINITIONS
`define ADD 7'b0000000
`define SUB 7'b0100000
`define SRL 7'b0000000
`define SRA 7'b0100000
`define M 7'b0000001

// ===============================

// REGISTER DEFINITIONS
`define REG_FIELD_SIZE 5
`define REG_FIELD_RANGE `REG_FIELD_SIZE-1:0

`define REG_RD 11:7
`define REG_RS1 19:15
`define REG_RS2 24:20

`define REG_SIZE 32
`define REG_RANGE `REG_SIZE-1:0

// ===============================

// IMMEDIATE DEFINITIONS
`define IMM_SIZE_I 12
`define IMM_SIZE_S 12
`define IMM_SIZE_B 13
`define IMM_SIZE_U 20
`define IMM_SIZE_J 21

`define IMM_RANGE_I `IMM_SIZE_I-1:0
`define IMM_RANGE_S `IMM_SIZE_S-1:0
`define IMM_RANGE_B `IMM_SIZE_B-1:0
`define IMM_RANGE_U `IMM_SIZE_U-1:0
`define IMM_RANGE_J `IMM_SIZE_J-1:0

`define IMM_FIELD_I 31:20

`define IMM_FIELD_S_U 31:25
`define IMM_FIELD_S_L 11:7

`define IMM_FIELD_B_12 31
`define IMM_FIELD_B_10_5 30:25
`define IMM_FIELD_B_11 7
`define IMM_FIELD_B_4_1 11:8

`define IMM_FIELD_U 31:12

`define IMM_FIELD_J_20 31
`define IMM_FIELD_J_19_12 19:12
`define IMM_FIELD_J_11 20
`define IMM_FIELD_J_10_1 30:21

// ===============================

`define NOP 32'b00000000000000000000000000010011

`endif
