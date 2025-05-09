mv x10, x0
jal x1, 60
jal x1, 56
jal x1, 52
jal x1, 56
jal x1, 44
jal x1, 48
jal x1, 44
jal x1, 32
jal x1, 36
nop
nop
nop
nop
nop
nop
increment:
    addi x10, x10, 1
    ret
decrement:
    addi x10, x10, -1
    ret