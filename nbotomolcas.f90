program nbotomolden
        implicit none 
		integer :: i, j
		integer :: NBAS, nbos, molcas
		character(30) :: nbofile
        real(8),dimension(:,:),allocatable :: orbc
		real(8),dimension(:),allocatable :: occ
	    
		write(*,*) 'Your NBO7 output file (.3x, .39, 37)?'
		read(*,*) nbofile
		write(*,*) 'Number of basis functions?'
		read(*,*) NBAS

		allocate(orbc(NBAS,NBAS))
	    allocate(occ(NBAS))

		nbos = 100
		molcas = 110

		open(nbos,file=nbofile,status='old')
        read(nbos,*)
		read(nbos,*)
        read(nbos,*)
        
		open(newunit=molcas, file="molcas.NatOrb", status="replace", action="write")
       
        write(molcas,'(A)') '#INPORB 2.2' 
        write(molcas,'(A)') '#INFO' 
        write(molcas,'(A,A)') '* NBOs in AO basis set from file: ', nbofile 
        write(molcas,*) '      0       1       0'
        write(molcas,*)  NBAS
        write(molcas,*)  NBAS
        write(molcas,'(A)') '*Written in nbotomolden v0.1'
        write(molcas,'(A)') '#EXTRAS'
        write(molcas,*) 
        write(molcas,*) 
        write(molcas,'(A)') '#ORB' 

140 format (5(E23.15))

        do i = 1,NBAS
	       read(nbos,*)(orbc(i,j),j=1,NBAS)
		   write(molcas,'(A,I4,I4)') '* ORBITAL', 1, i
		   write(molcas,140) orbc(i,:)
        enddo
     
        write(molcas,'(A)') '#OCC'
        write(molcas,'(A)') '* OCCUPATION NUMBERS'
		occ = 0.0D0
		write(molcas,140) occ
	    write(molcas,'(A)') '#OCHR'
        write(molcas,'(A)') '* OCCUPATION NUMBERS (HUMAN-READABLE)'
150 format (10(F8.4))
        write(molcas,150) occ
         
		write(*,*) 'Output is written in molcas.NatOrb in molcas format' 
		deallocate(orbc)
		deallocate(occ)
end
