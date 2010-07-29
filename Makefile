# Makefile for the PowerPC architecture using GLISS V2

# configuration
GLISS_PREFIX=../gliss2
WITH_DISASM=1	# comment it to prevent disassembler building
WITH_SIM=1	# comment it to prevent simulator building

MEMORY=vfast_mem
PROFILE=PPC.profile # Here goes the path of your profiling file 
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

SUBDIRS=src sim disasm
CLEAN=ppc.nml ppc.irg
DISTCLEAN=include src disasm sim

GFLAGS=\
	-m mem:$(MEMORY) \
	-m loader:$(LOADER) \
	-m syscall:$(SYSCALL) \
	-m sysparm:sysparm-reg32 \
	-m fetch:fetch32 \
	-m decode:decode32_dtrace \
	-m code:code \
	-m exception:extern/exception \
	-m fpi:extern/fpi \
	-m env:linux_env \
	-a disasm.c \
    -on GLISS_NO_MALLOC \
    -on GLISS_INSTR_FAST_STRUCT \
    -PJ 9
    
# 
# -m decode:decode32 
# -m decode:decode32_inf_cache 
# -m decode:decode32_fixed_cache 
# -m decode:decode32_lru_cache 
# -m decode:decode32_trace 

# fastest :
# -m decode:decode32_dtrace 
# To be used with GEP option "-gen-with-trace"
 

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
	$(GLISS_PREFIX)/gep/gep $(GFLAGS) $< -S -gen-with-trace -p $(PROFILE) 

lib: src include/ppc/config.h src/disasm.c
	(cd src; make -j)

ppc-disasm:
	cd disasm; make -j3

ppc-sim:
	cd sim; make -j3

include/ppc/config.h: config.tpl
	test -d include/ppc || mkdir include/ppc
	cp config.tpl include/ppc/config.h

src/disasm.c: ppc.irg
	$(GLISS_PREFIX)/gep/gliss-disasm $< -o $@ -c

distclean: clean
	-for d in $(SUBDIRS); do test -d $$d && (cd $$d; make distclean || exit 0); done
	-rm -rf $(DISTCLEAN)

clean: only-clean
	-for d in $(SUBDIRS); do test -d $$d && (cd $$d; make clean || exit 0); done

only-clean:
	-rm -rf $(CLEAN)
