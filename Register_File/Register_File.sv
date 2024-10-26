`include "inst_defs.sv"

module RegFile #(
    parameter WIDTH = 32, SIZE = 32
    ) (
    input logic clk, reset, write_enable,
    input logic [`REG_FIELD_RANGE] read_addr1, read_addr2, write_addr,
    input logic [`REG_RANGE] write_data_in,
    output logic [`REG_RANGE] read_data_out1, read_data_out2
    );

    // Memory array
    logic [SIZE-1:1][WIDTH-1:0] RegisterFile;

    // it should take the address and return the data
    always_ff @(posedge clk) begin : Register_File_block
        if (reset) begin                    // Reset state
            RegisterFile <= '{default: '0};
        end else if (write_enable) begin            // Write operation
            if (write_addr != 5'b00000) begin
                RegisterFile[write_addr] <= write_data_in;
            end
        end                             
    end
	
	always_comb begin						 
		if (read_addr1 == 5'b00000) begin  
			read_data_out1 = 32'h00000000;
		end else begin
            read_data_out1 = RegisterFile[read_addr1];	  
		end
		
		if (read_addr2 == 5'b00000) begin
            read_data_out2 = 32'h00000000;		 
		end else begin	 
			read_data_out2 = RegisterFile[read_addr2];	  
		end
	end
    
endmodule