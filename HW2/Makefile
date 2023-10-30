.PHONY: clean

include ../../mk/toolchain.mk

ASFLAGS = -march=rv32i_zicsr_zifencei -mabi=ilp32
LDFLAGS = --oformat=elf32-littleriscv

OPT ?= 

%.o: %.S
	$(CROSS_COMPILE)as $(OPT) -R $(ASFLAGS) -o $@ $<

%.o: %.c
	$(CROSS_COMPILE)as $(OPT) -R $(ASFLAGS) -o $@ $<

all: mul_clz.elf
	../../build/rv32emu $<
	$(CROSS_COMPILE)size $<

mul_clz.elf: mul_clz.o
	$(CROSS_COMPILE)ld $(OPT) -o $@ -T mul_clz.ld $(LDFLAGS) $<

testgcc:
	bash ./scripts/runbygcc.sh

clean:
	$(RM) *.elf *.o
