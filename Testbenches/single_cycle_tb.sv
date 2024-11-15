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

    int fd;
    string line;

    string program_file = "FILE NAME HERE";

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
        end
        $fclose(fd);
        instr_in = 0; instr_wr_addr = 0; instr_wr_en = 0;
        reset = 0;
        
        for (int i = 0; i < 256; i++) begin @(posedge clk); end

        $finish;
    end
endmodule
