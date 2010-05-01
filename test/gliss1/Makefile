PPC2_PREFIX=../..
PPC_PREFIX=../../../ppc
GEL_PREFIX=../../../gel


CFLAGS=-I$(PPC2_PREFIX)/include -I$(PPC_PREFIX)/src -I$(PPC_PREFIX)/extern -I$(GEL_PREFIX)/include -g3
LIBADD =  $(shell bash ../src/ppc-config --libs) -L$(PPC_PREFIX)/ppc/lib -lemul

all: comp

comp: comp.o
	libtool --mode=link gcc $(LDFLAGS) -o $@ $^ $(LIBADD) $(GEL_PREFIX)/src/libgel.la

%.o : %.c
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f comp comp.o
