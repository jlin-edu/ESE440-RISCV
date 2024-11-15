li x1, 64
li x2, 32
li x3, 96

if:
    add x4, x1, x2
    beq x3, x4 then
else:
    j end_if
then:
    li x5, 1
end_if:
    nop