`include "inst_defs.sv"

module write_back#(
    parameter WIDTH=32
)(
    input [`REG_RANGE] ALU_out_MEMWB,
    input [`REG_RANGE] pc_4_MEMWB,
    input [WIDTH-1:0] mem_rd_data_MEMWB,
    input [1:0] reg_wr_ctrl_MEMWB,

    input [`REG_FIELD_RANGE] rd_MEMWB,
    input reg_wr_en_MEMWB,

    //outputs
    output logic [`REG_RANGE] reg_wr_data_WBID,
    output logic [`REG_FIELD_RANGE] rd_WBID,
    output logic reg_wr_en_WBID
);
    assign rd_WBID = rd_MEMWB;
    assign reg_wr_en_WBID = reg_wr_en_MEMWB;

    always_comb begin
        reg_wr_data_WBID = 0;
        if(reg_wr_ctrl_MEMWB == 0)
            reg_wr_data_WBID = ALU_out_MEMWB;
        else if(reg_wr_ctrl_MEMWB == 1)
            reg_wr_data_WBID = pc_4_MEMWB;
        else if(reg_wr_ctrl_MEMWB == 2)
            reg_wr_data_WBID = mem_rd_data_MEMWB;
    end

endmodule