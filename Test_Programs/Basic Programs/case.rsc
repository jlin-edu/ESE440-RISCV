li x1, 64
li x2, 32
li x3, 64
li x4, 128

beq x1, x2, case_1
beq x1, x3, case_2
beq x1, x4, case_3
j end_case

case_1:
    li x5, 1
    j end_case
case_2:
    li x5, 2
    j end_case
case_3:
    li x5, 3
end_case:
    nop