# Makefile for the PowerPC architecture using GLISS V2

# configuration
GLISS_PREFIX=../gliss2
WITH_DISASM	= 1	# comment it to prevent disassembler building
WITH_SIM	= 1	# comment it to prevent simulator building
WITH_VLE	= 1	# comment it to prevent use of VLE

MEMORY=vfast_mem
PROFILE=PPC.profile # Here goes the path of your profiling file
LOADER=old_elf
SYSCALL=syscall-linux

# one of decode, decode32_inf_cache, decode32_fixed_cache, decode32_lru_cache, decode32_trace, decode32_dtrace
DECODER=decode32_dtrace

# files
GOALS=
ifdef WITH_DISASM
GOALS+=ppc-disasm
endif
ifdef WITH_SIM
GOALS+=ppc-sim
endif

SUBDIRS=src sim disasm
CLEAN=ppc.nml ppc.irg
DISTCLEAN=include src disasm sim

CFLAGS=\
	-fno-jump-table

GFLAGS=\
	-m mem:$(MEMORY) \
	-m loader:$(LOADER) \
	-m syscall:$(SYSCALL) \
	-m sysparm:sysparm-reg32 \
	-m code:code \
	-m exception:extern/exception \
	-m fpi:extern/fpi \
	-m env:linux_env \
	-a disasm.c

ifdef WITH_VLE
PROC=ppc
NMP_MAIN = nmp/ppc_vle.nmp nmp/vle.nmp
GFLAGS += -D
else
PROC=ppc
NMP_MAIN = nmp/ppc.nmp
endif

NMP =\
	$(NMP_MAIN) \
	nmp/ppc32.nmp \
	nmp/oea_instr.nmp \
	nmp/uisa_fp_instr.nmp  \
	nmp/vea_instr.nmp \
	nmp/state.nmp \
	nmp/ppc32.nmp \
	nmp/book_e.nmp



# targets
all: lib $(GOALS)

ppc.nml: $(NMP)
	$(GLISS_PREFIX)/gep/gliss-nmp2nml.pl $< $@

ppc.irg: ppc.nml
	$(GLISS_PREFIX)/irg/mkirg $< $@

src include: ppc.irg
	$(GLISS_PREFIX)/gep/gep $(GFLAGS) $< -S

check: ppc.irg
	$(GLISS_PREFIX)/gep/gep $(GFLAGS) $< -S -c

lib: src include/$(PROC)/config.h src/disasm.c
	(cd src; make -j)

ppc-disasm:
	cd disasm; make -j3

ppc-sim:
	cd sim; make -j3

include/$(PROC)/config.h: config.tpl
	test -d include/$(PROC) || mkdir include/$(PROC)
	cp config.tpl $@
ifdef WITH_VLE
	echo "#define PPC_WITH_VLE" >> $@
endif

src/disasm.c: ppc.irg
	$(GLISS_PREFIX)/gep/gliss-disasm $< -o $@ -c

distclean: clean
	-for d in $(SUBDIRS); do test -d $$d && (cd $$d; make distclean || exit 0); done
	-rm -rf $(DISTCLEAN)

clean: only-clean
	-for d in $(SUBDIRS); do test -d $$d && (cd $$d; make clean || exit 0); done

only-clean:
	-rm -rf $(CLEAN)
