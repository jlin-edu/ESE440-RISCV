module InstructionMem #(
    parameter WIDTH = 32, SIZE = 256
    ) (
) (
    input logic [`REG_RANGE] PC,
    input logic clk, reset, write_enable,
    // input logic [`REG_RANGE] read_addr, write_addr,
    output logic [`REG_RANGE] data_out
    );

    // Memory array
    logic [SIZE-1:0][WIDTH-1:0] InstMem;

    // it should take the address and return the data
    always_ff @( posedge clk ) begin : Instruction_Mem_block
        if (reset) begin
            data_out <= 0;
        end
        else begin
            data_out <= InstMemmem[PC];
        end
    end
    
endmodule