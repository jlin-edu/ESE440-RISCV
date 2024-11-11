`include "inst_defs.sv"

module inst_decode (
    input logic clk, reset, debug_en,
    input logic [`REG_RANGE] instruction, pc_4, data_mem, alu_out,
    input logic[`REG_FIELD_RANGE] debug_addr,
    output logic [`OP_RANGE] opcode,
    output logic [`FUNCT_3_RANGE] funct3,
    output logic [`FUNCT_7_RANGE] funct7,
    output logic [`REG_RANGE] debug_data,
    output logic [`REG_RS1] rs1,
    output logic [`REG_RS2] rs2,
    output logic [`REG_RD] rd,
    output logic [`REG_RANGE] imm,
    output logic reg_wr_en,
    output logic jump_sel, mem_we,
    output logic op1_sel, op2_sel,
    output logic [1:0] reg_write_ctrl
);

logic [`REG_FIELD_RANGE] rs1_addr, rs2_addr, rd_addr;

logic [`REG_RANGE] reg_data;
logic [`REG_RS1] rs1_decoder, rs1_regfile;
logic [`REG_RS2] rs2_decoder, rs2_regfile;

inst_decoder decoder (.inst(instruction), .rs1(rs1), .rs2(rs2), .rd(rd),
                    .op(opcode), .funct3(funct3), .funct7(funct7), .imm(imm));

control_unit controller (.opcode(opcode), .funct3(funct3), .funct7(funct7),
                    .reg_wr_en(reg_wr_en), .pc_rs1_sel(op1_sel),
                    .imm_rs2_sel(op2_sel), .jump_branch_sel(jump_sel), 
                    .mem_wr_en(mem_we), .reg_write_ctrl(reg_write_ctrl));

RegFile #() registers (.clk(clk), .reset(reset), .write_enable(reg_wr_en),
                    .read_addr1(rs1_addr), .read_addr2(rs2_addr), .write_addr(rd_addr),
                    .write_data_in(reg_data), .read_data_out1(rs1_regfile), .read_data_out2(rs2_regfile),
                    .debug_en(debug_en), .debug_addr(debug_addr), .debug_data(debug_data));

// TO DO: MOVE TO WB IN FUTURE
always_comb begin
    reg_data = 0;
    case (reg_write_ctrl)
        0: reg_data = alu_out;
        1: reg_data = pc_4;
        2: reg_data = data_mem;
    endcase
end
endmodule