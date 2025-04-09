`include "inst_defs.sv"

module memory #(
    parameter                   WIDTH=32, SIZE=256,         //WIDTH is bits per word(shouldn't be changed), SIZE is # of WORDS
    parameter                   NUM_COL   = 4,
    parameter                   COL_WIDTH = 8,
    localparam                  QUARTER_SIZE  = SIZE/4,
    localparam                  LOGSIZE       = $clog2(SIZE),
    localparam                  QUARTER_BITS  = LOGSIZE-2
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
    output logic [1:0] reg_wr_ctrl_MEMWB,
    output logic [`REG_RANGE] ALU_out_MEMWB,
    output logic [`REG_RANGE] pc_4_MEMWB,
    output logic [WIDTH-1:0] mem0_rd_data_MEMWB, //these are output data of the several seperate BRAMs
    output logic [WIDTH-1:0] mem1_rd_data_MEMWB, 
    output logic [WIDTH-1:0] mem2_rd_data_MEMWB,
    output logic [WIDTH-1:0] mem3_rd_data_MEMWB,
    output logic [1:0]       mem_sel_MEMWB,            //passed into WB stage to mux between data read from all 4 memories(only 2)

    output logic [`FUNCT_3_RANGE] funct3_MEMWB,     //to be used to shift/mask data loaded from memory
    output logic [1:0] byte_offset_MEMWB,

    // ----------------- ID Stage Signals(Outputs) -----------------
    //enable, data and address
    //output logic [`REG_RANGE] reg_wr_data_WBID,
    output logic [`REG_FIELD_RANGE] rd_MEMWB,
    output logic reg_wr_en_MEMWB,


    // ---------------- Data Mem B port for AXI/PS use ---------------
    input [WIDTH-1:0]           AXI_dmem_data_in,
    input [(LOGSIZE-1)+2:0]     AXI_dmem_byte_addr,
    input [NUM_COL-1:0]         AXI_dmem_byte_wr_en,

    output logic [WIDTH-1:0] AXI_dmem0_data_out, //these are output data of the several seperate BRAMs
    output logic [WIDTH-1:0] AXI_dmem1_data_out, 
    output logic [WIDTH-1:0] AXI_dmem2_data_out,
    output logic [WIDTH-1:0] AXI_dmem3_data_out
);
    logic [LOGSIZE-1:0] word_addr;
    logic [1:0] byte_offset;

    assign word_addr = ALU_out_EXMEM[(LOGSIZE-1)+2:2];
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

    //addressing should be cut down by a few bits, byte_wr_en needs to be checked with top address bits, AXI port needs the same
    logic [1:0]         mem_sel;    //need to pass tho=rough pipeline to mux in the WB stage
    logic [NUM_COL-1:0] byte_wr_en_mem0, byte_wr_en_mem1, byte_wr_en_mem2, byte_wr_en_mem3;
    logic [(QUARTER_BITS-1):0] quarter_word_addr;

    logic [1:0]         AXI_mem_sel;
    logic [NUM_COL-1:0] AXI_dmem_byte_wr_en_mem0, AXI_dmem_byte_wr_en_mem1, AXI_dmem_byte_wr_en_mem2, AXI_dmem_byte_wr_en_mem3;
    logic [((QUARTER_BITS-1)+2):0] AXI_quarter_byte_addr;

    assign mem_sel           = word_addr[(LOGSIZE-1):(LOGSIZE-1)-1];
    assign byte_wr_en_mem0   = (mem_sel == 2'b00) ? byte_wr_en : 4'b0000;
    assign byte_wr_en_mem1   = (mem_sel == 2'b01) ? byte_wr_en : 4'b0000;
    assign byte_wr_en_mem2   = (mem_sel == 2'b10) ? byte_wr_en : 4'b0000;
    assign byte_wr_en_mem3   = (mem_sel == 2'b11) ? byte_wr_en : 4'b0000;
    assign quarter_word_addr = word_addr[(QUARTER_BITS-1):0];  //remove top 2 bits that are used for memory selection, so we use quarter bits which is LOGSIZE-2

    assign AXI_mem_sel              = AXI_dmem_byte_addr[(LOGSIZE-1)+2:(LOGSIZE-1)+2-1]; //plus 2 because SIZE parameter only takes into account word_address
    assign AXI_dmem_byte_wr_en_mem0 = (AXI_mem_sel == 2'b00) ? AXI_dmem_byte_wr_en : 4'b0000;
    assign AXI_dmem_byte_wr_en_mem1 = (AXI_mem_sel == 2'b01) ? AXI_dmem_byte_wr_en : 4'b0000;
    assign AXI_dmem_byte_wr_en_mem2 = (AXI_mem_sel == 2'b10) ? AXI_dmem_byte_wr_en : 4'b0000;
    assign AXI_dmem_byte_wr_en_mem3 = (AXI_mem_sel == 2'b11) ? AXI_dmem_byte_wr_en : 4'b0000;
    assign AXI_quarter_byte_addr    = AXI_dmem_byte_addr[((QUARTER_BITS-1)+2):0]; //remove top 2 bits that are used for memory selection, so we use quarter bits which is LOGSIZE-2

    //data_memory_0(general use), data_memory_1(matrix_a), data_memory_2(matrix_b), data_memory_3(output_matrix)
    data_memory #(.WIDTH(WIDTH), .SIZE(QUARTER_SIZE), .NUM_COL(NUM_COL), 
                    .COL_WIDTH(COL_WIDTH)) data_mem0(.clk(clk), .data_in(mem_data_in), .word_addr(quarter_word_addr), 
                                                     .byte_wr_en(byte_wr_en_mem0), .reset(reset), .data_out(mem0_rd_data_MEMWB),
                                                     .data_in_B(AXI_dmem_data_in), .data_out_B(AXI_dmem0_data_out), .byte_addr_B(AXI_quarter_byte_addr), .byte_wr_en_B(AXI_dmem_byte_wr_en_mem0));    //replace mem_rd_data with mem_rd_data_MEMWB once sequential read is added

    data_memory #(.WIDTH(WIDTH), .SIZE(QUARTER_SIZE), .NUM_COL(NUM_COL), 
                    .COL_WIDTH(COL_WIDTH)) data_mem1(.clk(clk), .data_in(mem_data_in), .word_addr(quarter_word_addr), 
                                                     .byte_wr_en(byte_wr_en_mem1), .reset(reset), .data_out(mem1_rd_data_MEMWB),  //need new data out signals and add mux for that, in addition the mem_sel signal will need to be sent through pipeline to next stage
                                                     .data_in_B(AXI_dmem_data_in), .data_out_B(AXI_dmem1_data_out), .byte_addr_B(AXI_quarter_byte_addr), .byte_wr_en_B(AXI_dmem_byte_wr_en_mem1)); //same or data_out_B used for the PS                                              

    data_memory #(.WIDTH(WIDTH), .SIZE(QUARTER_SIZE), .NUM_COL(NUM_COL), 
                    .COL_WIDTH(COL_WIDTH)) data_mem2(.clk(clk), .data_in(mem_data_in), .word_addr(quarter_word_addr), 
                                                     .byte_wr_en(byte_wr_en_mem2), .reset(reset), .data_out(mem2_rd_data_MEMWB),  //need new data out signals and add mux for that, in addition the mem_sel signal will need to be sent through pipeline to next stage
                                                     .data_in_B(AXI_dmem_data_in), .data_out_B(AXI_dmem2_data_out), .byte_addr_B(AXI_quarter_byte_addr), .byte_wr_en_B(AXI_dmem_byte_wr_en_mem2)); //same or data_out_B used for the PS 

    data_memory #(.WIDTH(WIDTH), .SIZE(QUARTER_SIZE), .NUM_COL(NUM_COL), 
                    .COL_WIDTH(COL_WIDTH)) data_mem3(.clk(clk), .data_in(mem_data_in), .word_addr(quarter_word_addr), 
                                                     .byte_wr_en(byte_wr_en_mem3), .reset(reset), .data_out(mem3_rd_data_MEMWB),  //need new data out signals and add mux for that, in addition the mem_sel signal will need to be sent through pipeline to next stage
                                                     .data_in_B(AXI_dmem_data_in), .data_out_B(AXI_dmem3_data_out), .byte_addr_B(AXI_quarter_byte_addr), .byte_wr_en_B(AXI_dmem_byte_wr_en_mem3)); //same or data_out_B used for the PS 


    logic [`REG_RANGE] reg_wr_data_WB; 
    always_ff @(posedge clk) begin
        if(reset) begin
            ALU_out_MEMWB <= 0;
            pc_4_MEMWB <= 0;
            reg_wr_ctrl_MEMWB <= 0;
            mem_sel_MEMWB     <= 0;
        
            rd_MEMWB <= 0;
            reg_wr_en_MEMWB <= 0;

            funct3_MEMWB <= 0;
            byte_offset_MEMWB <= 0;
        end
        else begin
            ALU_out_MEMWB <= ALU_out_EXMEM;
            pc_4_MEMWB <= pc_4_EXMEM;
            reg_wr_ctrl_MEMWB <= reg_wr_ctrl_EXMEM;
            mem_sel_MEMWB     <= mem_sel;

            rd_MEMWB <= rd_EXMEM;
            reg_wr_en_MEMWB <= reg_wr_en_EXMEM;

            funct3_MEMWB <= funct3_EXMEM;
            byte_offset_MEMWB <= byte_offset;
        end
    end

endmodule
