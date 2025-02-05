mv sp, zero
jal ra, main

push:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        sw      a0,-20(s0)
        sw      a1,-24(s0)
        sw      a2,-28(s0)
        lw      a5,-24(s0)
        lw      a5,0(a5)
        addi    a4,a5,1
        lw      a5,-24(s0)
        sw      a4,0(a5)
        lw      a5,-24(s0)
        lw      a5,0(a5)
        slli    a5,a5,2
        lw      a4,-20(s0)
        add     a5,a4,a5
        lw      a4,-28(s0)
        sw      a4,0(a5)
        nop
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra
pop:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        sw      a0,-20(s0)
        sw      a1,-24(s0)
        lw      a5,-24(s0)
        addi    a4,a5,-4
        sw      a4,-24(s0)
        lw      a5,0(a5)
        slli    a5,a5,2
        lw      a4,-20(s0)
        add     a5,a4,a5
        lw      a5,0(a5)
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra
producer:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        sw      a0,-20(s0)
        sw      a1,-24(s0)
        sw      a2,-28(s0)
        lw      a2,-28(s0)
        lw      a1,-24(s0)
        lw      a0,-20(s0)
        jal     ra, push
        nop
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra
consumer:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        sw      a0,-20(s0)
        sw      a1,-24(s0)
        lw      a1,-24(s0)
        lw      a0,-20(s0)
        jal     ra, pop
        nop
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra
main:
        addi    sp,sp,-432
        sw      ra,428(sp)
        sw      s0,424(sp)
        addi    s0,sp,432
        li      a5,-1
        sw      a5,-424(s0)
        sw      zero,-20(s0)
        j       .L7
.L8:
        addi    a4,s0,-424
        addi    a5,s0,-420
        lw      a2,-20(s0)
        mv      a1,a4
        mv      a0,a5
        jal     ra, producer
        addi    a4,s0,-424
        addi    a5,s0,-420
        mv      a1,a4
        mv      a0,a5
        jal     ra, consumer
        lw      a5,-20(s0)
        addi    a5,a5,1
        sw      a5,-20(s0)
.L7:
        lw      a4,-20(s0)
        li      a5,999
        ble     a4,a5,.L8
        li      a5,0
        mv      a0,a5
        lw      ra,428(sp)
        lw      s0,424(sp)
        addi    sp,sp,432
        jr      ra