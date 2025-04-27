`include "inst_defs.sv"

module instruction_decode #(
    parameter WIDTH=32
)(
    input clk, reset,

    // ----------------- Inputs to this stage -----------------
    // ----------------- IF Stage Signals(Inputs) -----------------
    input [`REG_RANGE] instruction_IFID, pc_IFID, pc_4_IFID,


    // ----------------- EX Stage Signals(Inputs) -----------------
    input              mmm_stall,

    // ----------------- WB Stage Signals(Inputs) -----------------
    input [`REG_RANGE] reg_wr_data_WBID,        //these signals are responsible for writing to the register file
    input [`REG_FIELD_RANGE] rd_WBID,
    input reg_wr_en_WBID,

    input pc_sel_EXIF,    //utilized for flushing, Hazard Handling

    // ----------------- Outputs of this stage -----------------
    // ----------------- EX Stage Signals(Outputs) -----------------
    output logic [`OP_RANGE] op_IDEX,               //used by ALU to determine what operation to do
    output logic [`FUNCT_7_RANGE] funct7_IDEX,      //used by ALU to determine what operation to do
    output logic [`FUNCT_3_RANGE] funct3_IDEX,      //used by ALU, but also by the Data MEM to know which load/store operation
    output logic [`REG_RANGE] rs1_data_IDEX,        //used by ALU to perform an operation and get an output

    output logic signed [`REG_RANGE] immediate_IDEX,       //used by branch adder to determine branch address
    output logic [`REG_RANGE] pc_IDEX,              //used by branch adder to determine branch address
    output logic jump_branch_sel_IDEX,              //used by branch adder to determine whether to use branch address or jump address

    // ----------------- MEM Stage Signals -----------------
    output logic mem_wr_en_IDEX,                //This signal connects directly to the memory
    output logic [`REG_RANGE] rs2_data_IDEX,
    output logic start_mmm_IDEX,
    output logic wait_mmm_finish_IDEX,

    // ----------------- WB Stage Signals -----------------
    output logic reg_wr_en_IDEX,                //the rest of these signals are used for Write Back
    output logic [1:0] reg_wr_ctrl_IDEX,
    output logic [`REG_FIELD_RANGE] rd_IDEX,
    output logic [`REG_RANGE] pc_4_IDEX,


    // ----------------- Forwarding Signals -----------------
    output logic [`REG_FIELD_RANGE] rs1_IDEX, rs2_IDEX,
    output logic pc_rs1_sel_IDEX, imm_rs2_sel_IDEX,

    output logic stall
    //used for data forwarding(not pipelined) 
    //forwarding unit should also be passed the opcode as well to determine if numbers in rs1 and rs2 range are actualy register numbers
    //actually, what we can do is send control signals imm_rs2_sel and pc_rs1_sel to forwarding unit to identify
    //output logic [`REG_FIELD_RANGE] rs1, rs2
);
    //internal signals(to be pipelined)
    //Ex Stage
    logic [`OP_RANGE] op_ID;
    logic [`FUNCT_7_RANGE] funct7_ID;
    logic [`FUNCT_3_RANGE] funct3_ID;
    //logic [`REG_RANGE] in1_ID, in2_ID;
    logic signed [`REG_RANGE] immediate_ID;
    logic jump_branch_sel_ID;

    //Mem Stage
    logic mem_wr_en_ID;
    logic [`REG_RANGE] rs2_data_ID;
    logic start_mmm_ID;
    logic wait_mmm_finish_ID;

    //WB Stage
    logic reg_wr_en_ID;
    logic [1:0] reg_wr_ctrl_ID;
    logic [`REG_FIELD_RANGE] rd_ID;

    //assign pc_IDEX = pc_IFID;
    //assign pc_4_IDEX = pc_4_IFID;
    always_ff @(posedge clk) begin
        if((reset == 1) || (pc_sel_EXIF == 1) || (stall == 1)) begin
            //EX Stage
            op_IDEX        <= `OP_IMM;
            funct7_IDEX    <= 0;
            funct3_IDEX    <= 0;
            rs1_data_IDEX  <= 0;
            //in2_IDEX       <= 0;

            immediate_IDEX       <= 0;
            pc_IDEX              <= 0;
            jump_branch_sel_IDEX <= 0;

            //MEM Stage
            mem_wr_en_IDEX <= 0;
            rs2_data_IDEX  <= 0;
            start_mmm_IDEX <= 0;
            wait_mmm_finish_IDEX <= 0;

            //WB Stage
            reg_wr_en_IDEX   <= 0;
            reg_wr_ctrl_IDEX <= 0;
            rd_IDEX          <= 0;
            pc_4_IDEX        <= 0;

            //Forwarding
            rs1_IDEX         <= 0;
            rs2_IDEX         <= 0;
            pc_rs1_sel_IDEX  <= 0;
            imm_rs2_sel_IDEX <= 0;
        end
        else if (mmm_stall == 0) begin
            //EX Stage
            op_IDEX        <= op_ID;
            funct7_IDEX    <= funct7_ID;
            funct3_IDEX    <= funct3_ID;
            rs1_data_IDEX  <= rs1_data;
            //in2_IDEX       <= in2_ID;

            immediate_IDEX       <= immediate_ID;
            pc_IDEX              <= pc_IFID;
            jump_branch_sel_IDEX <= jump_branch_sel_ID;

            //MEM Stage
            mem_wr_en_IDEX <= mem_wr_en_ID;
            rs2_data_IDEX  <= rs2_data_ID;
            start_mmm_IDEX <= start_mmm_ID;
            wait_mmm_finish_IDEX <= wait_mmm_finish_ID;

            //WB Stage
            reg_wr_en_IDEX   <= reg_wr_en_ID;
            reg_wr_ctrl_IDEX <= reg_wr_ctrl_ID;
            rd_IDEX          <= rd_ID;
            pc_4_IDEX        <= pc_4_IFID;

            //Forwarding
            rs1_IDEX         <= rs1_ID;
            rs2_IDEX         <= rs2_ID;
            pc_rs1_sel_IDEX  <= pc_rs1_sel;
            imm_rs2_sel_IDEX <= imm_rs2_sel;
        end
    end


    //logic [`OP_RANGE] op;
    //logic [`FUNCT_3_RANGE] funct3;
    //logic [`FUNCT_7_RANGE] funct7;
    logic [`REG_FIELD_RANGE] rs1_ID, rs2_ID;
    assign op_ID     = instruction_IFID[`OP_FIELD];
    assign funct3_ID = instruction_IFID[`FUNCT_3_FIELD];
    assign funct7_ID = instruction_IFID[`FUNCT_7_FIELD];
    assign rs1_ID    = instruction_IFID[`REG_RS1];          //for the pipelined variant, we will most likely need to pass rs1, rs2 and rd for hazard detection
    assign rs2_ID    = instruction_IFID[`REG_RS2];
    assign rd_ID     = instruction_IFID[`REG_RD];      //this rd signal will need to be sent through the pipeline
    inst_splitter inst_splitter (.inst(instruction_IFID), .op(op_ID), 
                                .imm(immediate_ID));

    logic pc_rs1_sel, imm_rs2_sel;
    control_unit  control_unit  (.opcode(op_ID),
                                .pc_rs1_sel(pc_rs1_sel), .imm_rs2_sel(imm_rs2_sel),
                                .jump_branch_sel(jump_branch_sel_ID), .mem_wr_en(mem_wr_en_ID), .reg_write_ctrl(reg_wr_ctrl_ID), .reg_wr_en(reg_wr_en_ID),
                                .start_mmm(start_mmm_ID), .wait_mmm_finish(wait_mmm_finish_ID));

    logic [`REG_RANGE] rs1_data;
    register_file #(.WIDTH(WIDTH)) register_file(.clk(clk), .reset(reset),
                                                .wr_addr(rd_WBID), .wr_data(reg_wr_data_WBID), .wr_en(reg_wr_en_WBID),     //dont use rd directly as the write address when pipelined, same with reg_wr_en
                                                .rs1_rd_addr(rs1_ID), .rs1_rd_data(rs1_data),
                                                .rs2_rd_addr(rs2_ID), .rs2_rd_data(rs2_data_ID)); 


    //logic stall;
    hazard_unit hazard_unit(.reg_wr_ctrl_IDEX(reg_wr_ctrl_IDEX), .rd_IDEX(rd_IDEX),
                            .rs1_ID(rs1_ID), .rs2_ID(rs2_ID), .pc_rs1_sel(pc_rs1_sel), .imm_rs2_sel(imm_rs2_sel),
                            .stall(stall));
    //muxes for selecting inputs of our ALU
    /*
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
    */
endmodule