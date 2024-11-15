`include "inst_defs.sv"

module inst_fetch (
    input logic reset, pc_sel, clk, write_en, debug_en,
    input logic [`REG_RANGE] jump_addr, debug_pc, write_addr, write_data,
    output logic [`REG_RANGE] instruction, pc, pc_4, debug_out
);

PC program_counter (.jump_addr(jump_addr), .pc_sel(pc_sel), .clk(clk), .reset(reset), .pc(pc), .pc_4(pc_4));

InstructionMem #() inst_memory (.PC(pc), .write_data(write_data), .write_addr(write_addr),
    .clk(clk), .write_enable(write_en), .debug_en(debug_en),
    .data_out(instruction), .debug_pc(debug_pc), .debug_out(debug_out)
);

endmodule