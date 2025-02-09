

module singlecycle #(
    parameter  WIDTH=32,
    parameter  REG_FILE_SIZE=32,
    localparam REG_FILE_LOGSIZE=$clog2(REG_FILE_SIZE),
    parameter  INSTR_MEM_SIZE=64, //holds 64, 32-bit instructions
    localparam INSTR_MEM_LOGSIZE=$clog2(INSTR_MEM_SIZE),
    parameter  DATA_MEM_SIZE=
)(
    input clk, reset,

    //used when filling up instruction memory
    input [`REG_RANGE] write_data,   //for filling instruction memory
    input [`REG_RANGE] write_address,
    input write_enable,
);
    //Instruction Decode Signals
    logic [`REG_RANGE] jmp_addr;
    logic [`REG_RANGE] pc, pc_4;
    logic              pc_sel;

    PC pc_singlecycle(.*);

    //need to edit the parameters for this probably
    //logic [`REG_RANGE] write_data, write_addr;  //actually, this is provided by input port, not internal conenctions
    logic [`REG_RANGE] instruction_out;
    InstructionMem #() instr_mem_singlecycle(.data_out(instruction_out), .);


    //Instruction Fetch Signals



endmodule