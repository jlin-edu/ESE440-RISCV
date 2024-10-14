module RegFile #(
    parameter WIDTH = 32, SIZE = 256
    ) (
) (
    input logic clk, reset, write_enable,
    input logic [`REG_RANGE] read_addr, write_addr,
    output logic [`REG_RANGE] write_data_out, read_data_out
    );

    // Memory array
    logic [SIZE-1:0][WIDTH-1:0] RegisterFile;

    // it should take the address and return the data
    always_ff @( posedge clk ) begin : Register_File_block
        if (reset) begin                    // Reset state
            read_data_out <= 0;
            write_data_out <= 0;
        end
        else if (write_enable) begin            // Write operation
            RegisterFile[write_addr] <= write_data_out;
        end
        else begin                              // Read operation
            read_data_out <= RegisterFile[read_addr];
        end
    end
    
endmodule