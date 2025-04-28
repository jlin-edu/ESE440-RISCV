#ifndef START
#define START

#define hlt ".word 0x0000000\n\t"
#define MMS ".word 0xXXXXXXX\n\t"
#define MMW ".word 0xXXXXXXX\n\t"

#define MATA __attribute__((section(".matrix_A")))
#define MATB __attribute__((section(".matrix_B")))

void main(void);

__attribute__((naked, noreturn, section(".start"))) void start(void) {
    asm volatile("li sp, 0xA00\n\t"); // Init stack pointer
    main();
    asm volatile(hlt);
}

#endif