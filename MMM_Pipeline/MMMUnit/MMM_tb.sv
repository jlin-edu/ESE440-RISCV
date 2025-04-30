`default_nettype none

module MMM_tb #(
    parameter  QUARTERSIZE      = 64,
    parameter  INW              = 32,
    parameter  OUTW             = 32,
    localparam M                = int'($sqrt(QUARTERSIZE)),       //M*N Must be less than quarter mem
    localparam N                = int'($sqrt(QUARTERSIZE)),
    localparam MAXK             = int'(QUARTERSIZE/M),       //M*MAXK and N*MAXK Must be less than quarter mem
    localparam K_BITS           = $clog2(MAXK+1),
    localparam A_ADDR_BITS      = $clog2(M*MAXK),
    localparam B_ADDR_BITS      = $clog2(MAXK*N),
    localparam OUT_ADDR_BITS    = $clog2(M*N),
    localparam LOGQUARTERSIZE   = $clog2(QUARTERSIZE)
)();

    logic                       clk;
    logic                       reset;

    logic [INW-1:0]             K_in;
    logic                       start_mmm;
    logic                       wait_mmm_finish;

    logic [INW-1:0]              mata_data;
    logic [INW-1:0]              matb_data;
    logic [LOGQUARTERSIZE-1:0]   rdaddr_mem1;
    logic [LOGQUARTERSIZE-1:0]   rdaddr_mem2;

    logic [INW-1:0]              outmat_data;
    logic [LOGQUARTERSIZE-1:0]   wraddr_mem3;
    logic                        outmat_wren;

    logic                       stall;

    logic [INW-1:0] mata_mem    [(QUARTERSIZE)-1:0];
    logic [INW-1:0] matb_mem    [(QUARTERSIZE)-1:0];
    logic [INW-1:0] matout_mem  [(QUARTERSIZE)-1:0];

    initial clk   = 0;
    always #5 clk  = ~clk;
    
    integer check_val = 0;

    initial begin
        //reset
        reset           = 1;
        wait_mmm_finish = 0;
        start_mmm       = 0;
        @(posedge clk);
        @(posedge clk);

        //preload values into the input matrices
        K_in      = 3;
        for(int i = 0; i<(M*K_in); i++) mata_mem[i] = i; 
        for(int i = 0; i<(K_in*N); i++) matb_mem[i] = (K_in*N)-i;


        //send start signal to MMM
        reset       = 0;
        start_mmm   = 1;
        @(posedge clk);
        
        start_mmm   = 0;
        wait_mmm_finish = 1;
        @(posedge clk);

        //run for several cycles until output matrix is done, then manually check values
        //wait_mmm_finish = 0;
        for(int i = 0; i<(M*N*K_in*2); i++) @(posedge clk);
        
        
        //self check values
        /*
        for(int i = 0; i < N-1; i++) begin
            for(int j = 0; j < M-1;j++) begin
                check_val = 0;
                for(int k = 0; k < K_in-1; k++) begin
                    check_val += mata_mem[k+(i*K_in)]*matb_mem[j+(k*N)];
                end
                `assert(matout_mem[(i*M)+j], check_val, (i*M)+j);
            end
        end
        */
        
        $finish;
    end

    always_ff @(posedge clk) begin
        mata_data <= mata_mem[rdaddr_mem1];
        matb_data <= matb_mem[rdaddr_mem2];
    end
    
    always_ff @(posedge clk) begin
        if(outmat_wren)
            matout_mem[wraddr_mem3] <= outmat_data;
    end

    MMM_wrapper #(.INW(INW), .OUTW(OUTW), .QUARTERSIZE(QUARTERSIZE)) MMM_wrapper(.*);

endmodule