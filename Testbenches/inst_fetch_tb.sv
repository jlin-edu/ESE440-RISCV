`include "inst_defs.sv"

module inst_fetch_tb();

logic [`REG_RANGE] PC_tb, write_data_tb, write_addr_tb, jump_addr_tb;
logic clk_tb, reset_tb, we_tb, pc_sel_tb;
logic [`REG_RANGE] instruction_tb, debug_pc_tb, pc_4_tb, debug_out_tb;

int fd;
string line;

inst_fetch UUT (
    .reset(reset_tb), .pc_sel(pc_sel_tb), .clk(clk_tb), .write_en(we_tb), .debug_en(1'b1), 
    .jump_addr(jump_addr_tb), .debug_pc(debug_pc_tb), .write_addr(write_addr_tb), .write_data(write_data_tb),
    .instruction(instruction_tb), .pc(PC_tb), .pc_4(pc_4_tb), .debug_out(debug_out_tb)
);

initial begin
    clk_tb = 0;
    reset_tb = 0;
    we_tb = 0;
    pc_sel_tb = 0;
    write_addr_tb = 0;
    debug_pc_tb = 0;
    jump_addr_tb = 0;
end

always #5 clk_tb = ~clk_tb;

initial begin
    $monitor("%t\t: PC: %b, Instruction: %b", $time, PC_tb, instruction_tb);
    $display("INSTRUCTION FETCH TEST");	 
	$display("RESET TEST");
	reset_tb = 1; 
	#6 reset_tb = 0;
	$display("READING MEMORY");
	for (int i = 0; i < 1024; i++) begin
        @ (posedge clk_tb);
	end
    
    $display("WRITING TO INSTRUCTION MEMORY....");
    fd = $fopen("test_instructions.txt", "r");
	pc_sel_tb = 1; 
	#6 pc_sel_tb = 0; 
    reset_tb = 1;
    we_tb = 1;
    while (!$feof(fd)) begin
        @ (posedge clk_tb);				 
        $fgets(line, fd);
        $sscanf(line, "%b\n", write_data_tb);  
        write_addr_tb += 4;
    end	
    we_tb = 0;
    reset_tb = 0;
	$fclose(fd);	
	
	$display("READING MEMORY");
    pc_sel_tb = 1; 
    #6 pc_sel_tb = 0;	   
	for (int i = 0; i < 1024; i += 4) begin
		@ (posedge clk_tb);
	end	
    $finish;
end

endmodule
