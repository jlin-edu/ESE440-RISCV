@echo off
set /p program="Enter C file to compile: "
@echo on
riscv64-unknown-elf-gcc -c -include %~dp0start.h -march=rv32im -mabi=ilp32 -ffreestanding %program%.c -o %program%.o
riscv64-unknown-elf-gcc -T %~dp0linker.ld -march=rv32im -mabi=ilp32 -nostdlib %program%.o -o %program%.elf
riscv64-unknown-elf-objcopy -O binary %program%.elf %program%.bin