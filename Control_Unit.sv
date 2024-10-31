`include("inst_defs.sv")
// TODO: FIX THIS MESS, MAKE A TABLE TO SEE WHAT VALUES CHANGE WHEN
module control_unit (
    // ----------------- ID stage controls ---------------------------
    input signed [`REG_RANGE] opcode,     
    input logic [`FUNCT_3_RANGE] funct3,              // 3-bit funct3 field
    input logic [`FUNCT_7_RANGE] funct7,        // 7-bit funct7 field  
    output logic registerfile_write_enable,                       // Read enable flag
    output logic pc_rs1_sel,                       // MUX between PC (only used by auipc instruction) and rs1 
    output logic imm_rs2_sel,                       // Immediate source select flag
    
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
    output logic store_ctrl,                       // Store control flag (utilized by the memory to determine what bit range to fill when storing)
    output logic load_ctrl,                       // Load control flag (determines how to mask or to extend the value read from the memory when loading)
    output logic [2:0] reg_write_ctrl,                       // Register write control flag (selects muxes between PC+4(used by JAL or JALR) (1), read data from memory (for loading) (2), and ALU result (0))
    );

    always_comb begin : control_unit_block
        // Default values to avoid latches
        registerfile_write_enable = 0;
        pc_rs1_sel = 0;
        imm_rs2_sel = 0;
        jump_branch_sel = 0;
        mem_write_enable = 0;
        register_write_select = 0;
        store_ctrl = 0;
        load_ctrl = 0;
        reg_write_ctrl = 3'b000;
        byte_enable = 0;
        halfword_enable = 0;
        word_enable = 0;

    // check fo funct7 for multiplications and divisions
        case (opcode)
            `OP_IMM: begin
                registefile_write_enable = 1;
                pc_rs1_sel = pc;
                imm_rs2_sel = 1;
                jump_branch_sel = 0;
                mem_write_enable = 0;
                register_write_select = 1;
                store_ctrl = 0;
                load_ctrl = 0;
                reg_write_ctrl = 3'b000;
            end
            `OP_R3: begin           // Same control signals for all R3 type instructions
                case (funct3)
                pc_rs1_sel = pc;
                    `ADD_SUB: begin
                        registefile_write_enable = 1;
                        imm_rs2_sel = 0;
                        jump_branch_sel = 0;
                        mem_write_enable = 0;
                        register_write_select = 1;
                        store_ctrl = 0;
                        load_ctrl = 0;
                        reg_write_ctrl = 0;
                    end
                    `SLL: begin
                        registefile_write_enable = 1;
                        imm_rs2_sel = 0;
                        jump_branch_sel = 0;
                        mem_write_enable = 0;
                        register_write_select = 1;
                        store_ctrl = 0;
                        load_ctrl = 0;
                        reg_write_ctrl = 0;
                    end
                    `SLT: begin
                        registefile_write_enable = 1;
                        imm_rs2_sel = 0;
                        jump_branch_sel = 0;
                        mem_write_enable = 0;
                        register_write_select = 1;
                        store_ctrl = 0;
                        load_ctrl = 0;
                        reg_write_ctrl = 0;

                    end
                    `SLTU: begin
                        registefile_write_enable = 1;
                        imm_rs2_sel = 0;
                        jump_branch_sel = 0;
                        mem_write_enable = 0;
                        register_write_select = 1;
                        store_ctrl = 0;
                        load_ctrl = 0;
                        reg_write_ctrl = 0;
                    end
                    `XOR: begin
                        registefile_write_enable = 1;
                        imm_rs2_sel = 0;
                        jump_branch_sel = 0;
                        mem_write_enable = 0;
                        register_write_select = 1;
                        store_ctrl = 0;
                        load_ctrl = 0;
                        reg_write_ctrl = 0;
                    end
                    `SRL_SRA: begin
                        registefile_write_enable = 1;
                        imm_rs2_sel = 0;
                        jump_branch_sel = 0;
                        mem_write_enable = 0;
                        register_write_select = 1;
                        store_ctrl = 0;
                        load_ctrl = 0;
                        reg_write_ctrl = 0;
                    end
                    `OR: begin
                        registefile_write_enable = 1;
                        imm_rs2_sel = 0;
                        jump_branch_sel = 0;
                        mem_write_enable = 0;
                        register_write_select = 1;
                        store_ctrl = 0;
                        load_ctrl = 0;
                        reg_write_ctrl = 0;
                    end
                    `AND: begin
                        registefile_write_enable = 1;
                        imm_rs2_sel = 0;
                        jump_branch_sel = 0;
                        mem_write_enable = 0;
                        register_write_select = 1;
                        store_ctrl = 0;
                        load_ctrl = 0;
                        reg_write_ctrl = 0;
                    end
                endcase
            end
            `OP_LD: begin 
                pc_rs1_sel = pc;
            end
            `OP_ST: begin
                pc_rs1_sel = pc;
                registefile_write_enable = 0;
                imm_rs2_sel = 1;
                jump_branch_sel = 0;
                mem_write_enable = 1;
                register_write_select = 0;
                store_ctrl = 1;
                load_ctrl = 0;
                reg_write_ctrl = 2;   
            end
            `OP_BR: begin
                pc_rs1_sel = pc;
                registerfile_write_enable = 0;
                imm_rs2_sel = 0;
                jump_branch_sel = 1;
                mem_write_enable = 0;
                register_write_select = 0;
                store_ctrl = 0;
                load_ctrl = 0;
                reg_write_ctrl = 0;
                pc_rs1_sel = 1;
            end

            `OP_LUI: begin                      
                pc_rs1_sel = pc;
                registerfile_write_enable = 1;
                imm_rs2_sel = 1;
                jump_branch_sel = 0;
                mem_write_enable = 0;
                register_write_select = 1;
                store_ctrl = 0;
                load_ctrl = 0;
                reg_write_ctrl = 0;
            end
            `OP_AUIPC: begin
                pc_rs1_sel = pc;
                registerfile_write_enable = 1;
                imm_rs2_sel = 1;
                jump_branch_sel = 0;
                mem_write_enable = 0;
                register_write_select = 1;
                store_ctrl = 0;
                load_ctrl = 0;
                reg_write_ctrl = 0;
            end

            `OP_JAL: begin              // J-type instruction
                pc_rs1_sel = pc;                  // PC + 4
                registerfile_write_enable = 1;
                imm_rs2_sel = 1;
                jump_branch_sel = 1;
                mem_write_enable = 0;
                register_write_select = 1;
                store_ctrl = 0;
                load_ctrl = 0;
                reg_write_ctrl = 1;
            end

            `OP_JALR: begin             // I-type instruction
                pc_rs1_sel = 1;                  // PC + 4
                registerfile_write_enable = 1;
                imm_rs2_sel = 1;
                jump_branch_sel = 1;
                mem_write_enable = 0;
                register_write_select = 1;
                store_ctrl = 0;
                load_ctrl = 0;
                reg_write_ctrl = 1;
            end
            
        endcase 
    end 

endmodule