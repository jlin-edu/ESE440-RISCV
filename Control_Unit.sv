`include("inst_defs.sv")

module control_unit (
    // ----------------- ID stage controls ---------------------------
    input signed [`REG_RANGE] opcode,     
    input logic [`FUNCT_3_RANGE] funct3,              // 3-bit funct3 field
    input logic [`FUNCT_7_RANGE] funct7,        // 7-bit funct7 field  
    output logic registefile_write_enable,                       // Read enable flag
    output logic pc_rs1_sel,                       // MUX between PC (only used by auipc instruction) and rs1 
    output logic imm_rs2_sel,                       // Immediate source select flag
    output logic sign_extend[2:0],                       // Sign extend flag (3 bits for 4 types of sign extension)
    
    // immediate unit flags -----------------------
    output logic byte_enable,                                // Byte enable flag from the control unit
    output logic halfword_enable,                            // Halfword enable flag from the control unit
    output logic word_enable,                                // Word enable flag from the control unit

    // ----------------- EX stage controls ---------------------------

    // input logic pc_sel,                       // Program counter select flag
    output logic jump_branch_sel,                       // Jump/Branch select flag

    // ----------------- MEM stage controls ---------------------------
    output logic mem_write_enable,                       // Write enable flag
    output logic register_write_select,                      // Register write select flag
    output logic extend_flag,                       // Sign extend flag  
    output logic store_ctrl,                       // Store control flag (utilized by the memory to determine what bit range to fill when storing)
    output logic load_ctrl,                       // Load control flag (determines how to mask or to extend the value read from the memory when loading)
    output logic reg_write_ctrl,                       // Register write control flag (selects muxes between PC+4(used by JAL or JALR), read data from memory (for loading), and ALU result)
    );

    always_comb begin : control_unit_block
        // Default values to avoid latches
        registerfile_write_enable = 0;
        pc_rs1_sel = 0;
        imm_rs2_sel = 0;
        sign_extend = 3'b000;
        jump_branch_sel = 0;
        mem_write_enable = 0;
        register_write_select = 0;
        extend_flag = 0;
        store_ctrl = 0;
        load_ctrl = 0;
        reg_write_ctrl = 0;
        byte_enable = 0;
        halfword_enable = 0;
        word_enable = 0;

    // check fo funct7 for multiplications and divisions
        case (opcode)
            `OP_IMM: begin
                registefile_write_enable = 1;
                pc_rs1_sel = pc_4;
                imm_rs2_sel = 1;
                jump_branch_sel = 0;
                mem_write_enable = 0;
                register_write_select = 1;
                extend_flag = 1;
                store_ctrl = 0;
                load_ctrl = 0;
                reg_write_ctrl = 1;
                case (funct3)      
                    `ADDI: begin
                        sign_extend = 3'b001;
                    end
                    `SLTI: begin            
                        sign_extend = 3'b001;
                    end
                    `SLTIU: begin               // Needs to be zero extended
                        sign_extend = 3'b001;
                    end
                    `XORI: begin
                        sign_extend = 3'b001;
                    end
                    `ORI: begin;
                        sign_extend = 3'b001;
                    end
                    `ANDI: begin
                        sign_extend = 3'b001;
                    end
                    `SLLI: begin
                        sign_extend = 3'b001;
                    end
                    `SRLI_SRAI: begin           // SRAI is msb extended
                        sign_extend = 3'b001;
                    end
                endcase
            end
            `OP_R3: begin
                case (funct3)
                pc_rs1_sel = pc_4;
                    `ADD_SUB: begin
                        registefile_write_enable = 1;
                        imm_rs2_sel = 0;
                        sign_extend = 3'b000;
                        jump_branch_sel = 0;
                        mem_write_enable = 0;
                        register_write_select = 1;
                        extend_flag = 0;
                        store_ctrl = 0;
                        load_ctrl = 0;
                        reg_write_ctrl = 0;
                    end
                    `SLL: begin

                    end
                    `SLT: begin

                    end
                    `SLTU: begin

                    end
                    `XOR: begin

                    end
                    `SRL_SRA: begin

                    end
                    `OR: begin

                    end
                    `AND: begin

                    end
                endcase
            end
            `OP_LD: begin 
                pc_rs1_sel = pc_4;
                case(funct3)

                    `LB: begin
                        byte_enable = 1;
                    end
                    `LH: begin
                        halfword_enable = 1;
                    end
                    `LW: begin
                        word_enable = 1;
                    end
                    `LBU: begin
                        byte_enable = 1;
                    end

            end
            `OP_ST: begin
                pc_rs1_sel = pc_4;
                case(funct3)
                    `SB: begin
                        
                    end
                    `SH: begin
                        
                    end
                    `SW: begin
                        
                    end

            end
            `OP_BR: begin
                registerfile_write_enable = 0;
                pc_rs1_sel = 0;
                imm_rs2_sel = 0;
                sign_extend = 3'b001;
                jump_branch_sel = 1;
                mem_write_enable = 0;
                register_write_select = 0;
                extend_flag = 1;
                store_ctrl = 0;
                load_ctrl = 0;
                reg_write_ctrl = 0;
                case(funct3)
                    `BEQ: begin
                        
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
                endcase
            end

            `OP_LUI: begin

            end
            `OP_AUIPC: begin

            end

            `OP_JAL: begin

            end

            `OP_JALR: begin

            end
            
        endcase 
    end 

endmodule