# Makefile for the PowerPC architecture using GLISS

# configuration
GLISS_PREFIX=../gliss2
WITH_DISASM=1	# comment it to prevent disassembler building
WITH_SIM=1		# comment it to prevent simulator building

MEMORY=fast_mem
LOADER=old_elf
SYSCALL=syscall-linux


# files
GOALS=
ifdef WITH_DISASM
GOALS+=ppc-disasm
endif
ifdef WITH_SIM
GOALS+=ppc-sim
endif

CLEAN=include src disasm sim ppc.nml ppc.irg
GFLAGS=\
	-m mem:$(MEMORY) \
	-m loader:$(LOADER) \
	-m syscall:$(SYSCALL) \
	-m sysparm:sysparm-reg32 \
	-m fetch:fetch32 \
	-m decode:decode32 \
	-m inst_size:inst_size \
	-m code:code \
	-m exception:extern/exception \
	-m fpi:extern/fpi \
	-a disasm.c

NMP =\
	nmp/ppc.nmp \
	nmp/oea_instr.nmp \
	nmp/uisa_fp_instr.nmp  \
	nmp/vea_instr.nmp


# targets
all: lib $(GOALS)

ppc.nml: $(NMP)
	$(GLISS_PREFIX)/gep/gliss-nmp2nml.pl $< $@

ppc.irg: ppc.nml
	$(GLISS_PREFIX)/irg/mkirg $< $@

src include: ppc.irg
	$(GLISS_PREFIX)/gep/gep $(GFLAGS) $< -S

lib: src src/config.h src/disasm.c
	(cd src; make)

ppc-disasm:
	cd disasm; make

ppc-sim:
	cd sim; make

src/config.h: config.tpl
	test -d src || mkdir src
	cp config.tpl src/config.h

src/disasm.c: ppc.irg
	$(GLISS_PREFIX)/gep/gliss-disasm $< -o $@ -c

clean:
	rm -rf $(CLEAN)
