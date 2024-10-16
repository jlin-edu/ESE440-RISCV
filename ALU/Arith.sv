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
    input [`FUNCT_3_RANGE] funct3,              // 3-bit funct3 field
    input logic [`FUNCT_7_RANGE] funct7,        // 7-bit funct7 field  
    input logic IMM_Type_flag,                       // Immediate type flag 
    input signed [`IMM_RANGE_I] immediate,                  // Immediate value for I-type instructions
    output logic [`REG_RANGE] result
    );

    always_comb begin
        if (IMM_Type_flag) begin
            case (funct3)
                `ADDI:   result = op1 + immediate;
                `SLTI:   result = (op1 < immediate) ? 1 : 0;
                `SLTIU:  result = ($unsigned(op1) < $unsigned(immediate)) ? 1 : 0;
                `XORI:   result = op1 ^ immediate;
                `ORI:    result = op1 | immediate;
                `ANDI:   result = op1 & immediate;
                `SLLI:   result = op1 << immediate[5:0];        // Shift amount is lower 5 bits
                `SRLI_SRAI: begin
                    if (funct7 == `SRLI) begin
                        result = op1 >> immediate[5:0];        // Shift amount is lower 5 bits
                    end
                    else if (funct7 == `SRAI) begin
                        result = op1 >>> immediate[5:0];       // Shift amount is lower 5 bits
                    end
                end
                default: result = 0;
            endcase
        end
        else begin
        case (funct3)
            `ADD_SUB: begin
                if (funct7 == `DEFAULT_7) begin
                    result = op1 + op2;
                end
                else begin
                    result = op1 - op2;
                end
            end
            `SRL:    result = op1 >> op2;
            `SRA:    result = op1 >>> op2;
            `SLL:    result = op1 << op2;
            `SLT:    result = (op1 < op2) ? 1 : 0;
            `SLTU:   result = ($unsigned(op1) < $unsigned(op2)) ? 1 : 0;
            `XOR:    result = op1 ^ op2;
            `SRL_SRA: begin
                if (funct7 == `SRLI) begin
                    result = op1 >> op2; 
                end
                else if (funct7 == `SRAI) begin
                    result = op1 >>> op2;
                end
            end 
            `OR:     result = op1 | op2;
            `AND:    result = op1 & op2;
            default: result = 0;
        endcase
        end
    end
endmodule
