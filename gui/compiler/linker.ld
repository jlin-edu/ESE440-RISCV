ENTRY(start);
MEMORY {
    instruction (rx) : ORIGIN = 0x0000000, LENGTH = 4096
    general_data (rw) : ORIGIN = 0x00001000, LENGTH = 1024
    matrix_A (w) : ORIGIN = 0x00001400, LENGTH = 1024
    matrix_B (w) : ORIGIN = 0x00001800, LENGTH = 1024
    matrix_O (r) : ORIGIN = 0x00001C00, LENGTH = 1024
}

SECTIONS {
    .start : { *(.start) } > instruction
    .text : { *(.text) } > instruction
    .rodata : { *(.rodata) } > general_data
    .data : { *(.data) } > general_data
    .bss : { *(.bss) } > general_data
    .matrix_A : { *(.matrix_A) } > matrix_A
    .matrix_B : { *(.matrix_B) } > matrix_B
    . = ALIGN(4096);
}