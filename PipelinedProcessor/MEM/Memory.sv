`include "inst_defs.sv"

module memory #(
    parameter                   WIDTH=32, SIZE=4096,         //WIDTH is bits per word(shouldn't be changed), SIZE is # of WORDS
    parameter                   NUM_COL   = 4,
    parameter                   COL_WIDTH = 8,
    localparam                  LOGSIZE=$clog2(SIZE)
)(
    input clk, reset,

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

    output logic [`FUNCT_3_RANGE] funct3_MEMWB,     //to be used to shift/mask data loaded from memory
    output logic [1:0] byte_offset_MEMWB,

    // ----------------- ID Stage Signals(Outputs) -----------------
    //enable, data and address
    //output logic [`REG_RANGE] reg_wr_data_WBID,
    output logic [`REG_FIELD_RANGE] rd_MEMWB,
    output logic reg_wr_en_MEMWB
);
    logic [`REG_RANGE] word_addr;
    logic [1:0] byte_offset;

    assign word_addr = ALU_out_EXMEM[31:2];
    assign byte_offset = ALU_out_EXMEM[1:0];

    logic [3:0]        byte_wr_en;
    logic [`REG_RANGE] mem_data_in;
    always_comb begin
        if((funct3_EXMEM == `SW) & (mem_wr_en_EXMEM == 1)) begin
            byte_wr_en = 4'b1111;
            mem_data_in = rs2_data_EXMEM;
        end
        else if((funct3_EXMEM == `SH) & (mem_wr_en_EXMEM == 1)) begin
            byte_wr_en  = byte_offset[1] ? 4'b1100 : 4'b0011;
            mem_data_in = byte_offset[1] ? (rs2_data_EXMEM<<(COL_WIDTH*2)) : rs2_data_EXMEM;
        end
        else if((funct3_EXMEM == `SB) & (mem_wr_en_EXMEM == 1)) begin
            case(byte_offset)
                2'b00: begin 
                    byte_wr_en  = 4'b0001;
                    mem_data_in = rs2_data_EXMEM;
                end
                2'b01: begin
                    byte_wr_en  = 4'b0010;
                    mem_data_in = (rs2_data_EXMEM<<(COL_WIDTH));
                end
                2'b10: begin
                    byte_wr_en  = 4'b0100;
                    mem_data_in = (rs2_data_EXMEM<<(COL_WIDTH*2));
                end
                2'b11: begin
                    byte_wr_en  = 4'b1000;
                    mem_data_in = (rs2_data_EXMEM<<(COL_WIDTH*3));
                end
                default: begin
                    byte_wr_en  = 4'b0000;
                    mem_data_in = 0;
                end
            endcase
        end
        else begin
            byte_wr_en  = 4'b0000;
            mem_data_in = 0;
        end
    end

    //logic [] mem_data_in;


    //logic [WIDTH-1:0] mem_rd_data;
    data_memory #(.WIDTH(WIDTH), .SIZE(SIZE)) data_memory(.clk(clk),
                                                            .data_in(mem_data_in), .word_addr(word_addr), .byte_wr_en(byte_wr_en), .reset(reset),
                                                            .data_out(mem_rd_data_MEMWB));    //replace mem_rd_data with mem_rd_data_MEMWB once sequential read is added

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
            ALU_out_MEMWB <= 0;
            pc_4_MEMWB <= 0;
            //mem_rd_data_MEMWB <= 0;   //this line needs to get deleted once we use sequial read
            reg_wr_ctrl_MEMWB <= 0;
        
            rd_MEMWB <= 0;
            reg_wr_en_MEMWB <= 0;

            funct3_MEMWB <= 0;
            byte_offset_MEMWB <= 0;
        end
        else begin
            ALU_out_MEMWB <= ALU_out_EXMEM;
            pc_4_MEMWB <= pc_4_EXMEM;
            //mem_rd_data_MEMWB <= mem_rd_data;   //this line needs to get deleted once we use sequial read
            reg_wr_ctrl_MEMWB <= reg_wr_ctrl_EXMEM;

            rd_MEMWB <= rd_EXMEM;
            reg_wr_en_MEMWB <= reg_wr_en_EXMEM;

            funct3_MEMWB <= funct3_EXMEM;
            byte_offset_MEMWB <= byte_offset;
        end
    end

endmodule
