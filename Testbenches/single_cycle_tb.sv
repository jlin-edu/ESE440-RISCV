`include "inst_defs.sv"

module single_cycle_tb ();
    parameter   WIDTH=32, SIZE=64;
    localparam  LOGSIZE=$clog2(SIZE);

    logic [WIDTH-1:0] instr_in;
    logic [(LOGSIZE-1)+2:0] instr_wr_addr;
    logic instr_wr_en;

    logic clk, reset;
    initial clk  = 0;
    always #5 clk  = ~clk;

    single_cycle #(.WIDTH(WIDTH), .SIZE(SIZE)) dut(.clk(clk), .reset(reset),
                                                    .instr_in(instr_in), .instr_wr_addr(instr_wr_addr), .instr_wr_en(instr_wr_en));

    logic [31:0] testData[20:0];
    initial $readmemb("data.txt", testData);

    integer i;
    initial begin
        //@(posedge clk);
        reset = 1;
        for(i=0; i<10; i=i+1) begin
            instr_in = testData[i][31:0];     
            instr_wr_addr = i*4;            //the i*4 is a left shift twice since we are indexing by word
            instr_wr_en = 1;
            @(posedge clk);
        end

        #1; instr_in = 0; instr_wr_addr = 0; instr_wr_en = 0;
        @(posedge clk);

        #1; reset = 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        $finish;
    end
endmodule
