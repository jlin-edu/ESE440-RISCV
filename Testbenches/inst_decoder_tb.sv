`include "inst_defs.sv"

module inst_decoder_tb ();

    logic [`REG_RANGE] instruction_tb, imm_tb;
    logic [`REG_FIELD_RANGE] rs1_tb, rs2_tb, rd_tb;
    logic [`OP_RANGE] op_tb;
    logic [`FUNCT_3_RANGE] funct3_tb;
    logic [`FUNCT_7_RANGE] funct7_tb;

    int fd;	
	int instruction;
    string line;

    inst_decoder UUT (
        .inst(instruction_tb),
        .rs1(rs1_tb), .rs2(rs2_tb), .rd(rd_tb),
        .op(op_tb), .funct3(funct3_tb), .funct7(funct7_tb),
        .imm(imm_tb)
    );

    initial begin
        $monitor("%t\t: instruction=%b, opcode=%b, funct3=%b, funct7=%b, rs1=%b, rs2=%b, rd=%b, immediate=%b", $time, instruction_tb, op_tb, funct3_tb, funct7_tb, rs1_tb, rs2_tb, rd_tb, imm_tb);
        $display("INTRUCTION DECODER TEST");
        fd = $fopen("test_instructions.txt", "r");
        while(!$feof(fd)) begin
            $fgets(line, fd);
            $sscanf(line, "%b\n", instruction);	   
			#5 instruction_tb = instruction;
        end					  
		$fclose(fd);  
		$finish;
    end

endmodule