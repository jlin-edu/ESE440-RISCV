`include "inst_defs.sv"

module inst_memory_tb();

logic [`REG_RANGE] PC_tb, write_data_tb, write_addr_tb;
logic clk_tb, reset_tb, we_tb;
logic [`REG_RANGE] data_out_tb;

int fd;
string line;

InstructionMem #() UUT (
    .PC(PC_tb), .write_data(write_data_tb), .write_addr(write_addr_tb),
    .clk(clk_tb), .reset(reset_tb), .write_enable(we_tb),
    .data_out(data_out_tb)
);

initial begin
    clk_tb = 0;
    reset_tb = 0;
    we_tb = 0;
    write_addr_tb = 0;
    PC_tb = 0;
end

always #5 clk_tb = ~clk_tb;

initial begin
    $monitor("%t\t: PC: %b, Instruction: %b", $time, PC_tb, data_out_tb);
    $display("INSTRUCTION MEMORY TEST");	 
	#1;
	$display("RESET TEST");
	reset_tb = 1;
	#5 reset_tb = 0;
	$display("READING MEMORY");
	for (int i = 0; i < 256; i++) begin
		#10 PC_tb = i;
	end	
	#5;
    $display("WRITING TO INSTRUCTION MEMORY....");
    fd = $fopen("test_instructions.txt", "r");
    while (!$feof(fd)) begin
        $fgets(line, fd);
        $sscanf(line, "%b\n", write_data_tb);
        we_tb = 1;
        #5 we_tb = 0;
        write_addr_tb++;
        #5;
    end	  
	$display("READING MEMORY");
	for (int i = 0; i < 256; i++) begin
		#10 PC_tb = i;
	end	
    $fclose(fd);
    $finish;
end

endmodule