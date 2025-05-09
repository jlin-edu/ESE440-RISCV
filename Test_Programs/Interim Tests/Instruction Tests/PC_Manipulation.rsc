li x1, 2709678748
li x2, 2709678748
li x3, 3819450013

start:
beq x1, x2, 36

great_eq:
bge x1, x3, 44
bltu x1, x3, 36

not_equal:
bne x1, x2, 36
blt x1, x3, 12

great_eq_u:
bgeu x1, x3, 28
bge x3, x1, -20

less_than:
blt x3, x1, 20
bgeu x3, x1, -12

equal:
beq x1, x3, 12
bne x1, x3, -28

less_than_u:
bltu x3 x1, -44

end_branch:
la x1, 24
auipc x2, 73728
j 72
nop
nop
nop
nop
nop
nop
nop
nop
second:
jalr x4, x1, 0
nop
nop
nop
nop
nop
nop
nop
nop
first:
jal x3, -36
nop
nop
nop
nop
nop
nop
nop
nop
third:
nop