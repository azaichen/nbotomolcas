### Fortran compiler
FC     = gfortran
FC90   = gfortran

LINKER = gfortran

### Disable/Enable OpenMP support
OMP = 

### Compilation/Linking options
FOPT = -g -Wall -Wno-tabs -fbounds-check -fbacktrace -ffpe-trap=zero,overflow,underflow # gfortran 

### Extra libraries
#FLIB=-llapack   # use this line if you have Lapack libraries installed
#FLIB =         # use this line if you're using source code for DLASRT

#FFLAGS = $(OMP)

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
