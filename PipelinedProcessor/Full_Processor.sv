`include "inst_defs.sv"

module pipelined_processor #(
    parameter                   WIDTH=32, SIZE=64,         //WIDTH is bits per word(shouldn't be changed), SIZE is # of WORDS
    parameter                   NUM_COL   = 4,
    parameter                   COL_WIDTH = 8,
    localparam                  LOGSIZE=$clog2(SIZE)
)(
    //instruction memory write port
    //input [WIDTH-1:0]           instr_in,       //the write port should only be used for filling the memory with instructions in a testbench
    //input [(LOGSIZE-1)+2:0]     instr_wr_addr, 
    //input [NUM_COL-1:0]         instr_wr_en,
    //output logic [WIDTH-1:0]    instruction_IFID,

    //Single BRAM Port for both instr and data
    input [WIDTH-1:0]           bram_din,       //the write port should only be used for filling the memory with instructions in a testbench
    input [(LOGSIZE)+2:0]       shared_bram_addr, 
    input [NUM_COL-1:0]         bram_wr_en,
    output logic [WIDTH-1:0]    bram_dout,

    //y'know
    input clk_in, reset,
    output logic halt_reg
    //output logic signed [`REG_RANGE] processor_out

    // Data Mem B port for AXI/PS use
    //input [WIDTH-1:0]           AXI_dmem_data_in,
    //output logic [WIDTH-1:0]    AXI_dmem_data_out,
    //input [LOGSIZE-1:0]         AXI_dmem_word_addr,
    //input [NUM_COL-1:0]         AXI_dmem_byte_wr_en
);

    logic clk; // Main clk derived from clk_in

    // --------------- Instruction Fetch Signals ---------------
    // ---------- Inputs ----------
    // ----- EX Stage Signals -----
    logic [`REG_RANGE] jump_addr_EXIF;   //IF Input(Provided by EX Stage Mux)
    logic pc_sel_EXIF;                   //IF Input(Provided by EX Stage ALU)

    // ---------- Outputs ----------
    // ----- ID Stage Signals -----
    logic [`REG_RANGE] pc_IFID, pc_4_IFID, instruction_IFID;    //IF Outputs(ID uses instruction, EX uses PC, WB uses PC+4)



    // --------------- Instruction Decode Signals ---------------
    // ---------- Inputs ----------
    // ----- WB Stage Signals -----
    logic [`REG_RANGE] reg_wr_data_WBID;
    logic [`REG_FIELD_RANGE] rd_WBID;
    logic reg_wr_en_WBID;


    // ---------- Outputs ----------
    // ----- EX Stage Signals(Outputs) -----
    logic [`OP_RANGE] op_IDEX;               //used by ALU to determine what operation to do
    logic [`FUNCT_7_RANGE] funct7_IDEX;      //used by ALU to determine what operation to do
    logic [`FUNCT_3_RANGE] funct3_IDEX;      //used by ALU, but also by the Data MEM to know which load/store operation
    logic [`REG_RANGE] rs1_data_IDEX;             //used by ALU to perform an operation and get an output

    logic signed [`REG_RANGE] immediate_IDEX;       //used by branch adder to determine branch address
    logic [`REG_RANGE] pc_IDEX;              //used by branch adder to determine branch address
    logic jump_branch_sel_IDEX;              //used by branch adder to determine whether to use branch address or jump address

    logic halt_IDEX;

    // ----------------- MEM Stage Signals -----------------
    logic mem_wr_en_IDEX;                //This signal connects directly to the memory
    logic [`REG_RANGE] rs2_data_IDEX;

    // ----------------- WB Stage Signals -----------------
    logic reg_wr_en_IDEX;                //the rest of these signals are used for Write Back
    logic [1:0] reg_wr_ctrl_IDEX;
    logic [`REG_FIELD_RANGE] rd_IDEX;
    logic [`REG_RANGE] pc_4_IDEX;

    // ----------------- Forwarding Signals -----------------
    logic [`REG_FIELD_RANGE] rs1_IDEX, rs2_IDEX;
    logic pc_rs1_sel_IDEX, imm_rs2_sel_IDEX;

    logic stall, div_stall;


    // --------------- Execute Signals ---------------
    // ----------------- Outputs of this stage -----------------
    // ----------------- MEM Stage Signals(Outputs) -----------------
    logic signed [`REG_RANGE] ALU_out_EXMEM;   //wait does the ALU_out need to be signed???   //these are from the ALU
    logic [`FUNCT_3_RANGE] funct3_EXMEM;
    logic mem_wr_en_EXMEM;
    logic [`REG_RANGE] rs2_data_EXMEM;

    logic reg_wr_en_EXMEM;
    logic [1:0] reg_wr_ctrl_EXMEM;
    logic [`REG_FIELD_RANGE] rd_EXMEM;
    logic [`REG_RANGE] pc_4_EXMEM;

    logic [WIDTH-1:0] dmem_dout;

    logic halt_EXMEM;
    
    // ----------------- WB Stage Signals(Outputs) -----------------
    logic [`REG_RANGE] ALU_out_MEMWB;
    logic [`REG_RANGE] pc_4_MEMWB;
    logic [WIDTH-1:0] mem_rd_data_MEMWB;
    logic [1:0] reg_wr_ctrl_MEMWB;

    logic [`FUNCT_3_RANGE] funct3_MEMWB;
    logic [1:0] byte_offset_MEMWB;

    logic [`REG_FIELD_RANGE] rd_MEMWB;
    logic reg_wr_en_MEMWB;



    logic [(LOGSIZE-1)+2:0] block_wr_addr;
    assign block_wr_addr = shared_bram_addr[(LOGSIZE-1)+2:0];

    logic [NUM_COL-1:0] instr_wr_en;
    assign instr_wr_en = {4{~shared_bram_addr[(LOGSIZE)+2]}} & bram_wr_en;    //instruction mem is BRAM0

    logic halt_MEMWB;

    logic halt;

    instruction_fetch #(.WIDTH(WIDTH), .SIZE(SIZE), .NUM_COL(NUM_COL)) IF(.clk(clk), .reset(reset), .clk_in(clk_in),
                                                        .jump_addr_EXIF(jump_addr_EXIF), .pc_sel_EXIF(pc_sel_EXIF),
                                                        .pc_IFID(pc_IFID), .pc_4_IFID(pc_4_IFID), .instruction_IFID(instruction_IFID),
                                                        .instr_in(bram_din), .wr_addr(block_wr_addr), .wr_en(instr_wr_en),
                                                        .stall(stall | div_stall));

    //pipeline register here
    //instruction, pc, pc+4

    instruction_decode #(.WIDTH(WIDTH)) ID(.clk(clk), .reset(reset),
                                            .instruction_IFID(instruction_IFID), .pc_IFID(pc_IFID), .pc_4_IFID(pc_4_IFID),
                                            .reg_wr_data_WBID(reg_wr_data_WBID), .rd_WBID(rd_WBID), .reg_wr_en_WBID(reg_wr_en_WBID),
                                            .op_IDEX(op_IDEX), .funct7_IDEX(funct7_IDEX), .funct3_IDEX(funct3_IDEX), .rs1_data_IDEX(rs1_data_IDEX),
                                            .immediate_IDEX(immediate_IDEX), .pc_IDEX(pc_IDEX), .jump_branch_sel_IDEX(jump_branch_sel_IDEX),
                                            .mem_wr_en_IDEX(mem_wr_en_IDEX), .rs2_data_IDEX(rs2_data_IDEX),
                                            .reg_wr_en_IDEX(reg_wr_en_IDEX), .reg_wr_ctrl_IDEX(reg_wr_ctrl_IDEX), .rd_IDEX(rd_IDEX), .pc_4_IDEX(pc_4_IDEX),
                                            .pc_sel_EXIF(pc_sel_EXIF),
                                            .rs1_IDEX(rs1_IDEX), .rs2_IDEX(rs2_IDEX),
                                            .pc_rs1_sel_IDEX(pc_rs1_sel_IDEX), .imm_rs2_sel_IDEX(imm_rs2_sel_IDEX),
                                            .stall(stall), .div_stall(div_stall), .halt_EX(halt_IDEX));

    //pipeline register here
    //

    execute EX( .clk(clk), .reset(reset),
                .rs1_data_IDEX(rs1_data_IDEX), .funct7_IDEX(funct7_IDEX), .funct3_IDEX(funct3_IDEX), .op_IDEX(op_IDEX),
                .immediate_IDEX(immediate_IDEX), .pc_IDEX(pc_IDEX), .jump_branch_sel_IDEX(jump_branch_sel_IDEX),
                .mem_wr_en_IDEX(mem_wr_en_IDEX), .rs2_data_IDEX(rs2_data_IDEX),
                .reg_wr_en_IDEX(reg_wr_en_IDEX), .reg_wr_ctrl_IDEX(reg_wr_ctrl_IDEX), .rd_IDEX(rd_IDEX), .pc_4_IDEX(pc_4_IDEX),
                .ALU_out_EXMEM(ALU_out_EXMEM), .funct3_EXMEM(funct3_EXMEM), .mem_wr_en_EXMEM(mem_wr_en_EXMEM), .rs2_data_EXMEM(rs2_data_EXMEM),
                .reg_wr_en_EXMEM(reg_wr_en_EXMEM), .reg_wr_ctrl_EXMEM(reg_wr_ctrl_EXMEM), .rd_EXMEM(rd_EXMEM), .pc_4_EXMEM(pc_4_EXMEM),
                .pc_sel_EXIF(pc_sel_EXIF), .jump_addr_EXIF(jump_addr_EXIF),
                .rs1_IDEX(rs1_IDEX), .rs2_IDEX(rs2_IDEX),
                .pc_rs1_sel_IDEX(pc_rs1_sel_IDEX), .imm_rs2_sel_IDEX(imm_rs2_sel_IDEX),
                .reg_wr_data_WBID(reg_wr_data_WBID), .rd_WBID(rd_WBID), .reg_wr_en_WBID(reg_wr_en_WBID), .div_stall(div_stall),
                .halt_ID(halt_IDEX), .halt_MEM(halt_EXMEM));


    logic [NUM_COL-1:0] data_wr_en;
    assign data_wr_en = {4{shared_bram_addr[(LOGSIZE)+2]}} & bram_wr_en;    //instruction mem is BRAM0
    memory #(.WIDTH(WIDTH), .SIZE(SIZE), .NUM_COL(NUM_COL), .COL_WIDTH(COL_WIDTH)) 
                                        MEM(.clk(clk), .reset(reset), .clk_in(clk_in),
                                            .ALU_out_EXMEM(ALU_out_EXMEM), .funct3_EXMEM(funct3_EXMEM), .mem_wr_en_EXMEM(mem_wr_en_EXMEM), .rs2_data_EXMEM(rs2_data_EXMEM),
                                            .reg_wr_en_EXMEM(reg_wr_en_EXMEM), .reg_wr_ctrl_EXMEM(reg_wr_ctrl_EXMEM), .rd_EXMEM(rd_EXMEM), .pc_4_EXMEM(pc_4_EXMEM),
                                            .rd_MEMWB(rd_MEMWB), .reg_wr_en_MEMWB(reg_wr_en_MEMWB),
                                            .ALU_out_MEMWB(ALU_out_MEMWB), .pc_4_MEMWB(pc_4_MEMWB), .mem_rd_data_MEMWB(mem_rd_data_MEMWB), .reg_wr_ctrl_MEMWB(reg_wr_ctrl_MEMWB),
                                            .funct3_MEMWB(funct3_MEMWB), .byte_offset_MEMWB(byte_offset_MEMWB),
                                            .AXI_dmem_data_in(bram_din), .AXI_dmem_data_out(dmem_dout), .AXI_dmem_word_addr(block_wr_addr), .AXI_dmem_byte_wr_en(data_wr_en),
                                            .halt_EX(halt_EXMEM), .halt_WB(halt_MEMWB));    

    write_back #(.WIDTH(WIDTH)) WB(.ALU_out_MEMWB(ALU_out_MEMWB), .pc_4_MEMWB(pc_4_MEMWB), .mem_rd_data_MEMWB(mem_rd_data_MEMWB), .reg_wr_ctrl_MEMWB(reg_wr_ctrl_MEMWB),
                .rd_MEMWB(rd_MEMWB), .reg_wr_en_MEMWB(reg_wr_en_MEMWB),
                .reg_wr_data_WBID(reg_wr_data_WBID), .rd_WBID(rd_WBID), .reg_wr_en_WBID(reg_wr_en_WBID),
                .funct3_MEMWB(funct3_MEMWB), .byte_offset_MEMWB(byte_offset_MEMWB),
                .halt_MEM(halt_MEMWB), .halt_WB(halt));
    
    //assign processor_out = ALU_out_EXMEM;
    logic bram_sel;
    always_ff @(posedge clk_in) begin
        if(reset)
            bram_sel <= 0;
        else
            bram_sel <= shared_bram_addr[(LOGSIZE)+2];
    end

    always_comb begin
        if(bram_sel)
            bram_dout = dmem_dout;
        else
            bram_dout = instruction_IFID;
    end

    always_ff @(posedge(clk_in)) begin
        if (reset) begin
            halt_reg <= 1;
        end
        else if (halt) begin
            halt_reg <= 0;
        end
    end

    always_comb begin
        clk = clk_in & halt_reg;
    end

endmodule
