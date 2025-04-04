module addr_ctr #(
    parameter  INW              = 32,
    parameter  OUTW             = 32,
    parameter  M                = 6,
    parameter  N                = 6,
    parameter  MAXK             = 6,
    localparam K_BITS           = $clog2(MAXK+1),
    localparam A_ADDR_BITS      = $clog2(M*MAXK),
    localparam B_ADDR_BITS      = $clog2(MAXK*N),
    localparam OUT_ADDR_BITS    = $clog2(M*N)
)(
    input clk, reset,

    input [K_BITS-1:0] K,
    input incr_acc, incr_outaddr,   //incr_outaddr is the same signal as outmat_wren, because whenever we want to write we also want to move to next address on same cycle
                                    //remember to feed incr_outaddr the delayed pipelined output of outmat_wren so write and incr occur on same cycle

    output logic [A_ADDR_BITS-1:0]      A_addr,
    output logic [B_ADDR_BITS-1:0]      B_addr,
    output logic [OUT_ADDR_BITS-1:0]    out_addr,

    //Control for FSM
    output logic last_acc, last_index,

    output logic compute_finished
);
    logic [$clog2(M)-1:0] output_row_index;         //essentially the outermost loop, goes from 0 to M-1
    logic [$clog2(N)-1:0] output_col_index;         //essentially the middle loop, goes from 0 to N-1, increments, cleared when N-1 and K-1 is reached and increments the row
    logic [K_BITS-1:0]    accumulate_iteration;     //essentially the innermost loop, goes from 0 to K-1, increments every clock, cleared when K-1 is reached and data is written

    logic last_acc, last_col, last_row;
    assign last_acc = (accumulate_iteration == K-1) ? 1 : 0;
    assign last_col = (output_col_index == N-1) ? 1 : 0;
    assign last_row = (output_row_index == M-1) ? 1 : 0;

    logic incr_col, incr_row;
    assign incr_col = (incr_acc && last_acc) ? 1 : 0;
    assign incr_row = (incr_acc && last_acc && last_col) ? 1 : 0;
    always_ff @(posedge clk) begin
        //accumulation counter for every index
        if(reset)
            accumulate_iteration <= 0;
        else if(incr_acc == 1) begin
            if(last_acc == 1)
                accumulate_iteration <= 0;
            else
                accumulate_iteration <= accumulate_iteration+1;
        end

        //counter for which column of output matrix we are computing
        if(reset)
            output_col_index <= 0;
        else if(incr_col == 1)begin
            if(last_acc == 1) 
                output_col_index <= 0;
            else
                output_col_index <= output_col_index+1;
        end

        //counter for which row of output matrix we are computing
        if(reset)
            output_row_index <= 0;
        else if(incr_row == 1) begin
            if(last_row == 1)
                output_row_index <= 0;
            else 
                output_row_index <= output_row_index+1;
        end

        //counter for which index of output matrix we are writing to
        if(reset)
            out_addr <= 0;
        else if(incr_outaddr == 1) begin
            if(last_index == 1)
                out_addr <= 0;
            else
                out_addr <= out_addr+1;
        end
    end

    assign compute_finished = (incr_outaddr & last_index);
    assign last_index = (last_col & last_row);
    assign A_addr = accumulate_iteration+(output_row_index*K);
    assign B_addr = output_col_index+(accumulate_iteration*N);

endmodule