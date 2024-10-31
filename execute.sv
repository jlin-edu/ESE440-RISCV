`include "inst_defs.sv"

module execute (
    input logic [`REG_RANGE] imm, pc, rs1, rs2,
    input logic [`OP_RANGE] opcode,
    input logic [`FUNCT_3_RANGE] funct3,
    input logic [`FUNCT_7_RANGE] funct7,
    input logic op1_sel, op2_sel, jump_sel,
    output logic [`REG_RANGE] alu_out, jump_addr,
    output logic pc_sel
);

logic [`REG_RANGE] op1, op2;

alu ALU (.in1(op1), .in2(op2), .op(opcode), 
        .funct_3(funct3), .funct_7(funct7),
        .out(alu_out), .pc_sel(pc_sel));

assign op1 = (op1_sel) ? pc : rs1;
assign op2 = (op2_sel) ? imm : rs2;
assign jump_addr = (jump_sel) ? pc + imm : alu_out;

endmodule