`include "inst_defs.sv"

module data_memory #(   
    parameter                   WIDTH=32, SIZE=256,         //WIDTH is bits per word, SIZE is # of WORDS
    parameter                   NUM_COL   = 4,
    parameter                   COL_WIDTH = 8,
    localparam                  LOGSIZE=$clog2(SIZE)
)(
    input [WIDTH-1:0]           data_in,
    output logic [WIDTH-1:0]    data_out,
    input [LOGSIZE-1:0]         word_addr,
    input                       clk,
    input [NUM_COL-1:0]         byte_wr_en,
    input                       reset
);

    logic [WIDTH-1:0] mem [SIZE-1:0];

    
    integer i;
    always_ff @(posedge clk) begin
        if(reset) begin
            data_out <= 0;
        end
        else begin
            for(i=0;i<NUM_COL;i=i+1) begin
                if(byte_wr_en[i])
                    mem[word_addr][i*COL_WIDTH +: COL_WIDTH] <= data_in[i*COL_WIDTH +: COL_WIDTH];
            end
            data_out <= mem[word_addr];
        end
        //add secondary axi port 
        //
    end
    
endmodule