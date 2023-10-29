.PHONY: clean

include ../../mk/toolchain.mk

ASFLAGS = -march=rv32i_zicsr_zifencei -mabi=ilp32
LDFLAGS = --oformat=elf32-littleriscv

%.o: %.S
	$(CROSS_COMPILE)as -R $(ASFLAGS) -o $@ $<

%.o: %.c
	$(CROSS_COMPILE)as -R $(ASFLAGS) -o $@ $<

all: mul_clz.elf

mul_clz.elf: mul_clz.o
	$(CROSS_COMPILE)ld -ofast -o $@ -T mul_clz.ld $(LDFLAGS) $<

testgcc:
	bash ./scripts/runbygcc.sh

clean:
	$(RM) *.elf *.o
