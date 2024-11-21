`include "inst_defs.sv"

module memory #(
    parameter                   WIDTH=32, SIZE=256,         //WIDTH is bits per word(shouldn't be changed), SIZE is # of WORDS
    localparam                  LOGSIZE=$clog2(SIZE)
)(
    input clk,

    // ----------------- Inputs to this stage -----------------
    // ----------------- MEM Stage Signals(Inputs) -----------------
    input [`REG_RANGE] ALU_out_EXMEM,          //write&read address
    input [`FUNCT_3_RANGE] funct3_EXMEM,      //shifting&masking load and stores
    input mem_wr_en_EXMEM,                   //write enable
    input [`REG_RANGE] rs2_data_EXMEM,      //write data

    // ----------------- WB Stage Signals(Inputs) -----------------
    input reg_wr_en_EXMEM,
    input [1:0] reg_wr_ctrl_EXMEM,
    input [`REG_FIELD_RANGE] rd_EXMEM,
    input [`REG_RANGE] pc_4_EXMEM,

    // ----------------- Outputs of this stage -----------------
    // ----------------- ID Stage Signals(Outputs) -----------------
    //enable, data and address
    output logic [`REG_RANGE] reg_wr_data_WBID,
    output logic [`REG_FIELD_RANGE] rd_WBID,
    output logic reg_wr_en_WBID
);

    logic [WIDTH-1:0] mem_rd_data;
    data_memory #(.WIDTH(WIDTH), .SIZE(SIZE)) data_memory(.clk(clk),
                                                            .data_in(rs2_data_EXMEM), .addr(ALU_out_EXMEM), .wr_en(mem_wr_en_EXMEM), .funct3(funct3_EXMEM),
                                                            .data_out(mem_rd_data));

    //Write Back(im just putting this here for the single stage version)
    assign rd_WBID = rd_EXMEM;
    assign reg_wr_en_WBID = reg_wr_en_EXMEM;
    always_comb begin
        reg_wr_data_WBID = 0;
        if(reg_wr_ctrl_EXMEM == 0)
            reg_wr_data_WBID = ALU_out_EXMEM;
        else if(reg_wr_ctrl_EXMEM == 1)
            reg_wr_data_WBID = pc_4_EXMEM;
        else if(reg_wr_ctrl_EXMEM == 2)
            reg_wr_data_WBID = mem_rd_data;
    end

endmodule
