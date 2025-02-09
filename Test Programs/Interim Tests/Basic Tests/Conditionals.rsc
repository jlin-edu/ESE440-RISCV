li x1, 64
li x2, 32
li x3, 96

if:
    add x4, x1, x2
    beq x3, x4 8
else:
    j 8
then:
    li x5, 1
end_if:
    nop

li x1, 64
li x2, 32
li x3, 64
li x4, 128

beq x1, x2, 16
beq x1, x3, 24
beq x1, x4, 24
j 24

case_1:
    li x5, 1
    j 16
case_2:
    li x5, 2
    j 8
case_3:
    li x5, 3
end_case:
    nop