`include "inst_defs.sv"

module inst_decode (
    input logic clk, reset,
    input logic [`REG_RANGE] instruction, pc_4, data_mem, alu_out,
    output logic [`OP_RANGE] opcode,
    output logic [`FUNCT_3_RANGE] funct3,
    output logic [`FUNCT_7_RANGE] funct7,
    output logic [`REG_RANGE] rs1, rs2, imm,
    output logic jump_sel, mem_we, reg_write_ctrl
    output logic store_ctrl, load_ctrl, op1_sel, op2_sel
);

logic [`REG_FIELD_RANGE] rs1_addr, rs2_addr, rd_addr;
logic reg_we;
logic [2:0] reg_source;
logic [`REG_RANGE] reg_data;

inst_decoder decoder (.inst(instruction), .rs1(rs1_addr), .rs2(rs2_addr), .rd(rd_addr),
                    .op(opcode), .funct3(funct3), .funct7(funct7), .imm(imm));

control_unit controller (.opcode(opcode), .funct3(funct3), .funct7(funct7),
                    .registerfile_write_enable(reg_we), .pc_rs1_sel(op1_sel),
                    .imm_rs2_sel(op2_sel), .jump_branch_sel(jump_sel), 
                    .mem_write_enable(mem_we), .register_write_select(),
                    .byte_enable(), .halfword_enable(), .word_enable(),
                    .store_ctrl(store_ctrl), .load_ctrl(load_ctrl), .reg_write_ctrl(reg_source));

RegFile #() registers (.clk(clk), .reset(reset), .write_enable(reg_we),
                    .read_addr1(rs1_addr), .read_addr2(rs2_addr), .write_addr(rd_addr),
                    .write_data_in(reg_data), .read_data_out1(rs1), .read_data_out2(rs2));

always_comb begin
    reg_data = 0;
    case (reg_source)
        0: reg_data = alu_out;
        1: reg_data = pc_4;
        2: reg_data = data_mem;
    endcase
end

endmodule