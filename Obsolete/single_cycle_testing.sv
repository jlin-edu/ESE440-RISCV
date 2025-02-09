module SingleCycleProcessorTesting;

    // Parameters
    parameter WIDTH = 32;
    parameter SIZE = 64;
    localparam LOGSIZE = $clog2(SIZE);

    // Signals
    logic clk, reset;
    logic [WIDTH-1:0] instr_in;
    logic [(LOGSIZE-1)+2:0] instr_wr_addr;
    logic instr_wr_en;

    integer fd, fd_out;
    string line;

    logic [WIDTH-1:0] instruction;
    int instr_addr = 0;

    single_cycle #(.WIDTH(WIDTH), .SIZE(SIZE)) dut (
        .instr_in(instr_in),
        .instr_wr_addr(instr_wr_addr),
        .instr_wr_en(instr_wr_en),
        .clk(clk),
        .reset(reset)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // Testbench logic
    initial begin
        // Initialize signals
        reset = 1;
        instr_wr_en = 1;
        instr_in = 0;
        instr_wr_addr = 0;

        // Open files for reading and writing
        fd = $fopen("program.txt", "r");
        fd_out = $fopen("test_instructions_out.txt", "w");
        line ="";

        while (!$feof(fd)) begin
            $fgets(line, fd);
            $fscanf(fd, "%b", instr_in);
            @ (posedge clk);
            instr_wr_addr += 4;
            // Print the values of instr_in, instr_wr_addr, and instr_wr_en
            $fwrite(fd_out, "%d\tinstr_in = %b, instr_wr_addr = %d, instr_wr_en = %b\n", $time, instr_in, instr_wr_addr, instr_wr_en);
        end
        $fclose(fd);
        instr_in = 0; instr_wr_addr = 0; instr_wr_en = 0;
        reset = 0;

        for(integer i = 0; i < 300; i++) begin
            @(posedge clk);
            $fwrite(fd_out, "%d, Cycle %0d:\n", $time,i);
            $fwrite(fd_out, "  IF Stage: PC = %d, Instruction = %b\n", dut.pc_IFID, dut.instruction_IFID);
            $fwrite(fd_out, "  ID Stage: PC = %d, Instruction = %b\n", dut.pc_IDEX, dut.instruction_IFID);
            $fwrite(fd_out, "  EX Stage: ALU Result = %b\n", dut.ALU_out_EXMEM);
            $fwrite(fd_out, "  MEM Stage: Memory Data = %b\n", dut.MEM.mem_rd_data);
            $fwrite(fd_out, "  WB Stage: Write Back Data = %b\n", dut.reg_wr_data_WBID);
        end 
        $fclose(fd_out);

        $finish;
    end

endmodule
