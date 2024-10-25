`include "inst_defs.sv"

module register_file_tb ();

logic clk_tb, reset_tb, we_tb;
logic [`REG_FIELD_RANGE] rs1_tb, rs2_tb, rd_tb;
logic [`REG_RANGE] write_data_tb, read_data_1_tb, read_data_2_tb;

RegFile #() UUT(
    .clk(clk_tb), .reset(reset_tb), .write_enable(we_tb),
    .read_addr1(rs1_tb), .read_addr2(rs2_tb), .write_addr(rd_tb),
    .write_data_in(write_data_tb),
    .read_data_out1(read_data_1_tb), .read_data_out2(read_data_2_tb)
);

initial begin
    clk_tb = 0;
    reset_tb = 0;
    we_tb = 0;
    rs1_tb = 0;
    rs2_tb = 0;
    rd_tb = 0;
    write_data_tb = 0;
end

always #5 clk_tb = ~clk_tb;

initial begin
    $display("REGISTER FILE TEST");
    $display("RESET TEST");
    #5 reset_tb = 1;
    #5 reset_tb = 0;
	$display("REGISTERS AFTER RESET");
	for (int i = 0; i < 32; i++) begin 
		#5 rs1_tb = i;	
		$display("Register %d: %b", i, read_data_1_tb);
		#5;
	end		  
	
	$display("WRITE REGISTER TEST - ALSO WRITING TO REG0");
	rd_tb = 2;  
	write_data_tb = 4000000;
	#5 we_tb = 1;
	#5 we_tb = 0; 
	
	rd_tb = 7;  
	write_data_tb = 26794;
	#5 we_tb = 1;
	#5 we_tb = 0;
	
	rd_tb = 25;  
	write_data_tb = 588890;
	#5 we_tb = 1;
	#5 we_tb = 0; 
	
	rd_tb = 0;  
	write_data_tb = 4096;
	#5 we_tb = 1;
	#5 we_tb = 0;
	
	$display("REGISTERS AFTER WRITING");
	for (int i = 0; i < 32; i++) begin 
		#5 rs1_tb = i;	
		$display("Register %d: %b", i, read_data_1_tb);
		#5;
	end
	#10
	$finish;
end

endmodule