mv sp, zero
jal ra, main

main:
        addi    sp,sp,-432
        sw      ra,428(sp)
        sw      s0,424(sp)
        addi    s0,sp,432
        sw      zero,-420(s0)
        li      a5,1
        sw      a5,-416(s0)
        li      a5,2
        sw      a5,-20(s0)
        j       88
.L3:
        lw      a5,-20(s0)
        addi    a4,a5,-1
        addi    a5,s0,-420
        slli    a4,a4,2
        add     a5,a4,a5
        lw      a4,0(a5)
        lw      a5,-20(s0)
        addi    a3,a5,-2
        addi    a5,s0,-420
        slli    a3,a3,2
        add     a5,a3,a5
        lw      a5,0(a5)
        add     a4,a4,a5
        lw      a3,-20(s0)
        addi    a5,s0,-420
        slli    a3,a3,2
        add     a5,a3,a5
        sw      a4,0(a5)
        lw      a5,-20(s0)
        addi    a5,a5,1
        sw      a5,-20(s0)
.L2:
        lw      a4,-20(s0)
        li      a5,99
        ble     a4,a5,-96
        li      a5,0
        mv      a0,a5
        lw      ra,428(sp)
        lw      s0,424(sp)
        addi    sp,sp,432
        jr      ra