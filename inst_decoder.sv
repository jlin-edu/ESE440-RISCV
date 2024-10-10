`include "inst_defs.sv"

module inst_decoder (
    input [`REG_RANGE] pc,
    output logic [`REG_FIELD_RANGE] rs1, rs2, rd,
    output logic [`OP_RANGE] op,
    output logic [`FUNCT_3_RANGE] funct3,
    output logic [`FUNCT_7_RANGE] funct7,
    output logic [`REG_RANGE] imm
);
    
    always_comb begin
        op     = pc[`OP_FIELD];
        rs1    = pc[`REG_RS1];
        rs2    = pc[`REG_RS2];
        rd     = pc[`REG_RD];
        funct3 = pc[`FUNCT_3_FIELD];
        funct7 = pc[`FUNCT_7_FIELD];

        case (op)
            `OP_LUI:    imm = pc[`IMM_FIELD_U];
            `OP_AUIPC:  imm = pc[`IMM_FIELD_U];
            `OP_JAL:    imm = {pc[`IMM_FIELD_J_20], pc[`IMM_FIELD_J_19_12], pc[`IMM_FIELD_J_11], pc[`IMM_FIELD_J_10_1], 1'b0};
            `OP_JALR:   imm = pc[`IMM_FIELD_I];
            `OP_BR:     imm = {pc[`IMM_FIELD_B_12], pc[`IMM_FIELD_B_11], pc[`IMM_FIELD_B_10_5], pc[`IMM_FIELD_B_4_1], 1'b0};
            `OP_LD:     imm = pc[`IMM_FIELD_I];
            `OP_ST:     imm = {pc[`IMM_FIELD_S_U], pc[`IMM_FIELD_S_L]};
            `OP_IMM:    imm = pc[`IMM_FIELD_I];
            default:    imm = 0;
        endcase

    end

endmodule