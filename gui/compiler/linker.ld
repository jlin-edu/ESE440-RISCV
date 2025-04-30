ENTRY(start);
MEMORY {
    instruction (rx) : ORIGIN = 0x0000000, LENGTH = 2048
    general_data (rw) : ORIGIN = 0x00000800, LENGTH = 512
    matrix_A (w) : ORIGIN = 0x00000A00, LENGTH = 512
    matrix_B (w) : ORIGIN = 0x00000C00, LENGTH = 512
    matrix_O (r) : ORIGIN = 0x00000E00, LENGTH = 512
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