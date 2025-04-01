`include "inst_defs.sv"

module division_tb;

    logic signed [`REG_RANGE] dividend_tb, divisor_tb, quotient_tb, remainder_tb;
    logic status_tb, reset_tb, clk_tb, signed_div_tb, start_tb, divide_by_zero_tb;

    division_wrapper UUT (
        .dividend(dividend_tb),
        .divisor(divisor_tb),
        .quotient(quotient_tb),
        .remainder(remainder_tb),
        .status(status_tb),
        .reset(reset_tb),
        .clk(clk_tb),
        .signed_div(signed_div_tb),
        .start(start_tb),
        .divide_by_zero(divide_by_zero_tb)
    );

    initial clk_tb = 0;
    always #5 clk_tb = ~clk_tb;

    initial begin
        dividend_tb = 0;
        divisor_tb = 0;
        start_tb = 0;
        reset_tb = 0;
        signed_div_tb = 1;

        @(posedge clk_tb);
        reset_tb = 1;
        @(posedge clk_tb);
        reset_tb = 0;

        for (longint i = 1; i < 2**31; i++) begin
            for (longint j = 1; j < 2**31 && j <= i; j++) begin
                for (int k = 1; k >= -1; k -= 2) begin
                    for (int l = 1; l >= -1; l -= 2) begin
                        dividend_tb = i*k;
                        divisor_tb = j*l;
                        @(posedge clk_tb);
                        start_tb = 1;
                        @(posedge clk_tb);
                        start_tb = 0;
                        do @(posedge clk_tb); while (status_tb == 1);
                        if (quotient_tb != (i*k) / (j*l))
                            $display("ERROR: incorrect quotient for z = %0d, d = %0d. Got %0d, expected %0d", dividend_tb, divisor_tb, quotient_tb, (i*k) / (j*l));
                        if (remainder_tb != (i*k) % (j*l))
                            $display("ERROR: incorrect remainder for z = %0d, d = %0d. Got %0d, expected %0d", dividend_tb, divisor_tb, remainder_tb, (i*k) % (j*l));
                    end
                end
            end
        end
        $finish;
    end
endmodule