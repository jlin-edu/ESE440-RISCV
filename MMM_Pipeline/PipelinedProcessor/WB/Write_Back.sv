`include "inst_defs.sv"

module write_back#(
    parameter WIDTH=32
)(
    input [`REG_RANGE] ALU_out_MEMWB,
    input [`REG_RANGE] pc_4_MEMWB,
    input [WIDTH-1:0] mem_rd_data_MEMWB,
    input [1:0] reg_wr_ctrl_MEMWB,

    input [`FUNCT_3_RANGE] funct3_MEMWB,
    input [1:0] byte_offset_MEMWB,

    input [`REG_FIELD_RANGE] rd_MEMWB,
    input reg_wr_en_MEMWB,

    //outputs
    output logic [`REG_RANGE] reg_wr_data_WBID,
    output logic [`REG_FIELD_RANGE] rd_WBID,
    output logic reg_wr_en_WBID
);
    assign rd_WBID = rd_MEMWB;
    assign reg_wr_en_WBID = reg_wr_en_MEMWB;

    logic [WIDTH-1:0] mem_rd_data_masked;
    always_comb begin
        case(funct3_MEMWB)
            `LW:     mem_rd_data_masked = mem_rd_data_MEMWB;
            `LH:     mem_rd_data_masked = 32'(signed'(mem_rd_data_MEMWB[(8*byte_offset_MEMWB) +: 16]));
            `LB:     mem_rd_data_masked = 32'(signed'(mem_rd_data_MEMWB[(8*byte_offset_MEMWB) +: 8]));
            `LHU:    mem_rd_data_masked = mem_rd_data_MEMWB[(8*byte_offset_MEMWB) +: 16];
            `LBU:    mem_rd_data_masked = mem_rd_data_MEMWB[(8*byte_offset_MEMWB) +: 8];
            default: mem_rd_data_masked = 0;
        endcase
    end

    always_comb begin
        reg_wr_data_WBID = 0;
        if(reg_wr_ctrl_MEMWB == 0)
            reg_wr_data_WBID = ALU_out_MEMWB;
        else if(reg_wr_ctrl_MEMWB == 1)
            reg_wr_data_WBID = pc_4_MEMWB;
        else if(reg_wr_ctrl_MEMWB == 2)
            reg_wr_data_WBID = mem_rd_data_masked;
    end

endmodule