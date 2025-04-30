#ifndef START
#define START

#define hlt (asm volatile(".word 0x0000000\n\t"))

#define MMS(K)                                      \
    asm volatile("addi sp, sp, -4\n\t");            \
    asm volatile("sw t0, 4(sp)\n\t");               \
    asm volatile("li t0, " #K "\n\t");              \
    asm volatile(".word 0x0005007F\n\t");           \
    asm volatile("lw t0, 4(sp)\n\t");               \
    asm volatile("addi sp, sp, 4\n\t");             

#define MMW (asm volatile(".word 0x0000003F\n\t"))

#define MATA __attribute__((section(".matrix_A")))
#define MATB __attribute__((section(".matrix_B")))

void main(void);

__attribute__((naked, noreturn, section(".start"))) void start(void) {
    asm volatile("li sp, 0xA00\n\t"); // Init stack pointer
    main();
    hlt;
}

#endif