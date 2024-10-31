`include "inst_defs.sv"

module InstructionMem #(
    parameter WIDTH = 8, SIZE = 1024 // USE THIS IF SPACE AVAILABLE SINCE PC IS 32 BITS SO 2^32 ADDRESSES
    ) (
    input logic [`REG_RANGE] PC, write_data, write_addr, debug_pc,
    input logic clk, w_clk, reset, write_enable, debug_en,
    output logic [`REG_RANGE] data_out, debug_out
    );

    // Memory array
    logic [SIZE-1:0][WIDTH-1:0] InstMem;

    // Base addresses
    logic [`REG_RANGE] base_pc;
    logic [`REG_RANGE] base_w_addr;
    logic [`REG_RANGE] base_debug;

    // When PC changes, the output instruction changes
	assign base_pc = PC & 32'hFFFFFFFC;
	assign data_out = { InstMem[base_pc + 3], InstMem[base_pc + 2], InstMem[base_pc + 1], InstMem[base_pc] };	
	
    assign base_debug = debug_pc & 32'hFFFFFFFC;
    always_comb begin
        if (debug_en) begin
            debug_out = { InstMem[base_debug + 3], InstMem[base_debug + 2], InstMem[base_debug + 1], InstMem[base_debug] };
        end
    end

    // Only write/reset on clock pulse and with appropriate signals
	assign base_w_addr = write_addr & 32'hFFFFFFFC;
    always_ff @(posedge clk or posedge w_clk) begin
        if (reset) begin
            InstMem <= '{default: 0};
        end else if (write_enable) begin
            InstMem[base_w_addr] <= write_data[7:0];
            InstMem[base_w_addr + 1] <= write_data[15:8];
            InstMem[base_w_addr + 2] <= write_data[23:16];
            InstMem[base_w_addr + 3] <= write_data[31:24];
        end
    end
    
endmodule
