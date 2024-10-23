`include("inst_defs.sv")

module immediate_extender (
    input signed [`REG_RANGE] instruction,     
    input logic extend_flag,                       // Sign extend flag  
    input logic sign_extend[2:0],                       // Sign extend flag (3 bits for 4 types of sign extension)
    /*
    0: 12-bit immediate
    1: 13-bit immediate
    2: 21-bit immediate

    immediate instruction 
    jump instructions
    branch instructions 
    load instructions 
    store instructions
    */ 
    input signed [`IMM_RANGE_I] immediate,                  // Immediate value for I-type instructions
    input logic byte_enable,                                // Byte enable flag from the control unit
    input logic halfword_enable,                            // Halfword enable flag from the control unit
    input logic word_enable,                                // Word enable flag from the control unit
    output logic [`REG_RANGE] result
    );

// sign extension and re-arrangement of immediate value
always_comb begin : Immediate_Extend_block
if (extend_flag) begin
    case (sign_extend)
        3'b001: begin
            if (instruction[11] == 1) begin
                result = {20(1) , instruction};
            end
            else begin
                result = {20(0) , instruction};
            end
        end
        3'b010: begin 
            if (instruction[12] == 1) begin
                result = {19(1) , instruction};
            end
            else begin
                result = {19(0) , instruction};
            end
        end
        3'b100: begin 
            if (instruction[20] == 1) begin
                result = {11(1) , instruction};
            end
            else begin
                result = {11(0) , instruction};
            end
        end
        default: result = 0;
    endcase
end
else begin
    result = immediate;
end


if (byte_enable) begin              // If byte enable is set, only the 8 LSBs are used
    result = result[7:0];        
end
else if (halfword_enable) begin     // If halfword enable is set, only the 16 LSBs are used
    result = result[15:0];
end
else if (word_enable) begin         // If word enable is set, the 32 bits are used
    result = result[31:0];
end
end
end 
endmodule
