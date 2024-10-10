`include "inst_defs.sv"

module alu(
    input signed        [`REG_RANGE]     in1, in2,
    input               [`OP_RANGE]      op,
    input               [`FUNCT_3_RANGE] funct_3,
    input               [`FUNCT_7_RANGE] funct_7,
    output logic signed [`REG_RANGE]     out,
    output logic                         pc_sel
);
    always_comb begin
        pc_sel = 0;
        out  = 0;
        case(op)
            `OP_JAL: begin
                out    = in2;     //calculates the jump address using 0(in1) and immediate(in2)
                pc_sel = 1;       //note that pc+4 should be written into the target register rd of the opcode
            end
            `OP_JALR: begin
                out    = in1+in2; //calculates the jump address using rs1(in1) and immediate(in2)
                pc_sel = 1;       //note that pc+4 should be written into the target register rd of the opcode 
            end
            `OP_BR: begin
                case(funct_3)
                    //Branch address is computed by the PC adder module, not ALU and uses PC + immediate
                    //This only handles outputting the pc_sel sign
                    `BEQ:  pc_sel = (in1 == in2) ? 1 : 0;
                    `BNE:  pc_sel = (in1 != in2) ? 1 : 0;
                    `BLT:  pc_sel = (in1 < in2) ? 1 : 0;
                    `BGE:  pc_sel = !(in1 < in2) ? 1 : 0;
                    `BLTU: pc_sel = ($unsigned(in1) < $unsigned(in2)) ? 1 : 0;
                    `BGEU: pc_sel = !($unsigned(in1) < $unsigned(in2)) ? 1 : 0;
                    default: begin
                        //ASSERT STATEMENT
                        out = 0;
                        pc_sel = 0;
                    end
                endcase
            end
            `OP_LD: begin
                case(funct_3)
                    //Calculates the address of the value to be loaded into the registers
                    //adds rs1(in1) and 12-bit sign-extended immediate(in2) 
                    //assume load and stores are aligned
                    `LB:  out = in1+in2;
                    `LH:  out = in1+in2;
                    `LW:  out = in1+in2;
                    `LBU: out = in1+in2;
                    `LHU: out = in1+in2;
                    default: begin
                        //ASSERT STATEMENT
                        out = 0;
                        pc_sel = 0;
                    end
                endcase
            end
            `OP_ST: begin
                case(funct_3)
                    //Calculates the address of the value(rs2) to be stored in memory 
                    //adds rs1(in1) and 12-bit sign-extended immediate(in2) to get the address
                    //the write data(rs2) needs to be passed directly from register file to the memory(not handled by this block)
                    //assume load and stores are aligned
                    `SB:  out = in1+in2;
                    `SH:  out = in1+in2;
                    `SW:  out = in1+in2;
                    default: begin
                        //ASSERT STATEMENT
                        out = 0;
                        pc_sel = 0;
                    end
                endcase
            end
        endcase
    end

endmodule

module immediate_rearranger(
    input               [`REG_RANGE] instruction,
    output logic signed [`REG_RANGE] immediate
);
    //for Load and Store instructions, 12 bit immediate should be sign extended into 32 bits which is muxed for in2 of the ALU
    

endmodule