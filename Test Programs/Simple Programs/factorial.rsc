li x1, 5
li x2, 1

beqz x1, end
loop:
    mul x2, x2, x1
    addi x1, x1, -1
    bnez x1, loop

end:
    j end
