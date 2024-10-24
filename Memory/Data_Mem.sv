`include "inst_defs.sv"

module Data_Mem #(
    parameter WIDTH = 32, SIZE = 256
    ) (
    input clk, reset, write_enable,
    input [`OP_SIZE] opcode,
    input [`REG_RANGE] read_addr, write_addr,
    input [`REG_RANGE] data_in,
    input [`FUNCT__RANGE] funct3,
    output logic [`REG_RANGE] data_out
    );

    // Memory array
    logic [SIZE-1:0][WIDTH-1:0] DATAmem;


//     Load instructions (OP_LD 7'b0000011):
//     LB (Load Byte)
//     LH (Load Halfword)
//     LW (Load Word)
//     LBU (Load Byte Unsigned)
//     LHU (Load Halfword Unsigned)

//     Store instructions (OP_ST 7'b0100011):
// SB (Store Byte)
// SH (Store Halfword) 
// SW (Store Word)

    // it should take the address and return the data
    always_comb begin : data_mem_block
        if (reset) begin
            data_out <= 0;
        end
        else begin
            // Depending on the opcode, we will perform if its a load or store
            case(opcode) begin
                // Load instructions
                `OP_LD: begin
                    case (funct3)
                        `LW: begin
                            data_out <= DATAmem[read_addr];
                        end
                        `LH: begin
                            data_out <= DATAmem[read_addr][15:0];
                        end
                        `LB: begin
                            data_out <= DATAmem[read_addr][7:0];
                        end
                        `LHU: begin
                            data_out <= DATAmem[read_addr][15:0];
                        end
                        `LBU: begin
                            data_out <= DATAmem[read_addr][7:0];
                        end
                    endcase
                end
                // Store instructions
                `OP_ST: begin
                    case(funct3)
                        `SW: begin
                            if (write_enable) begin
                                DATAmem[write_addr] <= data_in;
                            end 
                        end
                        `SH: begin
                            if (write_enable) begin
                                DATAmem[write_addr][15:0] <= data_in;
                            end 
                        end
                        `SB: begin
                            if (write_enable) begin
                                DATAmem[write_addr][7:0] <= data_in;
                            end 
                        end
                    endcase
                end
            end 
            endcase
        end
    end
endmodule