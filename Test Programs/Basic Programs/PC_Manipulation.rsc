li x1, 2709678748
li x2, 2709678748
li x3, 3819450013

start:
beq x1, x2, equal

great_eq:
bge x3, x1, end_branch
bltu x1, x3, less_than_u

not_equal:
bne x1, x2, end_branch 
blt x3, x1, less_than

great_eq_u:
bgeu x1, x3, end_branch
bge x1, x3, great_eq

less_than:
blt x1, x3, end_branch
bgeu x3, x1, great_eq_u

equal:
beq x1, x3, end_branch
bne x1, x3, not_equal

less_than_u:
bltu x3 x1, start

end_branch:
la x1, third
auipc x2, 73728
j first
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
jal x3, second
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