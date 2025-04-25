`default_nettype none

module MMM_tb #(
    parameter  INW              = 32,
    parameter  OUTW             = 32,
    parameter  M                = 2,
    parameter  N                = 3,
    parameter  MAXK             = 9,    
    localparam K_BITS           = $clog2(MAXK+1),
    localparam A_ADDR_BITS      = $clog2(M*MAXK),
    localparam B_ADDR_BITS      = $clog2(MAXK*N),
    localparam OUT_ADDR_BITS    = $clog2(M*N)
)();

    logic                       clk;
    logic                       reset;

    logic [INW-1:0]             K_in;
    logic                       start_mmm;
    logic                       wait_mmm_finish;

    logic [INW-1:0]             mata_data;
    logic [INW-1:0]             matb_data;
    logic [A_ADDR_BITS-1:0]     mata_rdaddr;
    logic [B_ADDR_BITS-1:0]     matb_rdaddr;

    logic [INW-1:0]             outmat_data;
    logic [OUT_ADDR_BITS-1:0]   outmat_wraddr;
    logic                       outmat_wren;

    logic                       stall;

    logic [INW-1:0] mata_mem    [(M*MAXK)-1:0];
    logic [INW-1:0] matb_mem    [(MAXK*N)-1:0];
    logic [INW-1:0] matout_mem  [(MAXK*N)-1:0];

    initial clk   = 0;
    always #5 clk  = ~clk;

    initial begin
        //reset
        reset           = 1;
        wait_mmm_finish = 0;
        start_mmm       = 0;
        @(posedge clk);
        @(posedge clk);

        //preload values into the input matrices
        K_in      = 9;
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
        
        $finish;
    end

    always_ff @(posedge clk) begin
        mata_data <= mata_mem[mata_rdaddr];
        matb_data <= matb_mem[matb_rdaddr];
    end
    
    always_ff @(posedge clk) begin
        if(outmat_wren)
            matout_mem[outmat_wraddr] <= outmat_data;
    end

    MMM_wrapper #(.INW(INW), .OUTW(OUTW), .M(M), .N(N), .MAXK(MAXK)) MMM_wrapper(.*);

endmodule