`include("inst_defs.sv")

module control_unit (
    // ----------------- ID stage controls ---------------------------
    input [`REG_RANGE] opcode,     
    input logic [`FUNCT_3_RANGE] funct3,              // 3-bit funct3 field
    input logic [`FUNCT_7_RANGE] funct7,        // 7-bit funct7 field  
    output logic reg_wr_en,                       // Register file write enable flag
    output logic pc_rs1_sel,                       // 0 rs1, 1 for pc
    output logic imm_rs2_sel,                       // 0 for rs2, 1 for imm
    // ----------------- EX stage controls ---------------------------
    output logic jump_branch_sel,                       // 0 for ALU, 1 for sum of pc and imm

    // ----------------- MEM stage controls ---------------------------
    output logic mem_wr_en,                       // Write enable flag
    // ----------------- WB stage controls ---------------------------
    output logic [2:0] reg_write_ctrl                       // 0 for ALU output, 1 is for pc+4, 2 is for memory
    );

    always_comb begin : control_unit_block
        // Default values to avoid latches
        registerfile_write_enable = 0;
        pc_rs1_sel = 0;
        imm_rs2_sel = 0;
        jump_branch_sel = 0;
        mem_wr_en = 0;
        reg_write_ctrl = 0;

    // check fo funct7 for multiplications and divisions
        case (opcode)
            `OP_IMM: begin
                reg_wr_en = 1;
                imm_rs2_sel = 1;
                jump_branch_sel = 0;
                mem_wr_en = 0;
                reg_write_ctrl = 1;
                case (funct3)      
                    `ADDI: begin
                     
                    end
                    `SLTI: begin            
                     
                    end
                    `SLTIU: begin               // Needs to be zero extended
                        
                    end
                    `XORI: begin
                      
                    end
                    `ORI: begin;
                        
                    end
                    `ANDI: begin
                       
                    end
                    `SLLI: begin
                        
                    end
                    `SRLI_SRAI: begin           // SRAI is msb extended
                    
                    end
                endcase
            end
            `OP_R3: begin           // Same control signals for all R3 type instructions
                case (funct3)
                pc_rs1_sel = pc;
                    `ADD_SUB: begin
                        reg_wr_en = 1;
                        imm_rs2_sel = 0;
                        jump_branch_sel = 0;
                        mem_wr_en = 0;
                        register_write_select = 1;
                        reg_write_ctrl = 0;
                    end
                    `SLL: begin
                        reg_wr_en = 1;
                        imm_rs2_sel = 0;
                        jump_branch_sel = 0;
                        mem_wr_en = 0;
                        register_write_select = 1;
                        reg_write_ctrl = 0;
                    end
                    `SLT: begin
                        reg_wr_en = 1;
                        imm_rs2_sel = 0;
                        jump_branch_sel = 0;
                        mem_wr_en = 0;
                        register_write_select = 1;
                        reg_write_ctrl = 0;

                    end
                    `SLTU: begin
                        reg_wr_en = 1;
                        imm_rs2_sel = 0;
                        jump_branch_sel = 0;
                        mem_wr_en = 0;
                        register_write_select = 1;
                        reg_write_ctrl = 0;
                    end
                    `XOR: begin
                        reg_wr_en = 1;
                        imm_rs2_sel = 0;
                        jump_branch_sel = 0;
                        mem_wr_en = 0;
                        register_write_select = 1;
                        reg_write_ctrl = 0;
                    end
                    `SRL_SRA: begin
                        reg_wr_en = 1;
                        imm_rs2_sel = 0;
                        jump_branch_sel = 0;
                        mem_wr_en = 0;
                        register_write_select = 1;
                        reg_write_ctrl = 0;
                    end
                    `OR: begin
                        reg_wr_en = 1;
                        imm_rs2_sel = 0;
                        jump_branch_sel = 0;
                        mem_wr_en = 0;
                        register_write_select = 1;
                        reg_write_ctrl = 0;
                    end
                    `AND: begin
                        reg_wr_en = 1;
                        imm_rs2_sel = 0;
                        jump_branch_sel = 0;
                        mem_wr_en = 0;
                        register_write_select = 1;
                        reg_write_ctrl = 0;
                    end
                endcase
            end
            `OP_LD: begin 
                case(funct3)
                    pc_rs1_sel = pc;
                    reg_wr_en = 0;
                    imm_rs2_sel = 1;
                    jump_branch_sel = 0;
                    mem_wr_en = 1;
                    register_write_select = 0;
                    `LB: begin
                    end
                    `LH: begin

                    end
                    `LW: begin

                    end
                    `LBU: begin

                    end
                endcase

            end
            `OP_ST: begin
                case(funct3)
                    pc_rs1_sel = pc;
                    reg_wr_en = 0;
                    imm_rs2_sel = 1;
                    jump_branch_sel = 0;
                    mem_wr_en = 1;
                    reg_write_ctrl = 0;   
                    `SB: begin
                    end
                    `SH: begin

                    end
                    `SW: begin

                    end
                endcase

            end
            `OP_BR: begin
                pc_rs1_sel = pc;
                registerfile_write_enable = 0;
                imm_rs2_sel = 0;
                jump_branch_sel = 1;
                mem_wr_en = 0;
                reg_write_ctrl = 0;
                case(funct3)
                    `BEQ: begin
                        // Branch if rs1 == rs2       
                    end
                    `BNE: begin

                    end
                    `BLT: begin

                    end
                    `BGE: begin

                    end
                    `BLTU: begin

                    end
                    `BGEU: begin

                    end
                    pc_rs1_sel = 1;
                endcase
            end

            `OP_LUI: begin                      
                pc_rs1_sel = pc;
                registerfile_write_enable = 1;
                imm_rs2_sel = 1;
                jump_branch_sel = 0;
                mem_wr_en = 0;
                reg_write_ctrl = 1;
            end
            `OP_AUIPC: begin
                pc_rs1_sel = pc;
                registerfile_write_enable = 1;
                imm_rs2_sel = 1;
                jump_branch_sel = 0;
                mem_wr_en = 0;
                reg_write_ctrl = 1;
            end

            `OP_JAL: begin              // J-type instruction
                pc_rs1_sel = pc;                  
                registerfile_write_enable = 1;
                imm_rs2_sel = 1;
                jump_branch_sel = 1;
                mem_wr_en = 0;
                reg_write_ctrl = 1;
            end

            `OP_JALR: begin             // I-type instruction
                pc_rs1_sel = 1;                  
                registerfile_write_enable = 1;
                imm_rs2_sel = 1;
                jump_branch_sel = 1;
                mem_wr_en = 0;
                reg_write_ctrl = 1;
            end
            
        endcase 
    end 

endmodule