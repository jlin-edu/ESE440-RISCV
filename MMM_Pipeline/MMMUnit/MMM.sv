`include "inst_defs.sv"

module MMM_fsm(
    input clk, reset,

    input compute_start,
    input last_acc, last_index,

    output logic load_K,                        //load in new k
    output logic incr_inaddr,                   //address counter control signals
    output logic valid_input, clear_acc,        //mac control signals
    output logic outmat_wren,                   //write control signal
   // output logic compute_finished               //needs to be pipelined twice to match up with the wren
                                                 //actually we can generate this signal through datapath inside counters instead
);

    enum logic[1:0] {idle, accumulate, write_output, finished} current_state, next_state;

    //next state logic
    always_comb begin
        next_state = idle;  //default case

        //idle state transitions
        if((current_state == idle) && (compute_start == 0))
            next_state = idle;
        else if((current_state == idle) && (compute_start == 1))
            next_state = accumulate;
        //accumulate state transitions
        else if((current_state == accumulate) && (last_acc == 0))
            next_state = accumulate;
        else if((current_state == accumulate) && (last_acc == 1))
            next_state = write_output;
        //write_output transitions
        else if((current_state == write_output) && (last_index == 0))
            next_state = accumulate;
        else if((current_state == write_output) && (last_index == 1))
            next_state = finished;
        //finished output transitions(needed because we need to wait for last data to be written )
        else if((current_state == finished) && (compute_start == 1))
            next_state = finished;
        else if((current_state == finished) && (compute_start == 0))
            next_state = idle;
    end

    //current state logic
    always_ff @(posedge clk) begin
        if(reset)
            current_state <= idle;
        else
            current_state <= next_state;
    end

    //output logic
    always_comb begin
        load_K           = 0;
        incr_inaddr      = 0;   //default case
        valid_input      = 0;
        clear_acc        = 0;
        outmat_wren      = 0;
        //compute_finished = 0;

        //idle state transitions
        if((current_state == idle) && (compute_start == 0)) begin
            load_K           = 0;
            incr_inaddr      = 0;   //default case
            valid_input      = 0;
            clear_acc        = 0;
            outmat_wren      = 0;
            //compute_finished = 0;
        end
        else if((current_state == idle) && (compute_start == 1)) begin
            load_K           = 1;
            incr_inaddr      = 1;
            valid_input      = 1;
        end
        //accumulate state transitions
        else if((current_state == accumulate) && (last_acc == 0)) begin
            incr_inaddr      = 1;
            valid_input      = 1;
        end
        else if((current_state == accumulate) && (last_acc == 1)) begin
            incr_inaddr      = 0;   //don't increment(clear) so upon state transition we can check if this was the last index
            valid_input      = 1;
        end
        //write output state transitions
        else if((current_state == write_output) && (last_index == 0)) begin
            incr_inaddr      = 1;   //clear the counters (handled in the datapath)
            outmat_wren      = 1;   //write the data into data memory
            clear_acc        = 1;   //clear the accumulator
            valid_input      = 0;   //the current data is invalid
            //compute_finished = 0;
        end
        else if((current_state == write_output) && (last_index == 1)) begin
            incr_inaddr      = 1;   //clear the read address counters (handled in the datapath)
            outmat_wren      = 1;   //write the data into data memory and also clear write address counter (handled in datapath)
            clear_acc        = 1;   //clear the accumulator
            valid_input      = 0;   //the current data is invalid
            //compute_finished = 1;
        end
        //finished state transitions
        else if((current_state == write_output) && (compute_start == 1)) begin
            load_K           = 0;
            incr_inaddr      = 0;   //default case
            valid_input      = 0;
            clear_acc        = 0;
            outmat_wren      = 0;
            //compute_finished = 0;
        end
        else if((current_state == write_output) && (compute_start == 0)) begin
            load_K           = 0;
            incr_inaddr      = 0;   //default case
            valid_input      = 0;
            clear_acc        = 0;
            outmat_wren      = 0;
            //compute_finished = 0;
        end

    end

endmodule

module MMM #(
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

    input [K_BITS-1:0] new_K,   //remember to add a flipflop for K value
    input compute_start,        //generated by that set/clr flipflop

    input [INW-1:0]  mata_data, matb_data,
    output logic [A_ADDR_BITS-1:0] mata_rdaddr,
    output logic [B_ADDR_BITS-1:0] matb_rdaddr,

    output logic [INW-1:0] outmat_data,             
    output logic [OUT_ADDR_BITS-1:0] outmat_wraddr,  //delay the address, and wren by 1 cycle because of pipeline
    output logic outmat_wren,

    output logic compute_finished       //can be asserted by checking if last_index is asserted and wr_en is asserted(this means we are writing the last index on next cycle)
); 
    logic [K_BITS-1:0] K;
    logic load_K;

    logic incr_inaddr;
    logic last_acc;
    logic last_index;


    //delayed signals to align memor writes with valid data
    logic wren_pipein;
    logic clear_acc_pipein;
    logic valid_input_pipein;

    logic wren_pipeout;
    logic clear_acc_pipeout;
    logic valid_input_pipeout;
    logic wren_pipeout2;
    logic clear_acc_pipeout2;

    //fsm goes here
    MMM_fsm MMM_fsm(.clk(clk),
                    .reset(reset),
                    
                    //inputs
                    .compute_start(compute_start),
                    .last_acc(last_acc),
                    .last_index(last_index),
                    
                    //outputs
                    .load_K(load_K),

                    .incr_inaddr(incr_inaddr),
                    .outmat_wren(wren_pipein),

                    .valid_input(valid_input_pipein),
                    .clear_acc(clear_acc_pipein));


    //load new value of k
    always_ff @(posedge clk) begin
        if(reset)
            K <= 0;
        else if(load_K == 1)
            K <= new_K;
    end

    //delay signals appropriately (probably also need to delay the compute finished signal to line up with wren_pipeout2)
    always_ff @(posedge clk) begin
        if(reset) begin
            wren_pipeout         <= 0;
            clear_acc_pipeout    <= 0;
            valid_input_pipeout  <= 0;
        end
        else begin
            wren_pipeout         <= wren_pipein;
            clear_acc_pipeout    <= clear_acc_pipein;
            valid_input_pipeout  <= valid_input_pipein;
        end
    end

    always_ff @(posedge clk) begin
        if(reset) begin
            wren_pipeout2       <= 0;
            clear_acc_pipeout2  <= 0;
        end 
        else begin
            wren_pipeout2       <= wren_pipeout;
            clear_acc_pipeout2  <= clear_acc_pipeout;
        end
    end

    assign outmat_wren = wren_pipeout2;

    //handle an exception when K=0? just don't start and immediately clear the start input

    addr_ctr #(.*) addr_ctr(.clk(clk),
                            .reset(reset),
                            
                            //inputs
                            .K(K),
                            .incr_acc(incr_inaddr),
                            .incr_outaddr(wren_pipeout2),
                            
                            //outputs
                            .A_addr(mata_rdaddr),
                            .B_addr(matb_rdaddr),
                            .out_addr(outmat_wraddr),
                            
                            .last_acc(last_acc),
                            .last_index(last_index),
                            .compute_finished(compute_finished));

    mac_pipe #(.*) mac_pipe(.clk(clk),
                            .reset(reset),
                            
                            //inputs
                            .in0(mata_data),
                            .in1(matb_data),
                            .clear_acc(clear_acc_pipeout2),
                            .valid_input(valid_input_pipeout),
                            
                            //outputs
                            .out(outmat_data));

endmodule