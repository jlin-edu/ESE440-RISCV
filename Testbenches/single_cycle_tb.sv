`include "inst_defs.sv"

module single_cycle_tb ();

logic clk, reset, debug_en, inst_we, inst_clk;
logic [`REG_FIELD_RANGE] debug_reg_addr;
logic [`REG_RANGE] debug_inst_addr, debug_mem_addr, inst_wr_addr, inst_wr_data;
logic [`REG_RANGE] debug_inst_data, debug_reg_data, debug_mem_data;

single_cycle UUT (.*);

int in_fd, out_fd;
string line;

initial begin
    clk = 0;
    reset = 0;

    debug_en = 1;
    debug_inst_addr = 0;
    debug_mem_addr = 0;
    debug_reg_addr = 0;

    inst_we = 0;
    inst_clk = 0;
    inst_wr_addr = 0;
    inst_wr_data = 0;
end

always begin
    if (clk_en) begin
        #5 clk = ~clk;
    end
end



endmodule