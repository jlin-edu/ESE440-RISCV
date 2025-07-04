`include "inst_defs.sv"

module test_inst_decode_tb();

    logic clk_tb, reset_tb, debug_en_tb;
    logic [`REG_RANGE] instruction_tb, pc_4_tb, data_mem_tb, alu_out_tb;
    logic [`REG_FIELD_RANGE] debug_addr_tb;
    logic [`OP_RANGE] opcode_tb;
    logic [`FUNCT_3_RANGE] funct3_tb;
    logic [`FUNCT_7_RANGE] funct7_tb;
    logic [`REG_RANGE]imm_tb, debug_data_tb;
    logic [4:0] rs1_tb, rs2_tb, rd_tb;

    // Logic signals for control unit
    logic reg_wr_en_tb, pc_rs1_sel_tb, imm_rs2_sel_tb, jump_branch_sel_tb, mem_we_tb;
    logic [1:0] reg_write_ctrl_tb;

    // Logic signals for register file
    // logic [4:0] rs1_temp_tb, rs2_temp_tb, rd_temp_tb;
    logic [`REG_RANGE] read_dataout1_tb, read_dataout2_tb, write_datain_tb;

    // File IO
    int fd, fd_out;	
    logic [31:0] instruction;
    string line;

    inst_decode uut (
        .clk(clk_tb),
        .reset(reset_tb),
        .debug_en(debug_en_tb),
        .instruction(instruction_tb),
        .debug_addr(debug_addr_tb),
        .opcode(opcode_tb),
        .funct3(funct3_tb),
        .funct7(funct7_tb),
        .rs1(rs1_tb),
        .rs2(rs2_tb),
        .rd(rd_tb),
        .imm(imm_tb),
        .debug_data(debug_data_tb),
        .jump_sel(jump_branch_sel_tb),
        .mem_we(mem_we_tb),
        .op1_sel(pc_rs1_sel_tb),
        .op2_sel(imm_rs2_sel_tb),
        .reg_wr_en(reg_wr_en_tb),
        .reg_write_ctrl(reg_write_ctrl_tb),

        .read_addr1(rs1_tb),
        .read_addr2(rs2_tb),
        .write_addr(rd_tb),
        .write_data_in(write_datain_tb),
        .read_data_out1(read_dataout1_tb),
        .read_data_out2(read_dataout2_tb)
    );

    always #5 clk_tb = ~clk_tb;
    
    function string opcodeType(input logic [`OP_RANGE] opcode);
        case (opcode)
            `OP_LUI: return "LUI";
            `OP_AUIPC: return "AUIPC";
            `OP_JAL: return "JAL";
            `OP_JALR: return "JALR";
            `OP_BR: return "BRANCH";
            `OP_LD: return "LOAD";
            `OP_ST: return "STORE";
            `OP_IMM: return "IMMEDIATE";
            `OP_R3: return "R3";
            default: return "UNKNOWN";
        endcase
    endfunction

    initial begin
        //$monitor("%t: instruction=%b, opcode=%b, funct3=%b, funct7=%b, rs1=%b, rs2=%b, imm=%8b %8b %8b %8b\n", $time, instruction_tb, opcode_tb, funct3_tb, funct7_tb, rs1_tb, rs2_tb, imm_tb[31:24], imm_tb[23:16], imm_tb[15:8], imm_tb[7:0]);
        $display("INSTRUCTION DECODE STAGE TEST");

        clk_tb = 0;
        reset_tb = 1;
        debug_en_tb = 0;
        instruction_tb = 0;
        pc_4_tb = 0;
        data_mem_tb = 0;
        alu_out_tb = 0;
        debug_addr_tb = 0;

        #20 reset_tb = 0;

        fd = $fopen("test_instructions.txt", "r");
        fd_out = $fopen("test_instructions_out.txt", "w");
        if (fd == 0) begin 
            $fatal(1, "Error opening file");
        end 
        
        while (!$feof(fd)) begin
            line = "";
            if ($fgets(line, fd)) begin
                // $display("line=%s\n", line);
                if ($sscanf(line, "%32b", instruction) == 1) begin
                    instruction_tb = instruction;
                    #10;
                    $fwrite(fd_out, "\n%t: Type of instruction: %s\n", $time, opcodeType(opcode_tb));
                    // Decoder
                    $fwrite(fd_out, "instruction=%b, opcode=%b, funct3=%b, funct7=%b, rs1=%b, rs2=%b, rd=%b\nimm=%8b %8b %8b %8b\n", 
                        instruction_tb, opcode_tb, funct3_tb, funct7_tb, rs1_tb, rs2_tb, rd_tb, imm_tb[31:24], imm_tb[23:16], imm_tb[15:8], imm_tb[7:0]);
                    // Control unit
                    $fwrite(fd_out, "reg_wr_en=%b, pc_rs1_sel=%b, imm_rs2_sel=%b, jump_branch_sel=%b, mem_we=%b, reg_write_ctrl=%b\n", 
                        reg_wr_en_tb, pc_rs1_sel_tb, imm_rs2_sel_tb, jump_branch_sel_tb, mem_we_tb, reg_write_ctrl_tb);
                    // Register File
                    $fwrite(fd_out, "rs1=%b, rs2=%b, rd=%b, write_data_in=%b, read_data_out1=%b, read_data_out2=%b, ", 
                        rs1_tb, rs2_tb, rd_tb, write_datain_tb, read_dataout1_tb, read_dataout2_tb);
                end
            end
        end
	

        #100 
        $fclose(fd);
        $fclose(fd_out);
        $finish;
         
    end
endmodule