`include "inst_defs.sv"

module M_ext (
    input signed [`REG_RANGE] op1, op2,
    input [`FUNCT_3_RANGE] funct3,
    output logic [`REG_RANGE] result
);

    always_comb begin
        case (funct3)
            `MUL:    result = op1 * op2;
            `MULH:   result = (op1 * op2) >> `REG_SIZE;
            `MULHU:  result = ($unsigned(op1) * $unsigned(op2)) >> `REG_SIZE;      
            `MULHSU: result = (op1 * $unsigned(op2)) >> REG_SIZE;
            `DIV:    result = (op2 == 0) ? -1 : (op1 == -`MAX_32 && op2 == -1) ? -`MAX_32 : op1 / op2;
            `DIVU:   result = (op2 == 0) ? `MAX_32 : $unsigned(op1) / $unsigned(op2);
            `REM:    result = (op2 == 0) ? op1 : (op1 == -`MAX_32 && op2 == -1) ? 0 : op1 % op2;
            `REMU:   result = (op2 == 0) ? op1 : $unsigned(op1) % $unsigned(op2);
        endcase
    end

endmodule