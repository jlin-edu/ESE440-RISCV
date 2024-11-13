`include "inst_defs.sv"

module inst_decoder (
    input [`REG_RANGE] inst,
    output logic [`REG_RS1] rs1, 
    output logic [`REG_RS2] rs2,
    output logic [`REG_RD] rd,
    output logic [`OP_RANGE] op,
    output logic [`FUNCT_3_RANGE] funct3,
    output logic [`FUNCT_7_RANGE] funct7,
    output logic [`REG_RANGE] imm
);
    always_comb begin
        op     = inst[`OP_FIELD];
        imm = 0;
        
        case (op)
            `OP_R3:    begin
                imm = 32'(0);
                funct7 = inst[`FUNCT_7_FIELD];
                funct3 = inst[`FUNCT_3_FIELD];
                rd     = inst[`REG_RD];
                rs1    = inst[`REG_RS1];
                rs2    = inst[`REG_RS2];
            end
            `OP_LUI:    begin                   // U-type instruction
                imm = 32'(inst[`IMM_FIELD_U] << 12);
                rd     = inst[`REG_RD];
            end 
            `OP_AUIPC:  begin                   // U-type instruction
                imm = 32'(inst[`IMM_FIELD_U] << 12);
                rd     = inst[`REG_RD];
            end 
            `OP_JAL:    begin                   // J-type instruction
                imm = 32'(signed'({inst[`IMM_FIELD_J_20], inst[`IMM_FIELD_J_10_1], inst[`IMM_FIELD_J_11], inst[`IMM_FIELD_J_19_12], 1'b0}));
                rd     = inst[`REG_RD];
            end 
            `OP_JALR:   begin                   // I-type instruction
                imm = 32'(signed'(inst[`IMM_FIELD_I]));
                rd     = inst[`REG_RD];
                rs1    = inst[`REG_RS1];
                funct3 = inst[`FUNCT_3_FIELD];
            end 
            `OP_BR:     begin                   // B-type instruction
                imm    = 32'(signed'({inst[`IMM_FIELD_B_12], inst[`IMM_FIELD_B_12], inst[`IMM_FIELD_B_11], inst[`IMM_FIELD_B_10_5], inst[`IMM_FIELD_B_4_1], 1'b0}));
                rs1    = inst[`REG_RS1];
                rs2    = inst[`REG_RS2];
                funct3 = inst[`FUNCT_3_FIELD];
                rd = 'x;
            end 
            `OP_LD:     begin                   // I-type instruction
                imm = 32'(signed'(inst[`IMM_FIELD_I]));
                rd     = inst[`REG_RD];
                rs1    = inst[`REG_RS1];
                funct3 = inst[`FUNCT_3_FIELD];
            end 
            `OP_ST:     begin                   // S-type instruction
                imm = 32'(signed'({inst[`IMM_FIELD_S_U], inst[`IMM_FIELD_S_L]}));
                rs1    = inst[`REG_RS1];
                rs2    = inst[`REG_RS2];
                funct3 = inst[`FUNCT_3_FIELD];
            end 
            `OP_IMM: begin                      // I-type instruction
                // if (funct3 == `ADDI || funct3 == `SLTI || funct3 == `ANDI || funct3 == `ORI || funct3 == `XORI) begin       // Signed
                    imm = 32'(signed'(inst[`IMM_FIELD_I]));
                    rd     = inst[`REG_RD];
                    rs1    = inst[`REG_RS1];
                    funct3 = inst[`FUNCT_3_FIELD];
                // end 
                // else begin          // Unsigned
                //     imm = 32'(inst[`IMM_FIELD_I]);
                //     rd     = inst[`REG_RD];
                //     rs1    = inst[`REG_RS1];
                //     funct3 = inst[`FUNCT_3_FIELD];
                // end
            end
            default: begin
                imm = 0;
                rd = 'x;
                rs1 = 'x;
                rs2 = 'x;
                funct3 = 'x;
                funct7 = 'x;
            end
        endcase
    end
endmodule
