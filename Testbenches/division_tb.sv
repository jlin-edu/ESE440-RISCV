`include "inst_defs.sv"

module division_tb;

    logic unsigned [`REG_RANGE] dividend_tb, divisor_tb, quotient_tb, remainder_tb;
    logic status_tb, reset_tb, clk_tb, start_tb, divide_by_zero_tb, overflow_tb;

    division_wrapper UUT (
        .dividend(dividend_tb),
        .divisor(divisor_tb),
        .quotient(quotient_tb),
        .remainder(remainder_tb),
        .status(status_tb),
        .reset(reset_tb),
        .clk(clk_tb),
        .start(start_tb),
        .divide_by_zero(divide_by_zero_tb),
        .overflow(overflow_tb)
    );

    initial clk_tb = 0;
    always #5 clk_tb = ~clk_tb;

    initial begin
        dividend_tb = 0;
        divisor_tb = 0;
        start_tb = 0;
        reset_tb = 0;

        @(posedge clk_tb);
        reset_tb = 1;
        @(posedge clk_tb);
        reset_tb = 0;

        for (longint i = 1; i < 2**32; i++) begin
            for (int j = 1; j < 2**16 && j <= i; j++) begin
                dividend_tb = i;
                divisor_tb = j;
                @(posedge clk_tb);
                start_tb = 1;
                @(posedge clk_tb);
                start_tb = 0;
                do @(posedge clk_tb); while (status_tb == 1);
                if (quotient_tb != i / j)
                    $display("ERROR: incorrect quotient for z = %0d, d = %0d. Got %0d, expected %0d", dividend_tb, divisor_tb, quotient_tb, i / j);
                if (remainder_tb != i % j)
                    $display("ERROR: incorrect remainder for z = %0d, d = %0d. Got %0d, expected %0d", dividend_tb, divisor_tb, remainder_tb, i % j);
            end
        end
        $finish;
    end
endmodule