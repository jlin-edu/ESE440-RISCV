`include "inst_defs.sv"

module instruction_fetch #(
    parameter                   WIDTH=32, SIZE=256,         //WIDTH is bits per word(shouldn't be changed), SIZE is # of WORDS
    localparam                  LOGSIZE=$clog2(SIZE)
)(
    //From External stages
    input [`REG_RANGE] jump_addr_EXIF,       //Provided from EX Stage(Mux)
    input pc_sel_EXIF,                       //Provided from EX Stage(ALU)

    //for write port of instruction memory
    input [WIDTH-1:0]           instr_in,
    input [(LOGSIZE-1)+2:0]     wr_addr, 
    input wr_en,

    //the dynamic duo
    input clk, reset,

    //outputs of IF, inputs of other stages (ID uses instruction, EX uses PC, WB uses PC+4)
    output logic [`REG_RANGE] pc_IFID, pc_4_IFID, instruction_IFID
);
    
    PC pc_module (.clk(clk), .reset(reset),
                .pc_sel(pc_sel_EXIF), .jump_addr(jump_addr_EXIF),
                .pc(pc_IFID), .pc_4(pc_4_IFID));

    instr_memory #(.WIDTH(WIDTH), .SIZE(SIZE)) instruction_buffer(.clk(clk), .pc(pc_IFID), .instr_out(instruction_IFID),
                                                                .instr_in(instr_in), .wr_addr(wr_addr), .wr_en(wr_en));
endmodule
