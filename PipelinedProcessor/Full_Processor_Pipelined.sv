`include "inst_defs.sv"

module pipelined #(
    parameter                   WIDTH=32, SIZE=64,         //WIDTH is bits per word(shouldn't be changed), SIZE is # of WORDS
    localparam                  LOGSIZE=$clog2(SIZE)
)(
    //instruction memory write port
    input [WIDTH-1:0]           instr_in,       //the write port should only be used for filling the memory with instructions in a testbench
    input [(LOGSIZE-1)+2:0]     instr_wr_addr, 
    input instr_wr_en,

    //y'know
    input clk, reset
);
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
    logic flush;    // Used by the hazard unit to flush the pipeline
    // ----- EX Stage Signals(Outputs) -----
    logic [`OP_RANGE] op_IDEX;               //used by ALU to determine what operation to do
    logic [`FUNCT_7_RANGE] funct7_IDEX;      //used by ALU to determine what operation to do
    logic [`FUNCT_3_RANGE] funct3_IDEX;      //used by ALU, but also by the Data MEM to know which load/store operation
    logic [`REG_RANGE] in1_IDEX, in2_IDEX;   //used by ALU to perform an operation and get an output

    logic signed [`REG_RANGE] immediate_IDEX;       //used by branch adder to determine branch address
    logic [`REG_RANGE] pc_IDEX;              //used by branch adder to determine branch address
    logic jump_branch_sel_IDEX;              //used by branch adder to determine whether to use branch address or jump address

    // ----------------- MEM Stage Signals -----------------
    logic mem_wr_en_IDEX;                //This signal connects directly to the memory
    logic [`REG_RANGE] rs2_data_IDEX;

    // ----------------- WB Stage Signals -----------------
    logic reg_wr_en_IDEX;                //the rest of these signals are used for Write Back
    logic [1:0] reg_wr_ctrl_IDEX;
    logic [`REG_FIELD_RANGE] rd_IDEX;
    logic [`REG_RANGE] pc_4_IDEX;


    // --------------- Execute Signals ---------------
    // ----------------- Outputs of this stage -----------------
    // ----------------- MEM Stage Signals(Outputs) -----------------
    logic signed [`REG_RANGE] ALU_out_EXMEM;   //wait does the ALU_out need to be signed???   //these are from the ALU
    logic [`FUNCT_3_RANGE] funct3_EXMEM;
    logic mem_wr_en_EXMEM;
    logic [`REG_RANGE] rs2_data_EXMEM;

    // ----------------- WB Stage Signals(Outputs) -----------------
    logic reg_wr_en_EXMEM;
    logic [1:0] reg_wr_ctrl_EXMEM;
    logic [`REG_FIELD_RANGE] rd_EXMEM;
    logic [`REG_RANGE] pc_4_EXMEM;
    

    //MEM Signals
    //logic [`REG_RANGE] jump_addr;


    instruction_fetch_pipe #(.WIDTH(WIDTH), .SIZE(SIZE)) IF(.clk(clk), .reset(reset), .flush(flush)
                                                        .jump_addr_EXIF(jump_addr_EXIF), .pc_sel_EXIF(pc_sel_EXIF),
                                                        .pc_IFID(pc_IFID), .pc_4_IFID(pc_4_IFID), .instruction_IFID(instruction_IFID),
                                                        .instr_in(instr_in), .wr_addr(instr_wr_addr), .wr_en(instr_wr_en));

    instruction_decode_pipe #(.WIDTH(WIDTH)) ID(.clk(clk), .reset(reset),
                                            .instruction_IFID(instruction_IFID), .pc_IFID(pc_IFID), .pc_4_IFID(pc_4_IFID),
                                            .reg_wr_data_WBID(reg_wr_data_WBID), .rd_WBID(rd_WBID), .reg_wr_en_WBID(reg_wr_en_WBID),
                                            .op_IDEX(op_IDEX), .funct7_IDEX(funct7_IDEX), .funct3_IDEX(funct3_IDEX), .in1_IDEX(in1_IDEX), .in2_IDEX(in2_IDEX),
                                            .immediate_IDEX(immediate_IDEX), .pc_IDEX(pc_IDEX), .jump_branch_sel_IDEX(jump_branch_sel_IDEX),
                                            .mem_wr_en_IDEX(mem_wr_en_IDEX), .rs2_data_IDEX(rs2_data_IDEX),
                                            .reg_wr_en_IDEX(reg_wr_en_IDEX), .reg_wr_ctrl_IDEX(reg_wr_ctrl_IDEX), .rd_IDEX(rd_IDEX), .pc_4_IDEX(pc_4_IDEX));

    execute_pipe EX(
                .in1_IDEX(in1_IDEX), .in2_IDEX(in2_IDEX), .funct7_IDEX(funct7_IDEX), .funct3_IDEX(funct3_IDEX), .op_IDEX(op_IDEX),
                .immediate_IDEX(immediate_IDEX), .pc_IDEX(pc_IDEX), .jump_branch_sel_IDEX(jump_branch_sel_IDEX),
                .mem_wr_en_IDEX(mem_wr_en_IDEX), .rs2_data_IDEX(rs2_data_IDEX),
                .reg_wr_en_IDEX(reg_wr_en_IDEX), .reg_wr_ctrl_IDEX(reg_wr_ctrl_IDEX), .rd_IDEX(rd_IDEX), .pc_4_IDEX(pc_4_IDEX),
                .ALU_out_EXMEM(ALU_out_EXMEM), .funct3_EXMEM(funct3_EXMEM), .mem_wr_en_EXMEM(mem_wr_en_EXMEM), .rs2_data_EXMEM(rs2_data_EXMEM),
                .reg_wr_en_EXMEM(reg_wr_en_EXMEM), .reg_wr_ctrl_EXMEM(reg_wr_ctrl_EXMEM), .rd_EXMEM(rd_EXMEM), .pc_4_EXMEM(pc_4_EXMEM),
                .pc_sel_EXIF(pc_sel_EXIF), .jump_addr_EXIF(jump_addr_EXIF));

    memory_pipe #(.WIDTH(WIDTH), .SIZE(SIZE)) MEM(.clk(clk),
                                            .ALU_out_EXMEM(ALU_out_EXMEM), .funct3_EXMEM(funct3_EXMEM), .mem_wr_en_EXMEM(mem_wr_en_EXMEM), .rs2_data_EXMEM(rs2_data_EXMEM),
                                            .reg_wr_en_EXMEM(reg_wr_en_EXMEM), .reg_wr_ctrl_EXMEM(reg_wr_ctrl_EXMEM), .rd_EXMEM(rd_EXMEM), .pc_4_EXMEM(pc_4_EXMEM),
                                            .reg_wr_data_WBID(reg_wr_data_WBID), .rd_WBID(rd_WBID), .reg_wr_en_WBID(reg_wr_en_WBID));    


    

endmodule
