`include "inst_defs.sv"

module single_cycle (
    input logic clk, reset, debug_en, inst_we,
    input logic [`REG_FIELD_RANGE] debug_reg_addr,
    input logic [`REG_RANGE] debug_inst_addr, debug_mem_addr, inst_wr_addr, inst_wr_data,
    output logic [`REG_RANGE] debug_inst_data, debug_reg_data, debug_mem_data, debug_pc
);

logic pc_sel, jump_sel, mem_we, op1_sel, op2_sel;
logic [`OP_RANGE] opcode;
logic [`FUNCT_3_RANGE] funct3;
logic [`FUNCT_7_RANGE] funct7;
logic [`REG_RANGE] jump_addr, instruction, pc, pc_4, data_mem, alu_out, rs1, rs2, imm;

assign debug_pc = pc; // For reading PC value at top level

inst_fetch IF (.reset(reset), .pc_sel(pc_sel), .clk(clk), .write_en(inst_we),
            .jump_addr(jump_addr), .debug_pc(debug_inst_addr), .write_addr(inst_wr_addr),
            .write_data(inst_wr_data), .instruction(instruction), .pc(pc), .pc_4(pc_4),
            .debug_out(debug_inst_data));

inst_decode ID (.clk(clk), .reset(reset), .debug_en(debug_en), .instruction(instruction),
                .pc_4(pc_4), .data_mem(data_mem), .alu_out(alu_out), .debug_addr(debug_reg_addr),
                .opcode(opcode), .funct3(funct3), .funct7(funct7), .rs1(rs1), .rs2(rs2), .imm(imm),
                .debug_data(debug_reg_data), .jump_sel(jump_sel), .mem_we(mem_we), .op1_sel(op1_sel),
                .op2_sel(op2_sel));

execute EX (.imm(imm), .pc(pc), .rs1(rs1), .rs2(rs2), .opcode(opcode), .funct3(funct3), .funct7(funct7),
            .op1_sel(op1_sel), .op2_sel(op2_sel), .jump_sel(jump_sel), .alu_out(alu_out), .jump_addr(jump_addr),
            .pc_sel(pc_sel));

Data_Mem #() MEM (.clk(clk), .reset(reset), .write_enable(mem_we), .debug_en(debug_en),
                .addr(alu_out), .data_in(rs2), .data_out(data_mem), .debug_data(debug_mem_data));

endmodule
