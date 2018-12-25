IMAGES = stg-sprite.chr stg-bg.chr
SOURCES = \
	src/stg.asm\
	src/stg0_setup.asm\
	src/stg1_mainloop.asm\
	src/stgS_movePlayer.asm\
	src/stgS_moveEnemy_type1.asm\
	src/stgS_moveEnemy_typeM.asm\
	src/stgS_changeEnemyToMedal.asm\
	src/stgS_newEnemyShot.asm\
	src/stgS_moveEnemy_hitCheck.asm\
	src/stgS_addScore.asm\

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
