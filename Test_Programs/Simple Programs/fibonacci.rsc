li x5, 1024
li x6, 0

li x8, 10
li x9, 2

li x1, 0
add x7, x5, x6
sw x1, x7(0)
addi x6, x6, 4

li x2, 1
add x7, x5, x6
sw x2, x7(0)
addi x6, x6, 4

loop:
    add x3, x1, x2
    add x7, x5, x6
    sw x3, x7(0)
    addi x6, x6, 4
    addi x9, x9, 1
    mov x1, x2
    mov x2, x3
    bne x9, x8, loop:

end:
    j end