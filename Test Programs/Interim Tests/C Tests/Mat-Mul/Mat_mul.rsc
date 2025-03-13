mv sp, zero
jal ra, main

main:
        addi    sp,sp,-80
        sw      ra,76(sp)
        sw      s0,72(sp)
        addi    s0,sp,80
        sw      zero,-20(s0)
        j       156
.L5:
        sw      zero,-24(s0)
        j       120
.L4:
        lw      a5,-20(s0)
        addi    a4,a5,1
        lw      a5,-24(s0)
        add     a4,a4,a5
        lw      a5,-20(s0)
        slli    a3,a5,1
        lw      a5,-24(s0)
        add     a3,a3,a5
        addi    a5,s0,-48
        slli    a3,a3,2
        add     a5,a3,a5
        sw      a4,0(a5)
        li      a4,3
        lw      a5,-20(s0)
        sub     a4,a4,a5
        lw      a5,-24(s0)
        add     a4,a4,a5
        lw      a5,-20(s0)
        slli    a3,a5,1
        lw      a5,-24(s0)
        add     a3,a3,a5
        addi    a5,s0,-64
        slli    a3,a3,2
        add     a5,a3,a5
        sw      a4,0(a5)
        lw      a5,-24(s0)
        addi    a5,a5,1
        sw      a5,-24(s0)
.L3:
        lw      a4,-24(s0)
        li      a5,1
        ble     a4,a5,-128
        lw      a5,-20(s0)
        addi    a5,a5,1
        sw      a5,-20(s0)
.L2:
        lw      a4,-20(s0)
        li      a5,1
        ble     a4,a5,-164
        sw      zero,-28(s0)
        j       180
.L9:
        sw      zero,-32(s0)
        j       148
.L8:
        lw      a4,-28(s0)
        addi    a5,s0,-48
        slli    a4,a4,3
        add     a5,a4,a5
        lw      a4,0(a5)
        lw      a3,-32(s0)
        addi    a5,s0,-64
        slli    a3,a3,2
        add     a5,a3,a5
        lw      a5,0(a5)
        mul     a4,a4,a5
        lw      a3,-28(s0)
        addi    a5,s0,-44
        slli    a3,a3,3
        add     a5,a3,a5
        lw      a3,0(a5)
        lw      a5,-32(s0)
        addi    a2,a5,2
        addi    a5,s0,-64
        slli    a2,a2,2
        add     a5,a2,a5
        lw      a5,0(a5)
        mul     a5,a3,a5
        add     a4,a4,a5
        lw      a5,-28(s0)
        slli    a3,a5,1
        lw      a5,-32(s0)
        add     a3,a3,a5
        addi    a5,s0,-80
        slli    a3,a3,2
        add     a5,a3,a5
        sw      a4,0(a5)
        lw      a5,-32(s0)
        addi    a5,a5,1
        sw      a5,-32(s0)
.L7:
        lw      a4,-32(s0)
        li      a5,1
        ble     a4,a5,-152
        lw      a5,-28(s0)
        addi    a5,a5,1
        sw      a5,-28(s0)
.L6:
        lw      a4,-28(s0)
        li      a5,1
        ble     a4,a5,-188
        li      a5,0
        mv      a0,a5
        lw      ra,76(sp)
        lw      s0,72(sp)
        addi    sp,sp,80
        jr      ra