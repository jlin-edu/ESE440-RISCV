`include "inst_defs.sv"
module alu_tb;
    logic signed [`REG_RANGE] in1, in2;
    logic [`OP_RANGE] op;
    logic [`FUNCT_3_RANGE] funct3;
    logic [`FUNCT_7_RANGE] funct7;
    logic [`REG_RANGE] out;
    logic pc_sel;

    alu UUT (
        .in1(in1),
        .in2(in2),
        .op(op),
        .funct_3(funct3),
        .funct_7(funct7),
        .out(out),
        .pc_sel(pc_sel)
    );
/* IMM DEFINITIONS
`define ADDI 3'b000
`define SLTI 3'b010
`define SLTIU 3'b011
`define XORI 3'b100
`define ORI 3'b110
`define ANDI 3'b111
`define SLLI 3'b001
`define SRLI_SRAI 3'b101

// R3 DEFINITIONS
`define ADD_SUB 3'b000
`define SLL 3'b001
`define SLT 3'b010
`define SLTU 3'b011
`define XOR 3'b100
`define SRL_SRA 3'b101
`define OR 3'b110
`define AND 3'b111
*/
    initial begin
        // Test LUI
        in1 = 0;
        in2 = 32'h12345678;
        funct3 = 0;
        funct7 = 0;
        op = `OP_LUI;
        #10;
        $display("LUI out: %h, expected = %h", out, 32'h12345678);

        // Test ADDI
        in1 = 32'h00000010;
        in2 = 32'h00000020;
        op = `OP_IMM;
        funct3 = `ADDI;
        funct7 = 0;
        #10;
        $display("ADDI out: %h, expected = %h", out, 32'h00000030);

        // Test SUB
        in1 = 32'h00000020;
        in2 = 32'h00000010;
        op = `OP_R3;
        funct3 = `ADD_SUB;
        funct7 = `SUB;
        #10;
        $display("SUB out: %h, expected = %h", out, 32'h00000010);

        // Test JAL 
        in1 = 0;
        in2 = 32'h00000010;
        op = `OP_JAL;
        funct3 = 0;
        funct7 = 0;
        #10;
        $display("JAL out: %h, pc_sel = %b, expected = %h, %b", out, pc_sel, 32'h00000010, 1);

        $finish;
    end
endmodule