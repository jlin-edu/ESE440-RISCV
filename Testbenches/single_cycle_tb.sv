`include "inst_defs.sv"

// Single Cycle Testbench, specify the program to run in the program_file string.
// The program will run for 256 clock cycles, this can be changed in the cycles variable

module single_cycle_tb ();
    parameter   WIDTH=32, SIZE=64;
    localparam  LOGSIZE=$clog2(SIZE);

    logic [WIDTH-1:0] instr_in;
    logic [(LOGSIZE-1)+2:0] instr_wr_addr;
    logic instr_wr_en;

    logic clk, reset;
    initial clk  = 0;
    always #5 clk  = ~clk;

    pipelined_processor #(.WIDTH(WIDTH), .SIZE(SIZE)) dut(.clk(clk), .reset(reset),
                    .instr_in(instr_in), .instr_wr_addr(instr_wr_addr), .instr_wr_en(instr_wr_en));

    int fd;
    string line;

    string program_file = "branch_test.txt";
    int cycles = 32;

    initial begin    
        fd = $fopen(program_file, "r");
        instr_wr_addr = 0;
        reset = 1;
        instr_wr_en = 1;
        while (!$feof(fd)) begin
            $fgets(line, fd);
            $sscanf(line, "%b\n", instr_in);
            @(posedge clk);
            instr_wr_addr += 4;
            @(negedge clk);
        end
        $fclose(fd);
        instr_in = 0; instr_wr_addr = 0; instr_wr_en = 0;
        reset = 0;
        
        for (int i = 0; i < cycles + 1; i++) begin @(posedge clk); end

        $finish;
    end
endmodule
