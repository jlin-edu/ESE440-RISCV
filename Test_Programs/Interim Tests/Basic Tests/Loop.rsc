li x1, 0
li x2, 10
loop:
addi x1, x1, 1
bne x1, x2, -1

li x1, 0
loop:
addi x1, x1, 1
j -1