### Fortran compiler
FC     = gfortran
FC90   = gfortran

LINKER = gfortran

### Compilation/Linking options
FOPT = -g -Wall -Wno-tabs -fbounds-check -fbacktrace -ffpe-trap=zero,overflow,underflow # gfortran 

.SUFFIXES: .f .F .F90 .f90

BIN = nbotomolcas


.F.o:
	$(FC) $(FOPT) -c $< -o $@
.F90.o: 
	$(FC90) $(FOPT) -c $< -o $@
.f90.o: 
	$(FC90) $(FOPT) -c $< -o $@

all: $(BIN)

nbotomolcas: nbotomolcas.o
	$(LINKER) -o nbotomolcas nbotomolcas.o $(FFLAGS) $(FLIB)

clean:
	rm -f $(BIN) *.o *.mod
