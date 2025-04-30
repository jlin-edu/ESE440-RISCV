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
    input                       clk, clk_in,
    input [NUM_COL-1:0]         byte_wr_en,
    input                       reset,

    //Port B signals for AXI use
    input [WIDTH-1:0]           data_in_B,
    output logic [WIDTH-1:0]    data_out_B,
    input [(LOGSIZE-1)+2:0]     byte_addr_B,
    input [NUM_COL-1:0]         byte_wr_en_B
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
    end

    //B port for AXI use
    logic [LOGSIZE-1:0] word_addr_B;
    assign word_addr_B = byte_addr_B[(LOGSIZE-1)+2:2];
    integer j;
    always_ff @(posedge clk_in) begin
        //maybe leave out the reset, if we want to prefill data memory with data, then we can hold reset, leaving the B port open write
        //if(reset) begin
        //    data_out_B <= 0;
        //end
        //else begin
            for(j=0;j<NUM_COL;j=j+1) begin
                if(byte_wr_en_B[j])
                    mem[word_addr_B][j*COL_WIDTH +: COL_WIDTH] <= data_in_B[j*COL_WIDTH +: COL_WIDTH];
            end
            data_out_B <= mem[word_addr_B];
        //end
    end
    
endmodule