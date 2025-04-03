mv x3, zero
li x6, 10

mv x1, zero
outer:
mv x2, zero
inner:
div x4, x1, x2
sw x4, 0(x3)
addi x3, x3, 4
addi x2, x2, 1
bge x6, x2, inner
addi x1, x1, 1
bge x6, x1, outer
