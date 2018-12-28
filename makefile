IMAGES = stg-sprite.chr stg-bg.chr
SOURCES = \
	src/stg.asm\
	src/stg-00title.asm\
	src/stg-01setup.asm\
	src/stg-02mainloop.asm\
	src/stg-movePlayer.asm\
	src/stg-moveEnemy_type1.asm\
	src/stg-moveEnemy_type2.asm\
	src/stg-moveEnemy_typeM.asm\
	src/stg-changeEnemyToMedal.asm\
	src/stg-moveEnemy_hitCheck.asm\
	src/stg-newEnemy.asm\
	src/stg-newEnemyShot.asm\
	src/stg-addScore.asm\

all: stg.nes
	open stg.nes

stg.nes: $(IMAGES) stg.o
	ld65 -o stg.nes --config stg.cfg --obj stg.o

stg-sprite.chr: stg-sprite.bmp
	bmp2chr stg-sprite.bmp stg-sprite.chr

stg-bg.chr: stg-bg.bmp
	bmp2chr stg-bg.bmp stg-bg.chr

stg.o: $(SOURCES)
	cl65 -t none -o stg.o -c src/stg.asm

clean:
	@rm -rf *.chr
	@rm -rf *.o
	@rm -rf *.nes
