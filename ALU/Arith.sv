`include "inst_defs.sv"
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
 module arithmatic (
    input signed [`REG_RANGE] op1, op2,
    input [`FUNCT_3_RANGE] funct3,
    output logic [`REG_RANGE] result
    );

    always_comb begin
        case (funct3)
            `ADD_SUB: begin
                if (funct7 == 0) begin
                    result = op1 + op2;
                end
                else begin
                    result = op1 - op2;
                end
            end
            `SRL:    result = op1 >> op2;
            `SRA:    result = op1 >>> op2;
        endcase
    end

endmodule
