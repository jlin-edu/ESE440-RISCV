`include "inst_defs.sv"

module control_unit (
    // ----------------- ID stage controls ---------------------------
    input [`OP_RANGE] opcode,     
    //input logic [`FUNCT_3_RANGE] funct3,              // 3-bit funct3 field
    //input logic [`FUNCT_7_RANGE] funct7,        // 7-bit funct7 field  
    output logic reg_wr_en,                       // Register file write enable flag
    output logic pc_rs1_sel,                       // 0 rs1, 1 for pc
    output logic imm_rs2_sel,                       // 0 for rs2, 1 for imm
    // ----------------- EX stage controls ---------------------------
    output logic jump_branch_sel,                       // 0 for ALU, 1 for sum of pc and imm

    // ----------------- MEM stage controls ---------------------------
    output logic mem_wr_en,                       // Write enable flag
    output logic start_mmm,
    output logic wait_mmm_finish,

    // ----------------- WB stage controls ---------------------------
    output logic [1:0] reg_write_ctrl                       // 0 for ALU output, 1 is for pc+4, 2 is for memory
    );

    always_comb begin
        // Default values to avoid latches
        reg_wr_en = 0;
        pc_rs1_sel = 0;
        imm_rs2_sel = 0;
        jump_branch_sel = 0;
        mem_wr_en = 0;
        reg_write_ctrl = 0;
        start_mmm       = 0;
        wait_mmm_finish = 0;

    // check fo funct7 for multiplications and divisions
        case (opcode)
            `OP_IMM: begin         // I-type instruction    
                reg_wr_en = 1;
                //pc_rs1_sel = 0;
                imm_rs2_sel = 1;
                //jump_branch_sel = 0;
                //mem_wr_en = 0;
                //reg_write_ctrl = 0;
            end
            `OP_R3: begin         // R-type instruction
                // pc_rs1_sel = 0;
                reg_wr_en = 1;
                // imm_rs2_sel = 0;
                // jump_branch_sel = 0;
                // mem_wr_en = 0;
                // reg_write_ctrl = 0;

            end
            `OP_LD: begin               // I-type instruction
                // pc_rs1_sel = 0;
                reg_wr_en = 1;
                imm_rs2_sel = 1;
                // jump_branch_sel = 0;
                // mem_wr_en = 0;
                reg_write_ctrl = 2;

            end
            `OP_ST: begin               // S-type instruction
                // pc_rs1_sel = 0;
                // reg_wr_en = 0;
                imm_rs2_sel = 1;
                // jump_branch_sel = 0;
                mem_wr_en = 1;
                // reg_write_ctrl = 0;   

            end
            `OP_BR: begin               // B-type instruction
                pc_rs1_sel = 0;
                // reg_wr_en = 0;
                imm_rs2_sel = 0;
                jump_branch_sel = 1;
                // mem_wr_en = 0;
                // reg_write_ctrl = 0;
            end

            `OP_LUI: begin                                // U-type instruction
                // pc_rs1_sel = 0;
                reg_wr_en = 1;
                imm_rs2_sel = 1;
                // jump_branch_sel = 0;
                // mem_wr_en = 0;
                //reg_write_ctrl = 0;
            end

            `OP_AUIPC: begin                // U-type instruction
                pc_rs1_sel = 1;
                reg_wr_en = 1;
                imm_rs2_sel = 1;
                // jump_branch_sel = 0;
                // mem_wr_en = 0;
                //reg_write_ctrl = 0;
            end

            `OP_JAL: begin              // J-type instruction
                pc_rs1_sel = 1;                  
                reg_wr_en = 1;
                imm_rs2_sel = 1;
                //jump_branch_sel = 0;
                // mem_wr_en = 0;
                reg_write_ctrl = 1;
            end

            `OP_JALR: begin             // I-type instruction
                // pc_rs1_sel = 0;                  
                reg_wr_en = 1;
                imm_rs2_sel = 1;
                //jump_branch_sel = 0;
                // mem_wr_en = 0;
                reg_write_ctrl = 1;
            end

            //doesn't use the ALU at all, just pass rs2_data & start_mmm to mem stage
            //opcode is formatted [ *filler* [24:20(rs2)] *filler* [6:0(opcode)]]
            `OP_MMMSTART: begin
                // pc_rs1_sel = 0;
                // reg_wr_en = 0;
                //imm_rs2_sel = 0;
                // jump_branch_sel = 0;
                //mem_wr_en = 1;
                // reg_write_ctrl = 0;
                start_mmm = 1;
            end

            `OP_MMMWAIT: begin
                //reg_write_ctrl  = 2;    //since MMM operation can be considered a store instr, we use this for hazard detection to insert
                wait_mmm_finish = 1;
            end
            
        endcase 
    end 

endmodule
