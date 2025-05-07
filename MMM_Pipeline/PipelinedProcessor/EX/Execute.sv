`include "inst_defs.sv"

module execute (
    input clk, reset,   //not used for the single cycle version but when we pipeline we need to insert a ff block

    // ----------------- Inputs to this stage -----------------
    // ----------------- EX Stage Signals(Inputs) -----------------
    input signed [`REG_RANGE]     rs1_data_IDEX,  //these are used by the ALU
    input        [`FUNCT_7_RANGE] funct7_IDEX,
    input        [`FUNCT_3_RANGE] funct3_IDEX,
    input        [`OP_RANGE]      op_IDEX,

    input signed [`REG_RANGE] immediate_IDEX,       //These are used by the branch adder and mux
    input        [`REG_RANGE] pc_IDEX,             //does the pc need to be signed as well?
    input                     jump_branch_sel_IDEX,

    input                     mmm_stall,
    input halt_ID,

    // ----------------- MEM Stage Signals -----------------
    input mem_wr_en_IDEX,
    input [`REG_RANGE] rs2_data_IDEX,

    // ----------------- WB Stage Signals -----------------
    input reg_wr_en_IDEX,
    input [1:0] reg_wr_ctrl_IDEX,
    input [`REG_FIELD_RANGE] rd_IDEX,
    input [`REG_RANGE] pc_4_IDEX,

    // ----------------- Forwarding/ALU Mux Signals -----------------
    input [`REG_FIELD_RANGE] rs1_IDEX, rs2_IDEX,    //the 2 registers used as alu input operands
    input pc_rs1_sel_IDEX, imm_rs2_sel_IDEX,        //select signals, if this is set to 1 then the data rs field may be invalid, and data shouldn't be forwarded

    input [`REG_RANGE] reg_wr_data_WBID,
    input [`REG_FIELD_RANGE] rd_WBID,
    input reg_wr_en_WBID,
    
    //input [1:0] in1_sel, in2_sel,       //select signal to control inputs to alu
                                        //00 means to select rs_data, 01 means 


    // ----------------- Outputs of this stage -----------------
    // ----------------- MEM Stage Signals(Outputs) -----------------
    output logic signed [`REG_RANGE] ALU_out_EXMEM,   //wait does the ALU_out need to be signed???   //these are from the ALU
    output logic [`FUNCT_3_RANGE] funct3_EXMEM,
    output logic mem_wr_en_EXMEM,
    output logic [`REG_RANGE] rs2_data_EXMEM,
    output logic halt_MEM,

    // ----------------- WB Stage Signals(Outputs) -----------------
    output logic reg_wr_en_EXMEM,
    output logic [1:0] reg_wr_ctrl_EXMEM,
    output logic [`REG_FIELD_RANGE] rd_EXMEM,
    output logic [`REG_RANGE] pc_4_EXMEM,

    
     // ----------------- IF Stage Signals(Outputs) -----------------
    output logic              pc_sel_EXIF,
    output logic [`REG_RANGE] jump_addr_EXIF, //these are from the branch adder and mux

    //USED By MMM which starts execution in EX stage
    output logic [`REG_RANGE] rs2_data_forward,

    output logic div_stall
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
        if((reset == 1) || (mmm_stall == 1) || (div_stall == 1)) begin
            //MEM Stage
            ALU_out_EXMEM <= 0;
            funct3_EXMEM <= 0;
            mem_wr_en_EXMEM <= 0;
            rs2_data_EXMEM <= 0;

            halt_MEM <= 0;

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
            rs2_data_EXMEM <= rs2_data_forward;

            halt_MEM <= halt_ID;

            //WB Stage
            reg_wr_en_EXMEM <= reg_wr_en_IDEX;
            reg_wr_ctrl_EXMEM <= reg_wr_ctrl_IDEX;
            rd_EXMEM <= rd_IDEX;
            pc_4_EXMEM <= pc_4_IDEX;
        end
    end

    logic signed        [`REG_RANGE]     in1, in2;
    logic               [1:0] in1_sel, in2_sel;
    //Forwarding Unit
    ForwardUnit forwardunit(.rs1_IDEX(rs1_IDEX), .rs2_IDEX(rs2_IDEX),
                            .rd_EXMEM(rd_EXMEM), .reg_wr_en_EXMEM(reg_wr_en_EXMEM),
                            .rd_WBID(rd_WBID), .reg_wr_en_WBID(reg_wr_en_WBID),
                            .in1_sel(in1_sel), .in2_sel(in2_sel));

    //logic [`REG_RANGE] rs2_data_forward;
    always_comb begin
        rs2_data_forward = rs2_data_IDEX;
        if((reg_wr_en_EXMEM == 1) && (rs2_IDEX == rd_EXMEM) && (rd_EXMEM != 0))
                rs2_data_forward = ALU_out_EXMEM;
        else if((reg_wr_en_WBID == 1) && (rs2_IDEX == rd_WBID) && (rd_WBID != 0))
                rs2_data_forward = reg_wr_data_WBID;
    end

    // ALU Input Mux
    always_comb begin
        if(pc_rs1_sel_IDEX == 1)    //if pc_rs1_sel is set to 1 then this operand contains the pc and should not be forwarded as it does not contain register data
            in1 = pc_IDEX;
        else if(in1_sel == 2'b00)
            in1 = rs1_data_IDEX;
        else if(in1_sel == 2'b10)
            in1 = ALU_out_EXMEM;
        else if(in1_sel == 2'b01)
            in1 = reg_wr_data_WBID;
        else
            in1 = 0;

        if(imm_rs2_sel_IDEX == 1)   //if imm_rs2_sel is set to 1 then this operand contains the immediate and should not be forwarded as it does not contain register data
            in2 = immediate_IDEX;
        else if(in2_sel == 2'b00)
            in2 = rs2_data_IDEX;
        else if(in2_sel == 2'b10)
            in2 = ALU_out_EXMEM;
        else if(in2_sel == 2'b01)
            in2 = reg_wr_data_WBID;
        else
            in2 = 0;
    end


    logic [`REG_RANGE] alu_out;
    alu alu(.in1(in1), .in2(in2),
            .op(op_IDEX), .funct_3(funct3_IDEX), .funct_7(funct7_IDEX),
            .out(alu_out), .pc_sel(pc_sel_EXIF));

    logic [`REG_RANGE] quotient, remainder;
    logic div_start, div_status, signed_div, div_fin;
    division_wrapper divider(
        .dividend(in1), .divisor(in2), .start(div_start), .clk(clk), .reset(reset),
        .signed_div(signed_div), .quotient(quotient), .remainder(remainder), .status(div_status), .finished(div_fin)
    );

    always_comb begin
        div_start = 0;
        signed_div = 0;
        ALU_out_EX = alu_out;
        if (op_IDEX == `OP_R3 && funct7_IDEX == `M) begin
            case(funct3_IDEX)
                `XOR: begin
                    div_start = 1;
                    signed_div = 1;
                    ALU_out_EX = quotient;
                end
                `SRL_SRA: begin
                    div_start = 1;
                    signed_div = 0;
                    ALU_out_EX = quotient;
                end
                `OR: begin
                    div_start = 1;
                    signed_div = 1;
                    ALU_out_EX = remainder;
                end
                `AND: begin
                    div_start = 1;
                    signed_div = 0;
                    ALU_out_EX = remainder;
                end
            endcase
        end
        div_stall = ((in2 == 0) && ~div_status) ? 0 : (div_status | (div_start & ~div_fin));
    end

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
