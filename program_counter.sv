`include "inst_defs.sv"

module PC (
    input [`REG_RANGE] jump_addr,
    input pc_sel, clk, reset,
    output logic [`REG_RANGE] pc, pc_4
);

    always_comb begin
        pc_4 = pc + 4;
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            pc <= 0;
        end else if (pc_sel) begin
            pc <= jump_addr;
        end else begin
            pc <= pc_4;
        end
    end

endmodule