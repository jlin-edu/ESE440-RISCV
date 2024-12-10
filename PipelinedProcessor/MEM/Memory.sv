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
    // ----------------- WB Stage Signals(Outputs) -----------------
    output logic [`REG_RANGE] ALU_out_MEMWB,
    output logic [`REG_RANGE] pc_4_MEMWB,
    output logic [WIDTH-1:0] mem_rd_data_MEMWB,
    output logic [1:0] reg_wr_ctrl_MEMWB,

    // ----------------- ID Stage Signals(Outputs) -----------------
    //enable, data and address
    //output logic [`REG_RANGE] reg_wr_data_WBID,
    output logic [`REG_FIELD_RANGE] rd_MEMWB,
    output logic reg_wr_en_MEMWB
);

    logic [WIDTH-1:0] mem_rd_data;
    data_memory #(.WIDTH(WIDTH), .SIZE(SIZE)) data_memory(.clk(clk),
                                                            .data_in(rs2_data_EXMEM), .addr(ALU_out_EXMEM), .wr_en(mem_wr_en_EXMEM), .funct3(funct3_EXMEM),
                                                            .data_out(mem_rd_data));    //replace mem_rd_data with mem_rd_data_MEMWB once sequential read is added

    //Write Back(im feeling lazy so im putting this here, might move later)
    //note that when we chnage the data memory to be a squential read, 
    //logic [`REG_RANGE] reg_wr_data_MEMWB;
    //logic [`REG_FIELD_RANGE] rd_MEMWB;

    //assign rd_WBID = rd_EXMEM;
    //assign reg_wr_en_WBID = reg_wr_en_EXMEM;
    /*
    always_comb begin
        reg_wr_data_WB = 0;
        if(reg_wr_ctrl_EXMEM == 0)
            reg_wr_data_WB = ALU_out_EXMEM;
        else if(reg_wr_ctrl_EXMEM == 1)
            reg_wr_data_WB = pc_4_EXMEM;
        else if(reg_wr_ctrl_EXMEM == 2)
            reg_wr_data_WB = mem_rd_data;
    end
    */

    logic [`REG_RANGE] reg_wr_data_WB; 
    always_ff @(posedge clk) begin
        if(reset) begin

        end
        else begin
            ALU_out_MEMWB <= ALU_out_EXMEM;
            pc_4_MEMWB <= pc_4_EXMEM;
            mem_rd_data_MEMWB <= mem_rd_data;   //this line needs to get deleted once we use sequial read
            reg_wr_ctrl_MEMWB <= reg_wr_ctrl_EXMEM;

            rd_MEMWB <= rd_EXMEM;
            reg_wr_en_MEMWB <= reg_wr_en_EXMEM;
        end
    end

endmodule
