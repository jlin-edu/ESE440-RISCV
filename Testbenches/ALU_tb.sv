`include "inst_defs.sv"

module ALU_tb ();

    logic signed [`REG_RANGE] in1, in2, out;
    logic [`FUNCT_7_RANGE] funct_7;
    logic [`FUNCT_3_RANGE] funct_3,
    logic [`OP_RANGE] op;
    logic pc_sel;

    alu UUT (
        .in1(in1),
        .in2(in2),
        .funct_3(funct_3),
        .funct_7(funct_7),
        .op(op),
        .pc_sel(pc_sel),
        .out(out)
    );

    initial begin
        $monitor("in1=%h, in2=%h, funct3=%b, funct7=%b, op=%b, pc_sel=%b, out=%h", in1, in2, funct_3, funct_7, op, pc_sel, out);

        op      = 7'b0000000;
        funct_3 = 3'b000;
        funct_7 = 7'b0000000;
        for (int i = 0; i < `MAX_32; i = i + 1) begin
            for (int j = 0; j < `MAX_32; j = j + 1) begin
                in1 = i;
                in2 = j;
                #1;
            end
        end
        
        $finish;
    end

endmodule