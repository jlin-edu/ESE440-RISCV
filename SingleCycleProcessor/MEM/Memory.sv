`include "inst_defs.sv"

module Execute #(

)(
    input clk, reset,

    // ----------------- Inputs to this stage -----------------
    // ----------------- MEM Stage Signals(Inputs) -----------------
    input [`REG_RANGE] ALU_out_EXMEM,          //write&read address
    input [`FUNCT_3_RANGE] funct3_EXMEM,      //shifting&masking load and stores
    input mem_wr_en_EXMEM,                   //write enable
    input [`REG_RANGE] rs2_data_EXMEM,      //write data

    // ----------------- WB Stage Signals(Inputs) -----------------

);

endmodule