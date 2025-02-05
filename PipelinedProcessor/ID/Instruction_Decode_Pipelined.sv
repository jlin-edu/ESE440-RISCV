`include "inst_defs.sv"

module instruction_decode_pipe #(
    parameter WIDTH=32
)(
    input clk, reset, flush

    // ----------------- Inputs to this stage -----------------
    // ----------------- IF Stage Signals(Inputs) -----------------
    input [`REG_RANGE] instruction_IFID, pc_IFID, pc_4_IFID,

    // ----------------- WB Stage Signals(Inputs) -----------------
    input [`REG_RANGE] reg_wr_data_WBID,        //these signals are responsible for writing to the register file
    input [`REG_FIELD_RANGE] rd_WBID,
    input reg_wr_en_WBID,



    // ----------------- Outputs of this stage -----------------
    // ----------------- EX Stage Signals(Outputs) -----------------
    output logic [`OP_RANGE] op_ID,               //used by ALU to determine what operation to do
    output logic [`FUNCT_7_RANGE] funct7_ID,      //used by ALU to determine what operation to do
    output logic [`FUNCT_3_RANGE] funct3_ID,      //used by ALU, but also by the Data MEM to know which load/store operation
    output logic [`REG_RANGE] in1_ID, in2_ID,   //used by ALU to perform an operation and get an output

    output logic signed [`REG_RANGE] immediate_ID,       //used by branch adder to determine branch address
    output logic [`REG_RANGE] pc_ID,              //used by branch adder to determine branch address
    output logic jump_branch_sel_ID,              //used by branch adder to determine whether to use branch address or jump address

    // ----------------- MEM Stage Signals -----------------
    output logic mem_wr_en_ID,                //This signal connects directly to the memory
    output logic [`REG_RANGE] rs2_data_ID,

    // ----------------- WB Stage Signals -----------------
    output logic reg_wr_en_ID,                //the rest of these signals are used for Write Back
    output logic [1:0] reg_wr_ctrl_ID,
    output logic [`REG_FIELD_RANGE] rd_ID,
    output logic [`REG_FIELD_RANGE] rs1_ID, rs2_ID, // used for forwarding
    output logic [`REG_RANGE] pc_4_ID

);

    logic [`OP_RANGE] op_ID,               //used by ALU to determine what operation to do
    logic [`FUNCT_7_RANGE] funct7_ID,      //used by ALU to determine what operation to do
    logic [`FUNCT_3_RANGE] funct3_ID,      //used by ALU, but also by the Data MEM to know which load/store operation
    logic [`REG_RANGE] in1_ID, in2_ID,   //used by ALU to perform an operation and get an output

    logic signed [`REG_RANGE] immediate_ID,       //used by branch adder to determine branch address
    logic [`REG_RANGE] pc_ID,              //used by branch adder to determine branch address
    logic jump_branch_sel_ID,              //used by branch adder to determine whether to use branch address or jump address

    logic mem_wr_en_ID,                //This signal connects directly to the memory
    logic [`REG_RANGE] rs2_data_ID,

    logic reg_wr_en_ID,                //the rest of these signals are used for Write Back
    logic [1:0] reg_wr_ctrl_ID,
    logic [`REG_FIELD_RANGE] rd_ID,
    logic [`REG_FIELD_RANGE] rs1_ID, rs2_ID, // used for forwarding
    logic [`REG_RANGE] pc_4_ID


    assign pc_ID = pc_IFID;
    assign pc_4_ID = pc_4_IFID;
    //logic [`OP_RANGE] op;
    //logic [`FUNCT_3_RANGE] funct3;
    //logic [`FUNCT_7_RANGE] funct7;
    logic [`REG_FIELD_RANGE] rs1, rs2;
    assign op_ID     = instruction_IFID[`OP_FIELD];
    assign funct3_ID = instruction_IFID[`FUNCT_3_FIELD];
    assign funct7_ID = instruction_IFID[`FUNCT_7_FIELD];
    assign rs1         = instruction_IFID[`REG_RS1];          //for the pipelined variant, we will most likely need to pass rs1, rs2 and rd for hazard detection
    assign rs2         = instruction_IFID[`REG_RS2];
    assign rd_ID     = instruction_IFID[`REG_RD];      //this rd signal will need to be sent through the pipeline
    inst_splitter inst_splitter (.inst(instruction_IFID), .op(op_ID), 
                                .imm(immediate_ID));

    logic pc_rs1_sel, imm_rs2_sel;
    control_unit  control_unit  (.opcode(op_ID),
                                .pc_rs1_sel(pc_rs1_sel), .imm_rs2_sel(imm_rs2_sel),
                                .jump_branch_sel(jump_branch_sel_ID), .mem_wr_en(mem_wr_en_ID), .reg_write_ctrl(reg_wr_ctrl_ID), .reg_wr_en(reg_wr_en_ID));

    logic [`REG_RANGE] rs1_data;
    register_file #(.WIDTH(WIDTH)) register_file(.clk(clk), .reset(reset),
                                                .wr_addr(rd_WBID), .wr_data(reg_wr_data_WBID), .wr_en(reg_wr_en_WBID),     //dont use rd directly as the write address when pipelined, same with reg_wr_en
                                                .rs1_rd_addr(rs1), .rs1_rd_data(rs1_data),
                                                .rs2_rd_addr(rs2), .rs2_rd_data(rs2_data_ID)); 

    //muxes for selecting inputs of our ALU
    always_comb begin
        if(pc_rs1_sel == 0)
            in1_ID = rs1_data;
        else
            in1_ID = pc_IFID;

        if(imm_rs2_sel == 0)
            in2_ID = rs2_data_ID;
        else
            in2_ID = immediate_ID;
    end

    always_ff @(posedge clk) begin
        if (flush || reset) begin
            op_IDEX <= `OP_IMM;              
            funct7_IDEX <= 0;    
            funct3_IDEX <= `ADDI;
            in1_IDEX <= 0;
            in2_IDEX <= 0;

            immediate_IDEX <= 0;       
            pc_IDEX <= 0;
            jump_branch_sel_IDEX <= 0;              

            mem_wr_en_IDEX <= 0;
            rs2_data_IDEX <= 0;

            reg_wr_en_IDEX <= 0;        
            reg_wr_ctrl_IDEX <= 0;
            rd_IDEX <= 0;
            rs1_IDEX <= 0;
            rs2_IDEX <= 0;
            pc_4_IDEX <= 0;

        end else begin
            op_IDEX <= op_ID;              
            funct7_IDEX <= funct7_ID;
            funct3_IDEX <= funct3_ID;
            in1_IDEX <= in1_ID;
            in2_IDEX <= in2_ID;

            immediate_IDEX <= immediate_ID;     
            pc_IDEX <= pc_ID;
            jump_branch_sel_IDEX <= jump_branch_sel_ID;              

            mem_wr_en_IDEX <= mem_wr_en_ID;
            rs2_data_IDEX <= rs2_data_ID;

            reg_wr_en_IDEX <= reg_wr_en_ID;
            reg_wr_ctrl_IDEX <= reg_wr_ctrl_ID;
            rd_IDEX <= rd_ID;
            rs1_IDEX <= rs1_ID;
            rs2_IDEX <= rs2_ID;
            pc_4_IDEX <= pc_4_ID;
        end
    end

endmodule