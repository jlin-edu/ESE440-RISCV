`include "inst_defs.sv"

module pc_tb ();

    logic [`REG_RANGE] new_pc;
    logic pc_sel, clk, reset;
    logic [`REG_RANGE] out_pc, out_pc_4;

    PC UUT (.jump_addr(new_pc), .pc_sel(pc_sel), .clk(clk), .reset(reset), .pc(out_pc), .pc_4(out_pc_4));

    initial begin 
        clk = 0;
        reset = 0;
		new_pc = 0;
		pc_sel = 0;
    end
	
    initial begin
        $monitor($time,, "pc=%b, reset=%b", out_pc, reset);
        $display("PROGRAM COUNTER TEST");	  
		
        $display("TEST: RESET"); 
		#5 reset = 1; 
        #5 reset = 0;				  
		#5				 
		
		$display("TEST: RUNNING CLOCK");
		for (integer i = 0; i < 4; i += 1) begin
			#5 clk = ~clk;
			#5 clk = ~clk;	 
		end
		#5
		
		$display("TEST: LOADING ADDRESS");
		new_pc = 32'h0000FFFF; 
		pc_sel = 1;
		#5 clk = ~clk;
		#5 clk = ~clk; 
		#5
		
		#5 
        $finish;
    end	  

endmodule