mv x10, x0
jal x1, increment
jal x1, increment
jal x1, increment
jal x1, decrement
jal x1, increment
jal x1, decrement
jal x1, decrement
jal x1, increment
jal x1, decrement
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