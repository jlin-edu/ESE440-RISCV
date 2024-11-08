`include "inst_defs.sv"

module data_memory #(   
    parameter                   WIDTH=32, SIZE=256,         //WIDTH is bits per word, SIZE is # of WORDS
    localparam                  LOGSIZE=$clog2(SIZE)
)(
    input [WIDTH-1:0]           data_in,
    output logic [WIDTH-1:0]    data_out,
    input [(LOGSIZE-1)+2:0]     addr,       //need plus 2 bits because the bottom 2 bits are byte offsets
    input                       clk, wr_en,
    //input [`OP_SIZE]            opcode,
    input [`FUNCT_3_RANGE]      funct3
);

    logic [SIZE-1:0][WIDTH-1:0] mem;

    logic [LOGSIZE-1:0] word_offset;
    logic [1:0] byte_offset;

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
                `SH:  mem[word_offset][(8* byte_offset) +: 16]  <= data_in[15:0];
                `SB:  mem[word_offset][(8* byte_offset) +: 8]  <= data_in[7:0];
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
            `LH:  data_out = 32'(signed'(mem[word_offset][(8* byte_offset) +: 16] ));
            `LB:  data_out = 32'(signed'(mem[word_offset][(8* byte_offset) +: 8] ));
            `LHU: data_out = mem[word_offset][(8* byte_offset) +: 16] ;
            `LBU: data_out = mem[word_offset][(8* byte_offset) +: 8] ;
            default: begin
                //ASSERT STATEMENT
                data_out = 0;
            end
        endcase
    end
endmodule

module mem_tb ();
    parameter  WIDTH=32,SIZE=16;     //in terms of words
    localparam LOGSIZE=$clog2(SIZE);

    logic [WIDTH-1:0]        data_in;
    logic [WIDTH-1:0]        data_out;
    logic [(LOGSIZE-1)+2:0]  addr;
    logic                    clk, wr_en;
    //input [`OP_SIZE]            opcode,
    logic [`FUNCT_3_RANGE]   funct3;

    initial clk=0;
    always #5 clk = ~clk;

    data_memory #(.WIDTH(WIDTH), .SIZE(SIZE)) UUT(.*);

    initial begin
        $display("--------------------------------------------------------");
        $display("Number of bits: %d", WIDTH);
        $display("Memory Depth: %d", SIZE);
        $display("--------------------------------------------------------");

        data_in = 32'hdead_beef; 
        addr    = 6'b0000_00;
        wr_en   = 0;
        funct3  = `LW;
        @(posedge clk);         //expect data_out to be garbage

        #1;
        data_in = 32'hdead_beef; 
        addr    = 6'b0011_00;
        wr_en   = 1;
        funct3  = `SW;
        @(posedge clk);         //expect mem[3] to become dead_beef

        #1;
        data_in = 32'h9876_5432; 
        addr    = 6'b1110_00;
        wr_en   = 1;
        funct3  = `SW;
        @(posedge clk);         //expect mem[14] to become 9876_5432

        #1;
        data_in = 32'h7654_3210; 
        addr    = 6'b1110_00;
        wr_en   = 1;
        funct3  = `SH;
        @(posedge clk);         //expect mem[14] to become 9876_3210

        #1;
        data_in = 32'h0000_3210; 
        addr    = 6'b0011_00;
        wr_en   = 1;
        funct3  = `SB;
        @(posedge clk);         //expect mem[3] to become dead_be10

        #1;
        data_in = 32'hdead_beef; 
        addr    = 6'b00_1100;
        wr_en   = 0;
        funct3  = `LW;
        @(posedge clk);         //expect data_out to become dead_be10

        #1;
        data_in = 32'hbeef_dead; 
        addr    = 6'b1110_00;
        wr_en   = 0;
        funct3  = `LB;
        @(posedge clk);         //expect data_out to become 0000_0010

        #1;
        data_in = 32'hbeef_dead; 
        addr    = 6'b1110_00;
        wr_en   = 0;
        funct3  = `LH;
        @(posedge clk);         //expect data_out to become  0000_3210

        #1;
        data_in = 32'h3210_f0f0; 
        addr    = 6'b0100_00;
        wr_en   = 1;
        funct3  = `SW;
        @(posedge clk);         //expect mem[4] to become 3210_f0f0

        #1;
        wr_en   = 0;
        funct3  = `LW;
        @(posedge clk);         //expect data_out to become 3210_f0f0

        #1;
        funct3  = `LH;
        @(posedge clk);         //expect data_out to become ffff_f0f0

        #1;
        funct3  = `LHU;
        @(posedge clk);         //expect data_out to become 0000_f0f0

        #1;
        funct3  = `LB;
        @(posedge clk);         //expect data_out to become ffff_fff0

        #1;
        funct3  = `LBU;
        @(posedge clk);         //expect data_out to become 0000_00f0

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        $finish;
    end

endmodule
