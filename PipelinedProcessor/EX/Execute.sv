`include "inst_defs.sv"

module execute (
    // input clk, reset,   //not used for the single cycle version but when we pipeline we need to insert a ff block

    // ----------------- Inputs to this stage -----------------
    // ----------------- EX Stage Signals(Inputs) -----------------
    input signed [`REG_RANGE]     in1_IDEX, in2_IDEX,   //these are used by the ALU
    input        [`FUNCT_7_RANGE] funct7_IDEX,
    input        [`FUNCT_3_RANGE] funct3_IDEX,
    input        [`OP_RANGE]      op_IDEX,

    input signed [`REG_RANGE] immediate_IDEX,       //These are used by the branch adder and mux
    input        [`REG_RANGE] pc_IDEX,             //does the pc need to be signed as well?
    input                     jump_branch_sel_IDEX,

    // ----------------- MEM Stage Signals -----------------
    input mem_wr_en_IDEX,
    input [`REG_RANGE] rs2_data_IDEX,

    // ----------------- WB Stage Signals -----------------
    input reg_wr_en_IDEX,
    input [1:0] reg_wr_ctrl_IDEX,
    input [`REG_FIELD_RANGE] rd_IDEX,
    input [`REG_RANGE] pc_4_IDEX,


    // ----------------- Outputs of this stage -----------------
    // ----------------- MEM Stage Signals(Outputs) -----------------
    output logic signed [`REG_RANGE] ALU_out_EXMEM,   //wait does the ALU_out need to be signed???   //these are from the ALU
    output logic [`FUNCT_3_RANGE] funct3_EXMEM,
    output logic mem_wr_en_EXMEM,
    output logic [`REG_RANGE] rs2_data_EXMEM,

    // ----------------- WB Stage Signals(Outputs) -----------------
    output logic reg_wr_en_EXMEM,
    output logic [1:0] reg_wr_ctrl_EXMEM,
    output logic [`REG_FIELD_RANGE] rd_EXMEM,
    output logic [`REG_RANGE] pc_4_EXMEM,

    
     // ----------------- IF Stage Signals(Outputs) -----------------
    output logic              pc_sel_EXIF,
    output logic [`REG_RANGE] jump_addr_EXIF //these are from the branch adder and mux

    //input signed        [`REG_RANGE]     in1, in2,
    //input               [`OP_RANGE]      op,
    //input               [`FUNCT_3_RANGE] funct_3,
    //input               [`FUNCT_7_RANGE] funct_7,

    //output logic signed [`REG_RANGE]     out,
    //output logic                         pc_sel
);
    //MEM Pipeline Signals
    //ALU_out_EXMEM
    //assign funct3_EXMEM = funct3_IDEX;
    //assign mem_wr_en_EXMEM = mem_wr_en_IDEX;
    //assign rs2_data_EXMEM = rs2_data_IDEX;

    //WB Pipeline Signals
    //assign reg_wr_en_EXMEM = reg_wr_en_IDEX;
    //assign reg_wr_ctrl_EXMEM = reg_wr_ctrl_IDEX;
    //assign rd_EXMEM = rd_IDEX;
    //assign pc_4_EXMEM = pc_4_IDEX;

    logic signed [`REG_RANGE] ALU_out_EX;
    always_ff @(posedge clk) begin
        if(reset == 1) begin
            //MEM Stage
            ALU_out_EXMEM <= 0;
            funct3_EXMEM <= 0;
            mem_wr_en_EXMEM <= 0;
            rs2_data_EXMEM <= 0;

            //WB Stage
            reg_wr_en_EXMEM <= 0;
            reg_wr_ctrl_EXMEM <= 0;
            rd_EXMEM <= 0;
            pc_4_EXMEM <= 0;
        end
        else begin
            //MEM Stage
            ALU_out_EXMEM <= ALU_out_EX;
            funct3_EXMEM <= funct3_IDEX;
            mem_wr_en_EXMEM <= mem_wr_en_IDEX;
            rs2_data_EXMEM <= rs2_data_IDEX;

            //WB Stage
            reg_wr_en_EXMEM <= reg_wr_en_IDEX;
            reg_wr_ctrl_EXMEM <= reg_wr_ctrl_IDEX;
            rd_EXMEM <= rd_IDEX;
            pc_4_EXMEM <= pc_4_IDEX;
        end
    end



    alu alu(.in1(in1_IDEX), .in2(in2_IDEX),
            .op(op_IDEX), .funct_3(funct3_IDEX), .funct_7(funct7_IDEX),
            .out(ALU_out_EX), .pc_sel(pc_sel_EXIF));

    //branch adder
    logic [`REG_RANGE] branch_addr;
    always_comb begin
        branch_addr = pc_IDEX + immediate_IDEX;

        if(jump_branch_sel_IDEX == 1)
            jump_addr_EXIF = branch_addr;
        else
            jump_addr_EXIF = ALU_out_EX;

    end



endmodule
