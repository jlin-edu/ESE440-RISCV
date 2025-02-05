`include "inst_defs.sv"

module data_memory #(   
    parameter                   WIDTH=32, SIZE=256,         //WIDTH is bits per word, SIZE is # of WORDS
    localparam                  LOGSIZE=$clog2(SIZE)
)(
    input [WIDTH-1:0]           data_in,
    output logic [WIDTH-1:0]    data_out,
    //input [(LOGSIZE-1)+2:0]     addr,       //need plus 2 bits because the bottom 2 bits are byte offsets
    input [`REG_RANGE]          addr,
    input                       clk, wr_en,
    //input [`OP_SIZE]            opcode,
    input [`FUNCT_3_RANGE]      funct3
);

    logic [SIZE-1:0][WIDTH-1:0] mem;

    logic [LOGSIZE-1:0] word_offset;
    logic [1:0] byte_offset;
    
    assign addr[31:(LOGSIZE-1)+2] = 0; 
    assign word_offset = addr[(LOGSIZE-1)+2:2];
    assign byte_offset = addr[1:0];
    
    always_ff @(posedge clk) begin
        //data_out <= mem[addr];

        //note that misaligned stores are not supported
        //able to load byte from any location without restriction
        //only able to load half-word from %2 address locations
        //only able to load words from %4 address locations
        if (wr_en) begin
            case(funct3)
                `SW:  mem[word_offset]       <= data_in;
                `SH:  mem[word_offset][(8*byte_offset) +: 16] <= data_in[15:0];
                `SB:  mem[word_offset][(8*byte_offset) +: 8]  <= data_in[7:0];
            endcase
        end
    end

    //read logic
    always_comb begin
        //note that misaligned loads and stores are not supported
        //able to load byte from any location without restriction
        //only able to load half-word from %2 address locations
        //only able to load words from %4 address locations
        case(funct3)
            `LW:  data_out = mem[word_offset];
            `LH:  data_out = 32'(signed'(mem[word_offset][(8*byte_offset) +: 16]));
            `LB:  data_out = 32'(signed'(mem[word_offset][(8*byte_offset) +: 8]));
            `LHU: data_out = mem[word_offset][(8*byte_offset) +: 16];
            `LBU: data_out = mem[word_offset][(8*byte_offset) +: 8];
            default: begin
                //ASSERT STATEMENT
                data_out = 0;
            end
        endcase
    end
endmodule
