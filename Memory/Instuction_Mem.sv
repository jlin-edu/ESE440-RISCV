`include "inst_defs.sv"

module InstructionMem #(
    parameter WIDTH = 8, SIZE = 1024 // USE THIS IF SPACE AVAILABLE SINCE PC IS 32 BITS SO 2^32 ADDRESSES
    ) (
    input logic [`REG_RANGE] PC, write_data, write_addr,
    input logic clk, reset, write_enable,
    output logic [`REG_RANGE] data_out,
    );

    // Memory array
    logic [SIZE-1:0][WIDTH-1:0] InstMem;

    logic base_pc = PC & 32'hFFFFFFFC;
    logic base_w_addr = write_addr & 32'hFFFFFFFC;

    // it should take the address and return the data
    always_comb begin : Instruction_Mem_block
        if (reset) begin
            InstMem = 0;
        end else if (write_enable) begin
            InstMem[base_w_addr] = write_data[7:0];
            InstMem[base_w_addr + 1] = write_data[15:8];
            InstMem[base_w_addr + 2] = write_data[23:16];
            InstMem[base_w_addr + 3] = write_data[31:24];
        end
        data_out = { InstMem[base_pc + 3], InstMem[base_pc + 2], InstMem[base_pc + 1], InstMem[base_pc] };   
    end
    
endmodule
