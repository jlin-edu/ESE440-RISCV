`include "inst_defs.sv"

module single_cycle #(
    parameter                   WIDTH=32, SIZE=64,         //WIDTH is bits per word(shouldn't be changed), SIZE is # of WORDS
    localparam                  LOGSIZE=$clog2(SIZE)
)(
    //instruction memory write port
    input [WIDTH-1:0]           instr_in,       //the write port should only be used for filling the memory with instructions in a testbench
    input [(LOGSIZE-1)+2:0]     instr_wr_addr, 
    input instr_wr_en,

    //y'know
    input clk, reset
);
    //Instruction Fetch Signals
    logic [`REG_RANGE] jump_addr;   //IF Input(Provided by EX Stage Mux)
    logic pc_sel;                   //IF Input(Provided by EX Stage ALU)
    logic [`REG_RANGE] pc, pc_4, instruction;    //IF Outputs(ID uses instruction, EX uses PC, WB uses PC+4)

    instruction_fetch #(.WIDTH(WIDTH), .SIZE(SIZE)) IF(.clk(clk), .reset(reset),
                                                        .jump_addr(jump_addr), .pc_sel(pc_sel),
                                                        .pc(pc), .pc_4(pc_4), .instruction(instruction),
                                                        .instr_in(instr_in), .wr_addr(instr_wr_addr), .wr_en(instr_wr_en));

    //Instruction Decode Signals
    //Inputs: IF Stage instruction, IF Stage Program Counter, WB Stage
    logic [`REG_RANGE] reg_wr_data; //ID Input (Provided by WB stage mux)

    logic [`REG_RANGE] in1, in2;    //ID Output (Used by EX Stage ALU)
    logic [`REG_RANGE] immediate;   //ID Output (Used by EX Stage branch adder) should we just compute pc+immediate in ID so we dont need to propogate the signal through another stage?
    logic jump_branch_sel;   //ID Output (Used in EX Stage to select between branch address or jump address)
    logic mem_wr_en;         //ID Output (Used in MEM Stage to enable a store instruction)
    logic [1:0] reg_write_ctrl;     //ID Output (Used in WB Stage to select what data gets written to the RegFile; 0 for ALU output, 1 is for pc+4 for JAL, 2 is memory load operations)

    instruction_decode #(.WIDTH(WIDTH)) ID(.clk(clk), .reset(reset),
                                            .instruction(instruction), .pc(pc), .reg_wr_data(reg_wr_data),
                                            .in1(in1), .in2(in2), .immediate(immediate),
                                            .jump_branch_sel(jump_branch_sel), .mem_wr_en(mem_wr_en), .reg_write_ctrl(reg_write_ctrl));

    //Execute Signals
    //Inputs
    

endmodule


module single_cycle_tb ();
    parameter   WIDTH=32, SIZE=64;
    localparam  LOGSIZE=$clog2(SIZE);

    logic [WIDTH-1:0] instr_in;
    logic [(LOGSIZE-1)+2:0] instr_wr_addr;
    logic instr_wr_en;

    logic clk, reset;
    initial clk  = 0;
    always #5 clk  = ~clk;

    single_cycle #(.WIDTH(WIDTH), .SIZE(SIZE)) dut(.clk(clk), .reset(reset),
                                                    .instr_in(instr_in), .instr_wr_addr(instr_wr_addr), .instr_wr_en(instr_wr_en));

    logic [31:0] testData[20:0];
    initial $readmemb("data.txt", testData);

    integer i;
    initial begin
        //@(posedge clk);
        for(i=0; i<10; i=i+1) begin
            instr_in = testData[i][31:0];     
            instr_wr_addr = i*4;            //the i*4 is a left shift twice since we are indexing by word
            instr_wr_en = 1;
            @(posedge clk);
        end

        #1; reset = 1; instr_in = 0; instr_wr_addr = 0; instr_wr_en = 0;
        @(posedge clk);

        #1; reset = 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        $finish;
    end
endmodule