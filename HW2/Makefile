.PHONY: clean

include ../../mk/toolchain.mk

ASFLAGS = -march=rv32i_zicsr_zifencei -mabi=ilp32
LDFLAGS = --oformat=elf32-littleriscv

FROM = \
	getcycles.S \
    mul_clz.c

OBJS = \
    getcycles.o \
    mul_clz.o

TARGET = mul_clz_gcc.elf

%.o: %.S
	$(CROSS_COMPILE)as -R $(ASFLAGS) -o $@ $<

%.o: %.c
	$(CROSS_COMPILE)as -R $(ASFLAGS) -o $@ $<

all: mul_clz.elf

%.elf: %.o
	$(CROSS_COMPILE)ld -o $@ -T mul_clz.ld $(LDFLAGS) $<

clean:
	$(RM) *.elf *.o
