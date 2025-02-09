`include "inst_defs.sv"

module PC (
    input [`REG_RANGE] jmp_addr,
    input pc_sel, clk,
    output logic [`REG_RANGE] pc, pc_4
);

    //adder
    always_comb begin
        pc_4 = pc + 4;
    end

    //Counter Register for PC & Mux
    always_ff @(posedge clk) begin
        if (pc_sel) begin
            pc <= jump_addr;
        end else begin
            pc <= pc_4;
        end
    end

endmodule

//Instruction Memory
module InstructionMem #(
    parameter WIDTH = 32; 
    parameter SIZE  = 256;
)(
    input logic [`REG_RANGE] PC,
    input logic clk, reset, write_enable,
    // input logic [`REG_RANGE] read_addr, write_addr,
    output logic [`REG_RANGE] data_out
);

    // Memory array
    logic [SIZE-1:0][WIDTH-1:0] InstMem;

    //Write
    //should only use the top bits for word addressing [31:2], can use the bottom 2 bits for byte addressing within a word(maybe?)

    // it should take the address and return the data
    always_comb begin : Instruction_Mem_block
        if (reset) begin
            data_out <= 0;
        end
        else begin
            if (write_enable) begin 
                data_out <= InstMemmem[PC];
            end   
        end
    end
    
endmodule

//Top Level Module
module fetch(

);

endmodule