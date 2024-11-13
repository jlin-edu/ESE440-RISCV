`include "inst_defs.sv"

module instruction_decode #(
    parameter WIDTH=32
)(
    input clk, reset,

    // ----------------- Inputs to this stage -----------------
    // ----------------- IF Stage Signals(Inputs) -----------------
    input [`REG_RANGE] instruction_IFID, pc_IFID, pc_4_IFID,

    // ----------------- WB Stage Signals(Inputs) -----------------
    input [`REG_RANGE] reg_wr_data_WBID,        //these signals are responsible for writing to the register file
    input [`REG_FIELD_RANGE] rd_WBID,
    input reg_wr_en_WBID,



    // ----------------- Outputs of this stage -----------------
    // ----------------- EX Stage Signals(Outputs) -----------------
    output logic [`OP_RANGE] op_IDEX,               //used by ALU to determine what operation to do
    output logic [`FUNCT_7_RANGE] funct7_IDEX,      //used by ALU to determine what operation to do
    output logic [`FUNCT_3_RANGE] funct3_IDEX,      //used by ALU, but also by the Data MEM to know which load/store operation
    output logic [`REG_RANGE] in1_IDEX, in2_IDEX,   //used by ALU to perform an operation and get an output

    output logic signed [`REG_RANGE] immediate_IDEX,       //used by branch adder to determine branch address
    output logic [`REG_RANGE] pc_IDEX,              //used by branch adder to determine branch address
    output logic jump_branch_sel_IDEX,              //used by branch adder to determine whether to use branch address or jump address

    // ----------------- MEM Stage Signals -----------------
    output logic mem_wr_en_IDEX,                //This signal connects directly to the memory
    output logic [`REG_RANGE] rs2_data_IDEX,

    // ----------------- WB Stage Signals -----------------
    output logic reg_wr_en_IDEX,                //the rest of these signals are used for Write Back
    output logic [1:0] reg_wr_ctrl_IDEX,
    output logic [`REG_FIELD_RANGE] rd_IDEX,
    output logic [`REG_RANGE] pc_4_IDEX

);
    assign pc_IDEX = pc_IFID;
    assign pc_4_IDEX = pc_4_IFID;
    //logic [`OP_RANGE] op;
    //logic [`FUNCT_3_RANGE] funct3;
    //logic [`FUNCT_7_RANGE] funct7;
    logic [`REG_FIELD_RANGE] rs1, rs2;
    assign op_IDEX     = instruction_IFID[`OP_FIELD];
    assign funct3_IDEX = instruction_IFID[`FUNCT_3_FIELD];
    assign funct7_IDEX = instruction_IFID[`FUNCT_7_FIELD];
    assign rs1         = instruction_IFID[`REG_RS1];          //for the pipelined variant, we will most likely need to pass rs1, rs2 and rd for hazard detection
    assign rs2         = instruction_IFID[`REG_RS2];
    assign rd_IDEX     = instruction_IFID[`REG_RD];      //this rd signal will need to be sent through the pipeline
    inst_splitter inst_splitter (.inst(instruction_IFID), .op(op_IDEX), 
                                .imm(immediate_IDEX));

    logic pc_rs1_sel, imm_rs2_sel;
    control_unit  control_unit  (.opcode(op_IDEX),
                                .pc_rs1_sel(pc_rs1_sel), .imm_rs2_sel(imm_rs2_sel),
                                .jump_branch_sel(jump_branch_sel_IDEX), .mem_wr_en(mem_wr_en_IDEX), .reg_write_ctrl(reg_wr_ctrl_IDEX), .reg_wr_en(reg_wr_en_IDEX));

    logic [`REG_RANGE] rs1_data;
    register_file #(.WIDTH(WIDTH)) register_file(.clk(clk), .reset(reset),
                                                .wr_addr(rd_WBID), .wr_data(reg_wr_data_WBID), .wr_en(reg_wr_en_WBID),     //dont use rd directly as the write address when pipelined, same with reg_wr_en
                                                .rs1_rd_addr(rs1), .rs1_rd_data(rs1_data),
                                                .rs2_rd_addr(rs2), .rs2_rd_data(rs2_data_IDEX)); 

    //muxes for selecting inputs of our ALU
    always_comb begin
        if(pc_rs1_sel == 0)
            in1_IDEX = rs1_data;
        else
            in1_IDEX = pc_IFID;

        if(imm_rs2_sel == 0)
            in2_IDEX = rs2_data_IDEX;
        else
            in2_IDEX = immediate_IDEX;
    end

endmodule