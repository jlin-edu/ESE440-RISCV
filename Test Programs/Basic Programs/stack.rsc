mov x1, x0
li x2, 16
li x3, 32
li x4, 1024

push_loop:
    addi x1, x1, 1
    sw x1, x4(0)
    addi x4, x4, 4
    bne x1, x3, push_loop

pop_loop:
    addi x1, x1, -1
    lw x0, x4(0)
    addi x4, x4, -4
    bne x1, x2, pop_loop

end:
    j end