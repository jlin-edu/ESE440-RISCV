`include "inst_defs.sv"

module arithmatic_tb;

    logic signed [`REG_RANGE] op1, op2;
    logic [`FUNCT_3_RANGE] funct3;
    logic [`FUNCT_7_RANGE] funct7;
    logic IMM_Type_flag;
    logic signed [`IMM_RANGE_I] immediate;
    logic [`REG_RANGE] result;

    arithmatic UUT (
        .op1(op1),
        .op2(op2),
        .funct3(funct3),
        .funct7(funct7),
        .IMM_Type_flag(IMM_Type_flag),
        .immediate(immediate),
        .result(result)
    );

    initial begin
                // Initialize signals
        op1 = 0;
        op2 = 0;
        funct3 = 0;
        funct7 = 0;
        IMM_Type_flag = 0;
        immediate = 0;

        // Test ADDI
        IMM_Type_flag = 1;
        funct3 = `ADDI;
        op1 = 10;
        immediate = 5;
        #10;
        $display($time, ,"ADDI: op1 = %b |%d, immediate = %b | %d , result = %b | %d", op1, op1, immediate, immediate, result, result);

        // Test SLTI
        funct3 = `SLTI;
        op1 = 10;
        immediate = 15;
        #10;
        $display($time, ,"SLTI: op1 = %b |%d, immediate = %b | %d , result = %b | %d", op1, op1, immediate, immediate, result, result);

        // Test SLTIU
        funct3 = `SLTIU;
        op1 = 10;
        immediate = 15;
        #10;
        $display($time, ,"SLTIU: op1 = %b |%d, immediate = %b | %d , result = %b | %d", op1, op1, immediate, immediate, result, result);

        // Test XORI
        funct3 = `XORI;
        op1 = 10;
        immediate = 5;
        #10;
        $display($time, ,"XORI: op1 = %b |%d, immediate = %b | %d , result = %b | %d", op1, op1, immediate, immediate, result, result);

        // Test ORI
        funct3 = `ORI;
        op1 = 10;
        immediate = 5;
        #10;
        $display($time, ,"ORI: op1 = %b |%d, immediate = %b | %d , result = %b | %d", op1, op1, immediate, immediate, result, result);

        // Test ANDI
        funct3 = `ANDI;
        op1 = 10;
        immediate = 5;
        #10;
        $display($time, ,"ANDI: op1 = %b |%d, immediate = %b | %d , result = %b | %d", op1, op1, immediate, immediate, result, result);

        // Test SLLI
        funct3 = `SLLI;
        op1 = 10;
        immediate = 3;
        #10;
        $display($time, ,"SLLI: op1 = %b |%d, immediate = %b | %d , result = %b | %d", op1, op1, immediate, immediate, result, result);

        // Test SRLI
        funct3 = `SRLI_SRAI;
        funct7 = `SRLI;
        op1 = 10;
        immediate = 3;
        #10;
        $display($time, ,"SRLI: op1 = %b |%d, immediate = %b | %d , result = %b | %d", op1, op1, immediate, immediate, result, result);

        // Test SRAI
        funct7 = `SRAI;
        #10;
        $display($time, ,"SRAI: op1 = %b |%d, immediate = %b | %d , result = %b | %d", op1, op1, immediate, immediate, result, result);

        // Test ADD
        IMM_Type_flag = 0;
        funct3 = `ADD_SUB;
        funct7 = `DEFAULT_7;
        op1 = 10;
        op2 = 5;
        #10;
        $display($time, ,"ADD: op1 = %b |%d, op2 = %b | %d, result = %b | %d", op1, op1, op2, op2, result, result);

        // Test SUB
        funct7 = ~`DEFAULT_7;
        #10;
        $display($time, ,"SUB: op1 = %b |%d, op2 = %b | %d, result = %b | %d", op1, op1, op2, op2, result, result);

        // Test SRL
        funct3 = `SRL;
        op1 = 10;
        op2 = 3;
        #10;
        $display($time, ,"SRL: op1 = %b |%d, op2 = %b | %d, result = %b | %d", op1, op1, op2, op2, result, result);

        // Test SRA
        funct3 = `SRA;
        #10;
        $display($time, ,"SRA: op1 = %b |%d, op2 = %b | %d, result = %b | %d", op1, op1, op2, op2, result, result);

        // Test SLL
        funct3 = `SLL;
        #10;
        $display($time, ,"SLL: op1 = %b |%d, op2 = %b | %d, result = %b | %d", op1, op1, op2, op2, result, result);

        // Test SLT
        funct3 = `SLT;
        #10;
        $display($time, ,"SLT: op1 = %b |%d, op2 = %b | %d, result = %b | %d", op1, op1, op2, op2, result, result);

        // Test SLTU
        funct3 = `SLTU;
        #10;
        $display($time, ,"SLTU: op1 = %b |%d, op2 = %b | %d, result = %b | %d", op1, op1, op2, op2, result, result);

        // Test XOR
        funct3 = `XOR;
        #10;
        $display($time, ,"XOR: op1 = %b |%d, op2 = %b | %d, result = %b | %d", op1, op1, op2, op2, result, result);

        // Test OR
        funct3 = `OR;
        #10;
        $display($time, ,"OR: op1 = %b |%d, op2 = %b | %d, result = %b | %d", op1, op1, op2, op2, result, result);

        // Test AND
        funct3 = `AND;
        #10;
        $display($time, ,"AND: op1 = %b |%d, op2 = %b | %d, result = %b | %d", op1, op1, op2, op2, result, result);

        $finish;
    end
endmodule