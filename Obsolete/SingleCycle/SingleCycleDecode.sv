`include "inst_defs.sv"

module inst_decoder (
    input [`REG_RANGE] inst,
    output logic [`REG_FIELD_RANGE] rs1, rs2, rd,
    output logic [`OP_RANGE] op,
    output logic [`FUNCT_3_RANGE] funct3,
    output logic [`FUNCT_7_RANGE] funct7,
    output logic [`REG_RANGE] imm
);
    
    always_comb begin
        op     = inst[`OP_FIELD];
        rs1    = inst[`REG_RS1];
        rs2    = inst[`REG_RS2];
        rd     = inst[`REG_RD];
        funct3 = inst[`FUNCT_3_FIELD];
        funct7 = inst[`FUNCT_7_FIELD];

        case (op)
            `OP_LUI:    imm = inst[`IMM_FIELD_U] << 12;
            `OP_AUIPC:  imm = inst[`IMM_FIELD_U] << 12;
            `OP_JAL:    imm = {inst[`IMM_FIELD_J_20], inst[`IMM_FIELD_J_19_12], inst[`IMM_FIELD_J_11], inst[`IMM_FIELD_J_10_1], 1'b0};
            `OP_JALR:   imm = inst[`IMM_FIELD_I];
            `OP_BR:     imm = {inst[`IMM_FIELD_B_12], inst[`IMM_FIELD_B_11], inst[`IMM_FIELD_B_10_5], inst[`IMM_FIELD_B_4_1], 1'b0};
            `OP_LD:     imm = inst[`IMM_FIELD_I];
            `OP_ST:     imm = {inst[`IMM_FIELD_S_U], inst[`IMM_FIELD_S_L]};
            `OP_IMM:    imm = inst[`IMM_FIELD_I];
            default:    imm = 0;
        endcase
    end

endmodule

module RegFile #(
    parameter WIDTH = 32, SIZE = 256
)(
    input logic clk, reset, write_enable,
    input logic [`REG_RANGE] read_addr1, read_addr2, write_addr,
    output logic [`REG_RANGE] write_data_out, read_data_out1, read_data_out2
);

    // Memory array
    logic [SIZE-1:0][WIDTH-1:0] RegisterFile;

    // it should take the address and return the data
    always_comb begin : Register_File_block
        if (reset) begin                    // Reset state
            read_data_out <= 0;
            write_data_out <= 0;
        end
        else if (write_enable) begin            // Write operation
            RegisterFile[write_addr] <= write_data_out;
        end
        else begin                              // Read operation
            read_data_out1 <= RegisterFile[read_addr];
            read_data_out2 <= RegisterFile[read_addr];
        end
    end
    
endmodule

module control_unit(

);

endmodule