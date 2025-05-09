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