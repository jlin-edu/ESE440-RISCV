module mac_pipe #(
    parameter  INW     = 32,
    parameter  OUTW    = 32,
    localparam MINVAL  = (32'd1<<(OUTW-1)),
    localparam MAXVAL  = (32'd1<<(OUTW-1))-1
)(
    input  signed       [INW-1:0]  in0, in1,
    output logic signed [OUTW-1:0] out,
    input clk, reset, clear_acc, valid_input
);
    logic signed [(2*INW)-1:0]  product_regin, product_regout; 
    logic signed [OUTW-1:0] sum, saturated_sum;
    logic valid_input_regout;

    // designware pipeline 
    //DW02_mult_3_stage #(INW, INW) mult_inst (in0, in1, 1'b1, clk, product_regin);

    always_comb begin
        product_regin = in0 * in1;
        sum           = product_regout + out;
    end

    //saturation logic
    always_comb begin
        saturated_sum = sum;
        if ((product_regout[(2*INW)-1] == 0) & (out[OUTW-1] == 0) & (sum[OUTW-1] == 1)) begin
            saturated_sum = MAXVAL;
        end
        else if ((product_regout[(2*INW)-1] == 1) & (out[OUTW-1] == 1) & (sum[OUTW-1] == 0)) begin
            saturated_sum = MINVAL;
        end
    end

    always_ff @(posedge clk) begin
        if (reset == 1) begin
            product_regout     <= 0;
            valid_input_regout <= 0;
        end
        else begin
            product_regout     <= product_regin;
            valid_input_regout <= valid_input;
        end
    end

    always_ff @(posedge clk) begin
        if (reset == 1) 
            out <= 0; 
        else if (clear_acc == 1) 
            out <= 0;
        else if (valid_input_regout == 1) 
            out <= saturated_sum;
    end

endmodule