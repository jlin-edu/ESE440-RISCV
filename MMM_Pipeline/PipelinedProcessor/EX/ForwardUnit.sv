`include "inst_defs.sv"

module ForwardUnit(
    input [`REG_FIELD_RANGE] rs1_IDEX, rs2_IDEX,

    //EXMEM Pipeline Reg
    //input signed [`REG_RANGE] ALU_out_EXMEM,
    input [`REG_FIELD_RANGE] rd_EXMEM,
    input reg_wr_en_EXMEM,


    //MEMWB Pipeline Reg
    //input signed [`REG_RANGE] reg_wr_data_WBID,
    input [`REG_FIELD_RANGE] rd_WBID,
    input reg_wr_en_WBID,

    output logic [1:0] in1_sel, in2_sel     //00 means don't forward, 01 means forward MEMWB stage data, 10 means forward EXMEM data
);
    always_comb begin
        in1_sel = 2'b00;
        in2_sel = 2'b00;

        if((reg_wr_en_EXMEM == 1) && (rs1_IDEX == rd_EXMEM) && (rd_EXMEM != 0))
            in1_sel = 2'b10;
        else if((reg_wr_en_WBID == 1) && (rs1_IDEX == rd_WBID) && (rd_WBID != 0))
            in1_sel = 2'b01;

        if((reg_wr_en_EXMEM == 1) && (rs2_IDEX == rd_EXMEM) && (rd_EXMEM != 0))
            in2_sel = 2'b10;
        else if((reg_wr_en_WBID == 1) && (rs2_IDEX == rd_WBID) && (rd_WBID != 0))
            in2_sel = 2'b01;

    end


endmodule