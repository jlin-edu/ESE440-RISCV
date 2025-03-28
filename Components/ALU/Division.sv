`include "inst_defs.sv"
// Different Division Algorihms
// Inputs: dividend = z (32 bits), divisor = d (32 bits, but should be 16 bits), start (1 bit)
// Outputs: quotient = q (32 bits, but will be 16), remainder = s (32 bits, but will be 16), running (1 bit)

module division_wrapper (
    input logic unsigned [`REG_RANGE] dividend, divisor,
    input logic start, reset, clk,
    output logic unsigned [`REG_RANGE] quotient, remainder,
    output logic status, divide_by_zero, overflow
);

    logic start_wrap;

    restoring_division divider (
        .dividend(dividend),
        .divisor(divisor),
        .start(start_wrap),
        .reset(reset),
        .clk(clk),
        .quotient(quotient),
        .remainder(remainder),
        .status(status)
    );

    always_comb begin
        overflow = 0;
        divide_by_zero = 0;
        if (divisor == 0)
            divide_by_zero = 1;
        else if (dividend[`REG_SIZE-1:(`REG_SIZE/2)-1] > divisor)
            overflow = 1;
        else
            start_wrap = start;
    end


endmodule




// Restoring division algorithm.
// Time: 32 cycles
// Size: 3, 32-bit registers, add/subtrator
module restoring_division (
    input logic unsigned [`REG_RANGE] dividend, divisor,
    input logic start, reset, clk,
    output logic unsigned [`REG_RANGE] quotient, remainder,
    output logic status
    );  

    logic [(`REG_SIZE/2)-1:0] dividend_reg_high, dividend_reg_low, divisor_reg;
    logic [4:0] counter_reg;
    logic status_reg;

    logic [(`REG_SIZE/2)-1:0] shift, result;
    logic [`REG_SIZE/2:0] sub;
    logic q;

    always_ff @(posedge clk) begin
        if (reset) begin
            dividend_reg_high <= 0;
            dividend_reg_low <= 0;
            divisor_reg <= 0;

            status_reg <= 0;
            counter_reg <= 0;
        end
        else if (!status && start) begin
            status_reg <= 1;
            counter_reg <= 0;
            dividend_reg_high <= dividend[`REG_SIZE-1:(`REG_SIZE/2)-1];
            dividend_reg_low <= dividend[(`REG_SIZE/2)-1:0];
            divisor_reg <= divisor[(`REG_SIZE/2)-1:0];
        end
        else if (status) begin
            dividend_reg_high <= result;
            dividend_reg_low <= {dividend_reg_low[(`REG_SIZE/2)-2:0], q};

            counter_reg <= counter_reg + 1;
            if (counter_reg == 15) begin
                status_reg <= 0;
            end
        end
    end

    always_comb begin
        shift = {dividend_reg_high[(`REG_SIZE/2)-2:0], dividend_reg_low[(`REG_SIZE/2)-1]};
        sub = shift - divisor_reg;
        q = dividend_reg_high[(`REG_SIZE/2)-1] || ~sub[`REG_SIZE/2];
        if (q == 0) begin
            result = shift;
        end
        else begin
            result = sub[(`REG_SIZE/2)-1:0];
        end

        quotient = {16'b0 , dividend_reg_low};
        remainder = {16'b0 , dividend_reg_high};
        status = status_reg;
    end

endmodule