`include "inst_defs.sv"

module hazard_unit(
    input [1:0] reg_wr_ctrl_IDEX,       //Is instruction in EX stage a load instruction?
    input [`REG_FIELD_RANGE] rd_IDEX,   //what register will EX stage instruction load to?

    input [`REG_FIELD_RANGE] rs1_ID, rs2_ID,    //what source registers are we using in ID?
    input pc_rs1_sel, imm_rs2_sel,             //Are these fields of the ID instruction truly register addresses?

    output logic stall
);
    logic memRead, isRS1, isRS2;
    assign memRead = (reg_wr_ctrl_IDEX == 2);
    //assign isRS1  = (pc_rs1_sel == 0);
    //assign isRS2  = (imm_rs2_sel == 0);

    logic rs1Hazard, rs2Hazard;
    assign rs1Hazard = (rs1_ID == rd_IDEX);
    assign rs2Hazard = (rs2_ID == rd_IDEX);

    always_comb begin
        if(memRead & ((rs1Hazard) | (rs2Hazard)))
            stall = 1;
        else
            stall = 0;
    end

endmodule
