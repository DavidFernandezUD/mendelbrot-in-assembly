
AS := nasm
ASFLAGS := -f elf64
LD := ld

.PHONY: all clean

all: mandelbrot

mandelbrot: mandelbrot.o
	$(LD) mandelbrot.o -o mandelbrot
	@$(RM) *.o

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

clean:
	$(RM) mandelbrot *.o

