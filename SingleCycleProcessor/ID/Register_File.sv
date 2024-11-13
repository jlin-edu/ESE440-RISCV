`include "inst_defs.sv"

module register_file #(
    parameter  WIDTH=32//, SIZE=32,
    //localparam LOGSIZE=$clog2(SIZE)
)(
    input clk, reset,

    //write port
    input [`REG_FIELD_RANGE] wr_addr,
    input [`REG_RANGE]       wr_data, 
    input wr_en,

    //first read port
    input  [`REG_FIELD_RANGE] rs1_rd_addr,
    output logic [`REG_RANGE] rs1_rd_data,

    //second read port
    input  [`REG_FIELD_RANGE] rs2_rd_addr,
    output logic [`REG_RANGE] rs2_rd_data,
);
    logic [31:1][WIDTH-1:0] register_file;

    //write logic
    always_ff @(posedge clk) begin
        if(reset)
            register_file <= '{default: '0};
        else if((wr_addr != 0) & (wr_en == 1))
            register_file[wr_addr] <= wr_data;
    end

    //read logic
    always_comb begin
        if(rs1_rd_addr == 0)
            rs1_rd_data = 0;
        else
            rs1_rd_data = register_file[rs1_rd_addr];

        if(rs2_rd_addr == 0)
            rs2_rd_data = 0;
        else
            rs2_rd_data = register_file[rs2_rd_addr];
    end

endmodule