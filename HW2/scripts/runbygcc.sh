riscv-none-elf-gcc -march=rv32i_zicsr_zifencei -mabi=ilp32 -c getcycles.S -o getcycles.o
riscv-none-elf-gcc -march=rv32i_zicsr_zifencei -mabi=ilp32 -c mul_clz.c -o mul_clz.o
riscv-none-elf-gcc -march=rv32i_zicsr_zifencei -mabi=ilp32 -o mul_clz_gcc.elf mul_clz.o getcycles.o
../../build/rv32emu mul_clz_gcc.elf