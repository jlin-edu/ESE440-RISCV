`include "inst_defs.sv"

module M_tb ();

    logic [`REG_RANGE] op1, op2, result;
    logic [`FUNCT_3_RANGE] funct;

    M_ext UUT (
        .op1(op1),
        .op2(op2),
        .funct3(funct),
        .result(result)
    );

    initial begin
        $monitor("op1=%h, op2=%h, funct=%h, result=%h", op1, op2, funct, result);
        for (int op = 0; op < 8; op = op + 1) begin
            for (int i = 0; i < `MAX_32; i = i + 1) begin
                for (int j = 0; j < `MAX_32; j = j + 1) begin
                    op1 = i;
                    op2 = j;
                    funct = op;
                    #1;
                end
            end
        end
        $finish;
    end

endmodule