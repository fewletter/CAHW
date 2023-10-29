#!/bin/bash

OUTPUTELF=mul_clz_gcc.elf
opt=( "-O0" "-O1" "-O2" "-O3" "-Os" "-Ofast" )
TOOLCHAIN=riscv-none-elf
RV32IISA=-march=rv32i_zicsr_zifencei
ILP32=-mabi=ilp32

function make_and_run() {
    $TOOLCHAIN-gcc $RV32IISA $ILP32 -c getcycles.S -o getcycles.o
    $TOOLCHAIN-gcc $RV32IISA $ILP32 $i -c mul_clz.c -o mul_clz.o
    $TOOLCHAIN-gcc $RV32IISA $ILP32 -o $OUTPUTELF mul_clz.o getcycles.o
    ../../build/rv32emu $OUTPUTELF
}

function show() {
    echo "Compilation Option : $i"
    $TOOLCHAIN-size $OUTPUTELF
    $TOOLCHAIN-readelf -h $OUTPUTELF >> analysis/relf$i.txt
    $TOOLCHAIN-objdump -d $OUTPUTELF >> analysis/dump$i.txt
}

for i in "${opt[@]}"
  do
    make_and_run $i
    show $i
    echo ""
  done

make clean