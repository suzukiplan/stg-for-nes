IMAGES = stg-sprite.chr stg-bg.chr
OBJS = stg.o

all: $(IMAGES) stg.nes
	open stg.nes

stg-sprite.chr: stg-sprite.bmp
	bmp2chr stg-sprite.bmp stg-sprite.chr

stg-bg.chr: stg-bg.bmp
	bmp2chr stg-bg.bmp stg-bg.chr

stg.nes: $(OBJS)
	ld65 -o stg.nes --config stg.cfg --obj $(OBJS)

clean:
	@rm -rf *.chr
	@rm -rf *.o
	@rm -rf *.nes

.SUFFIXES: .asm .o

.asm.o:
	cl65 -t none -o $*.o -c $*.asm
