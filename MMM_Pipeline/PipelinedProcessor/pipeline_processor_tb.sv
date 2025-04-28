`include "inst_defs.sv"

// Single Cycle Testbench, specify the program to run in the program_file string.
// The program will run for 256 clock cycles, this can be changed in the cycles variable

module pipelined_processor_tb ();
    parameter   WIDTH=32, SIZE=256, NUM_COL=4, COL_WIDTH=8;
    localparam  QUARTER_SIZE=SIZE/4;
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

    int fd;
    string line;

    string program_file = "simple_mmm_test.txt";
    int cycles = QUARTER_SIZE*int'($sqrt(QUARTER_SIZE))*2;

    initial begin 
        fd = $fopen(program_file, "r");
        shared_bram_addr = 0;
        reset = 1;
        bram_wr_en = 4'b1111;
        while (!$feof(fd)) begin
            $fgets(line, fd);
            $sscanf(line, "%b\n", bram_din);
            @(posedge clk);
            shared_bram_addr += 4;
            @(negedge clk);
        end
        $fclose(fd);
        
        //Preload values into data memory
        shared_bram_addr = (SIZE)*4;
        for(int i=0; i<QUARTER_SIZE; i++) begin   //load input matrix a
            bram_din = i;
            @(posedge clk);
            shared_bram_addr += 4;
            @(negedge clk);
        end
        
        shared_bram_addr = (SIZE+QUARTER_SIZE)*4;
        for(int i=0; i<QUARTER_SIZE; i++) begin   //load input matrix a
            bram_din = i;
            @(posedge clk);
            shared_bram_addr += 4;
            @(negedge clk);
        end
        
        shared_bram_addr = (SIZE+(QUARTER_SIZE*2))*4;
        for(int i=0; i<QUARTER_SIZE; i++) begin   //load input matrix b
            bram_din = QUARTER_SIZE-i;
            @(posedge clk)
            shared_bram_addr += 4;
            @(negedge clk);
        end
        
        shared_bram_addr = (SIZE+(QUARTER_SIZE*3))*4;
        for(int i=0; i<QUARTER_SIZE; i++) begin   //load input matrix a
            bram_din = i;
            @(posedge clk);
            shared_bram_addr += 4;
            @(negedge clk);
        end
        
        //try a read test here
        
        
        
        bram_din = 0; shared_bram_addr = 0; bram_wr_en = 0;
        reset = 0;
        
        for (int i = 0; i < cycles + 1; i++) begin @(posedge clk); end

        $finish;
    end
endmodule
