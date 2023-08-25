
CFLAGS=-I../include -I../src -g -O3
LIBADD += $(shell bash ../src/ppc-config --libs)
EXEC=ppc-disasm$(EXE_SUFFIX)

all: fix $(EXEC)

fix: 
	cp ppc-disasm.save.c ppc-disasm.c

$(EXEC): ppc-disasm.o ../src/libppc.a
	$(CC) $(CFLAGS) -o $@ $< $(LIBADD)

clean:
	rm -rf ppc-disasm.o

distclean: clean
	rm -rf $(EXEC)
