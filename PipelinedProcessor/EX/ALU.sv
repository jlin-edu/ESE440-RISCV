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
        out    = 0;
        //Missing Instructions: LUI, AUIPC and M extension
        case(op)
            //note: Only difference between OP_IMM and OP_R3, is bit 5
            //      AUIPC uses PC, whereas JAL and JALR use PC+4
            //      Value of in1 should mux between PC and rs1 depending on the instruction
            //      Value of in2 should mux between Immediate and rs2 depending on the instruction
            //      Value of Out: For LUI, AUIPC, Arithmetic and Arithemtic Immediate, out represents the value to be written to register rd
            //                    For JAL, JALR, out represents the jump address
            //                    For Branch, out should just be 0
            //                    For Load and Store, out represents the byte address of the data memory
            //      Value of pc_sel: For JAL, JALR the pc_sel is unconditionally set to 1
            //                       For Branch instructions pc_sel is the result of a comparison
            //                       Otherwise, pc_sel should always be 0
            `OP_LUI:   out = in2;     //in2 contains the immediate value which is to be placed into rd
            `OP_AUIPC: out = in1+in2; //in1 should contain PC, which is the address of the auipc instruction, in2 is the immediate, result is written to register rd
            `OP_IMM: begin
                case(funct_3)
                    `ADDI:   out = in1+in2; //in2 will mux between rs2 and the immediate depending on a control signal
                    `SLTI:   out = (in1 < in2) ? 1 : 0;
                    `SLTIU:  out = ($unsigned(in1) < $unsigned(in2)) ? 1 : 0;
                    `XORI:   out = in1 ^ in2;
                    `ORI:    out = in1 | in2;
                    `ANDI:   out = in1 & in2;
                    `SLLI:   out = in1 << in2[4:0]; //shifts only use the lower 5 bits of the immediate field
                    `SRLI_SRAI: begin
                        case(funct_7)
                            `SRLI: out = in1 >>  in2[4:0]; 
                            `SRAI: out = in1 >>> in2[4:0];
                            default: begin
                                //ASSERT STATEMENT
                                out    = 0;
                                pc_sel = 0;
                            end
                        endcase
                    end
                    default: begin
                        //ASSERT STATEMENT
                        out    = 0;
                        pc_sel = 0;
                    end
                endcase
            end
            `OP_R3: begin
                case(funct_3)
                    `ADD_SUB: begin //in2 will mux between rs2 and the immediate depending on a control signal
                        case(funct_7) 
                            `ADD: out = in1+in2;
                            `SUB: out = in1-in2;
                            `M:   out = in1*in2; //MUL
                            default: begin
                                //ASSERT STATEMENT
                                out    = 0;
                                pc_sel = 0;
                            end
                        endcase
                    end
                    `SLL: begin 
                        case(funct_7)   
                            `DEFAULT_7: out = in1 << in2[4:0]; //shifts use the lower 5 bits of register rs2
                            `M:         out = 64'(in1*in2) >> `REG_SIZE; //MULH
                            default: begin
                                //ASSERT STATEMENT
                                out    = 0;
                                pc_sel = 0;
                            end
                        endcase
                    end
                    `SLT: begin  
                        case(funct_7)  
                            `DEFAULT_7: out = (in1 < in2) ? 1 : 0;
                            `M:         out = 64'(in1 * $unsigned(in2)) >> `REG_SIZE; //MULHSU
                            default: begin
                                //ASSERT STATEMENT
                                out    = 0;
                                pc_sel = 0;
                            end
                        endcase
                    end
                    `SLTU: begin
                        case(funct_7)  
                            `DEFAULT_7: out = ($unsigned(in1) < $unsigned(in2)) ? 1 : 0;
                            `M:         out = 64'($unsigned(in1) * $unsigned(in2)) >> `REG_SIZE; //MULHU
                            default: begin
                                //ASSERT STATEMENT
                                out    = 0;
                                pc_sel = 0;
                            end
                        endcase
                    end
                    `XOR: begin
                        case(funct_7)  
                            `DEFAULT_7: out = in1 ^ in2;
                            //`M:         out = (in2 == 0) ? -1 : (in1 == -`MAX_32 && in2 == -1) ? -`MAX_32 : in1 / in2; //DIV
                            default: begin
                                //ASSERT STATEMENT
                                out    = 0;
                                pc_sel = 0;
                            end
                        endcase
                    end
                    `SRL_SRA: begin
                        case(funct_7)
                            `SRL: out = in1 >>  in2[4:0];
                            `SRA: out = in1 >>> in2[4:0];
                            //`M:   out = (in2 == 0) ? -1 : $unsigned(in1) / $unsigned(in2);   //DIVU
                            default: begin
                                //ASSERT STATEMENT
                                out    = 0;
                                pc_sel = 0;
                            end
                        endcase
                    end
                    `OR: begin
                        case(funct_7)  
                            `DEFAULT_7: out = in1 | in2;
                            //`M:         out = (in2 == 0) ? in1 : (in1 == -`MAX_32 && in2 == -1) ? 0 : in1 % in2; //REM
                            default: begin
                                //ASSERT STATEMENT
                                out    = 0;
                                pc_sel = 0;
                            end
                        endcase
                    end
                    `AND: begin
                        case(funct_7)  
                            `DEFAULT_7: out = in1 & in2;
                            //`M:         out = (in2 == 0) ? in1 : $unsigned(in1) % $unsigned(in2); //REMU
                            default: begin
                                //ASSERT STATEMENT
                                out    = 0;
                                pc_sel = 0;
                            end
                        endcase
                    end
                    default: begin
                        //ASSERT STATEMENT
                        out    = 0;
                        pc_sel = 0;
                    end
                endcase
            end
        //Branch, Jump, Load & Store
            `OP_JAL: begin
                out    = in1+in2;     //calculates the jump address using pc(in1) plus immediate(in2)
                pc_sel = 1;       //note that pc+4 should be written into the target register rd of the opcode
            end
            `OP_JALR: begin
                out    = (in1+in2) & 32'hFFFFFFFE ; //calculates the jump address using rs1(in1) plus immediate(in2)
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
            default: begin
                out    = 0;
                pc_sel = 0;
            end
        endcase
    end

endmodule