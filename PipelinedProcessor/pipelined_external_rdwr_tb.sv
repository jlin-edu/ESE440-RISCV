`include "inst_defs.sv"

// Single Cycle Testbench, specify the program to run in the program_file string.
// The program will run for 256 clock cycles, this can be changed in the cycles variable

module single_cycle_tb ();
    parameter   WIDTH=32, SIZE=128, NUM_COL=4, COL_WIDTH=8;
    localparam  LOGSIZE=$clog2(SIZE);

    //logic [WIDTH-1:0]       instr_in;
    //logic [(LOGSIZE-1)+2:0] instr_wr_addr;
    //logic [NUM_COL-1:0]     instr_wr_en;

    logic clk, reset;
    initial clk  = 0;
    always #5 clk  = ~clk;
    
    //logic [WIDTH-1:0]    AXI_dmem_data_in;
    //logic [WIDTH-1:0]    AXI_dmem_data_out;
    //logic [LOGSIZE-1:0]  AXI_dmem_word_addr;
    //logic [NUM_COL-1:0]  AXI_dmem_byte_wr_en;
    
    //initial AXI_dmem_data_in = 0;
    //initial AXI_dmem_data_out = 0;
    //initial AXI_dmem_word_addr = 0;
    //initial AXI_dmem_byte_wr_en = 0;
    logic [WIDTH-1:0]       bram_din;
    logic [(LOGSIZE)+2:0]   shared_bram_addr;
    logic [NUM_COL-1:0]     bram_wr_en;
    logic [WIDTH-1:0]       bram_dout;

    pipelined_processor #(.WIDTH(WIDTH), .SIZE(SIZE), .NUM_COL(NUM_COL), .COL_WIDTH(COL_WIDTH)) dut(.clk(clk), .reset(reset),
                    .bram_din(bram_din), .shared_bram_addr(shared_bram_addr), .bram_wr_en(bram_wr_en), .bram_dout(bram_dout));

    //int fd;
    //string line;

    //string program_file = "Mat_mul.txt";
    //int cycles = 1024;

    initial begin    
        //fd = $fopen(program_file, "r");
        //shared_bram_addr = 0;
        reset = 1;
        bram_wr_en = 4'b1111;
        //while (!$feof(fd)) begin
        //    $fgets(line, fd);
        //    $sscanf(line, "%b\n", bram_din);
        //    @(posedge clk);
        //    shared_bram_addr += 4;
        //    @(negedge clk);
        //end
        //$fclose(fd);
        //bram_din = 0; shared_bram_addr = 0; bram_wr_en = 0;
        //reset = 0;
        
        //for (int i = 0; i < cycles + 1; i++) begin @(posedge clk); end
        
        //write some numbers into both instruction memory and data memory
        for (int i = 0; i < (SIZE*4*2); i+=4) begin
            shared_bram_addr = i;
            bram_din = i;
            @(posedge clk);
            #1;
        end

        $finish;
    end
endmodule
