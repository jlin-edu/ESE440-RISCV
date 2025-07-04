`include "inst_defs.sv"

module instruction_fetch #(
    parameter                   WIDTH=32, SIZE=256, NUM_COL=4,         //WIDTH is bits per word(shouldn't be changed), SIZE is # of WORDS
    localparam                  LOGSIZE=$clog2(SIZE)
)(
    //From External stages
    input [`REG_RANGE] jump_addr_EXIF,       //Provided from EX Stage(Mux)
    input pc_sel_EXIF,                       //Provided from EX Stage(ALU)

    //for write port of instruction memory
    input [WIDTH-1:0]           instr_in,
    input [(LOGSIZE-1)+2:0]     wr_addr, 
    input [NUM_COL-1:0]         wr_en,

    //the dynamic duo
    input clk_in, clk, reset,

    input stall,    //hazard handling
    input mmm_stall, //when mmm_stall is asserted then we want stage outputs to be unchanged

    //outputs of IF, inputs of other stages (ID uses instruction, EX uses PC, WB uses PC+4)
    output logic [`REG_RANGE] pc_IFID, pc_4_IFID, instruction_IFID, AXI_data_out
);
    logic [`REG_RANGE] pc_IF, pc_4_IF;
    
    PC pc_module(.clk(clk), .reset(reset), .stall(stall),
                .pc_sel(pc_sel_EXIF), .jump_addr(jump_addr_EXIF),
                .pc(pc_IF), .pc_4(pc_4_IF),
                .mmm_stall(mmm_stall));

    logic instr_wr_en;
    assign instr_wr_en = wr_en[0];
    instr_memory #(.WIDTH(WIDTH), .SIZE(SIZE)) instruction_buffer(.clk(clk_in), .reset(reset), .stall(stall),
                                                                .pc(pc_IF), .instr_out(instruction_IFID),
                                                                .instr_in(instr_in), .AXI_addr(wr_addr), .wr_en(instr_wr_en), .flush(pc_sel_EXIF),
                                                                .AXI_data_out(AXI_data_out),
                                                                .mmm_stall(mmm_stall));

    //pipeline register
    //is the reset even nessecary? If the instruction memory is replaced with a NOP then shouldn't pc and pc+4 be irrelevant?
    always_ff @(posedge clk) begin
        if((reset == 1) || (pc_sel_EXIF == 1)) begin
            pc_IFID   <= 0;
            pc_4_IFID <= 0;
        end
        else if((stall == 0) && (mmm_stall == 0)) begin
            pc_IFID   <= pc_IF;
            pc_4_IFID <= pc_4_IF;
        end
    end

endmodule