`include "inst_defs.sv"

module InstructionMem #(
    parameter WIDTH = 32, SIZE = 256 // 2**(WIDTH) USE THIS IF SPACE AVAILABLE SINCE PC IS 32 BITS SO 2^32 ADDRESSES
    ) (
    input logic [`REG_RANGE] PC, write_data, write_addr,
    input logic clk, reset, write_enable,
    output logic [`REG_RANGE] data_out,
    );

    // Memory array
    logic [SIZE-1:0][WIDTH-1:0] InstMem;

    // it should take the address and return the data
    always_comb begin : Instruction_Mem_block
        if (reset) begin
            InstMem = 0;
        end else if (write_enable) begin
            InstMem[write_addr] = write_data;
        end
        data_out = InstMem[PC];   
    end
    
endmodule