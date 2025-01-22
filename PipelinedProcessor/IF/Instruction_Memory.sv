`include "inst_defs.sv"

module instr_memory #(
    parameter                   WIDTH=32, SIZE=256,         //WIDTH is bits per word(shouldn't be changed), SIZE is # of WORDS
    localparam                  LOGSIZE=$clog2(SIZE)
)(
    input [WIDTH-1:0]           instr_in,       //the write port should only be used for filling the memory with instructions in a testbench
    input [(LOGSIZE-1)+2:0]     wr_addr, 
    input wr_en,
    input clk, reset,            //not sure if this is needed

    //input flush,    //hazard handling


    //input  [(LOGSIZE-1)+2:0]    pc,             //should this we REG_RANGE or should it rely on LOGSIZE??
    input [`REG_RANGE]          pc,
    output logic [WIDTH-1:0]    instr_out
);
    logic [WIDTH-1:0] mem [SIZE-1:0];

    logic [LOGSIZE-1:0] word_offset;
    logic [LOGSIZE-1:0] write_word_offset;
    assign word_offset = pc[(LOGSIZE-1)+2:2];
    assign write_word_offset = wr_addr[(LOGSIZE-1)+2:2];
    
    always_ff @(posedge clk) begin
        if(wr_en)
            mem[write_word_offset] <= instr_in;

        //if((reset == 1) || (flush == 1)) begin
        if(reset == 1)    //optional reset
            instr_out <= `NOP;
        else
            instr_out <= mem[word_offset];
    end
endmodule