
AS := nasm
ASFLAGS := -f elf64
LD := ld

.PHONY: all clean

all: mendelbrot

mendelbrot: mendelbrot.o
	$(LD) mendelbrot.o -o mendelbrot
	@$(RM) *.o

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

clean:
	$(RM) mendelbrot *.o

