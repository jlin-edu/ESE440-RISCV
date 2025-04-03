`include "inst_defs.sv"
// Different Division Algorihms
// Inputs: dividend = z (32 bits), divisor = d (32 bits, but should be 16 bits), start (1 bit)
// Outputs: quotient = q (32 bits, but will be 16), remainder = s (32 bits, but will be 16), running (1 bit)

module division_wrapper (
    input logic [`REG_RANGE] dividend, divisor,
    input logic start, reset, clk, signed_div,
    output logic [`REG_RANGE] quotient, remainder,
    output logic status, finished;
    );

    logic unsigned [`REG_RANGE] dividend_u, divisor_u, quotient_u, remainder_u;
    logic start_wrap, sign;

    restoring_division divider (
        .dividend(dividend_u),
        .divisor(divisor_u),
        .start(start_wrap),
        .reset(reset),
        .clk(clk),
        .quotient(quotient_u),
        .remainder(remainder_u),
        .status(status)
    );

    always_comb begin
        if (divisor)
            start_wrap = start;
            
        sign = dividend[`REG_SIZE-1] ^ divisor[`REG_SIZE-1];
        dividend_u = (signed_div && dividend[`REG_SIZE-1]) ? ~dividend + 1 : dividend;
        divisor_u = (signed_div && divisor[`REG_SIZE-1]) ? ~divisor + 1 : divisor;

        if (divisor) begin
            quotient = (signed_div && sign) ? ~quotient_u + 1 : quotient_u;
            remainder = (signed_div && dividend[`REG_SIZE-1]) ? ~remainder_u + 1 : remainder_u;
        end else begin
            quotient = -1;
            remainder = dividend;
        end
    end
endmodule




// Restoring division algorithm.
// Time: 32 cycles
// Size: 3 32-bit register, add/subtrator
module restoring_division (
    input logic unsigned [`REG_RANGE] dividend, divisor,
    input logic start, reset, clk,
    output logic unsigned [`REG_RANGE] quotient, remainder,
    output logic status
    );  

    logic [`REG_RANGE] dividend_reg_high, dividend_reg_low, divisor_reg;
    logic [`REG_FIELD_RANGE] counter_reg;
    logic status_reg, finished_reg;

    logic [`REG_RANGE] shift, result;
    logic [`REG_SIZE:0] sub;
    logic q;

    always_ff @(posedge clk) begin
        if (reset) begin
            dividend_reg_high <= 0;
            dividend_reg_low <= 0;
            divisor_reg <= 0;

            status_reg <= 0;
            finished_reg <= 0;
            counter_reg <= 0;
        end
        else if (!status_reg && !finished_reg && start) begin
            status_reg <= 1;
            finished_reg <= 0;
            counter_reg <= 0;
            dividend_reg_high <= 0;
            dividend_reg_low <= dividend;
            divisor_reg <= divisor;
        end
        else if (status_reg) begin
            dividend_reg_high <= result;
            dividend_reg_low <= {dividend_reg_low[`REG_SIZE-2:0], q};

            counter_reg <= counter_reg + 1;
            if (counter_reg == 31) begin
                status_reg <= 0;
                finished_reg <= 1;
            end
        end
        else if (finished_reg) begin
            finished_reg <= 0;
        end
    end

    always_comb begin
        shift = {dividend_reg_high[`REG_SIZE-2:0], dividend_reg_low[`REG_SIZE-1]};
        sub = shift - divisor_reg;
        q = dividend_reg_high[`REG_SIZE-1] || ~sub[`REG_SIZE];
        result = (q) ? sub[`REG_SIZE-1:0] : shift;

        quotient = dividend_reg_low;
        remainder = dividend_reg_high;
        status = status_reg;
        finished = finished_reg;
    end

endmodule