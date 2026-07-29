program nbotomolden
        implicit none 
	integer :: i, j
	integer :: NBAS, nbos, molcas
	character(len=512) :: nbofile
        real(8),dimension(:,:),allocatable :: orbc
	real(8),dimension(:),allocatable :: occ
        integer :: nargs, ios
	
         NBAS = 0   
         nargs = command_argument_count()

         if (nargs < 1) then
            write(*,*) 'Usage: nbotomolcas <NBO file>'
            write(*,*) 'Example: nbotomolcas NBO-molcas.37'
            stop 1
         endif
         
         call get_command_argument(1, nbofile)
         
             NBAS = nbas_from_31(trim(nbofile))
         if (NBAS <= 0) then
             write(*,*) 'Could not determine NBAS from the corresponding .31 file.'
             write(*,*) 'Number of basis functions?'
             read(*,*) NBAS
         else
             write(*,'(A,I0)') 'Number of basis functions from .31 file: ', NBAS
         endif

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

	read(nbos,*,iostat=ios)(occ(i),i=1,NBAS)
        
        if (ios < 0) then
           ! EOF: occupation numbers are absent in this type of .41 file
           occ = 0.0d0
           write(*,'(A)') 'No occupation numbers found in .41 file; skipping this block.'
        else if (ios > 0) then
           write(*,'(A,I0)') 'Error while reading occupation numbers, IOSTAT = ', ios
           stop 1
        end if
        
        write(molcas,'(A)') '#OCC'
        write(molcas,'(A)') '* OCCUPATION NUMBERS'
	write(molcas,140) occ
        write(molcas,'(A)') '#OCHR'
        write(molcas,'(A)') '* OCCUPATION NUMBERS (HUMAN-READABLE)'
150 format (10(F8.4))
        write(molcas,150) occ
         
 	write(*,*) 'Output is written in molcas.NatOrb in molcas format' 
 	deallocate(orbc)
 	deallocate(occ)

contains
   integer function nbas_from_31(nbofile) result(nbas)
   implicit none

   character(len=*), intent(in) :: nbofile
   character(len=512) :: file31
   character(len=512) :: line
   integer :: iu, ios, p, dummy

   nbas = -1

   ! NBO-molcas.37 -> NBO-molcas.31
   file31 = trim(nbofile)
   p = scan(trim(file31), '.', back=.true.)

   if (p > 0) then
      file31 = file31(:p)//'31'
   else
      file31 = trim(file31)//'.31'
   endif

   write(*,'(A)') trim(file31)//' is basis info file'

   open(newunit=iu, file=trim(file31), status='old', &
        action='read', iostat=ios)

   if (ios /= 0) then
      write(*,'(A,I0)') 'Could not open .31 file, IOSTAT = ', ios
      return
   endif

   ! Skip exactly three header lines.
   read(iu,'(A)',iostat=ios) line
   if (ios /= 0) goto 900

   read(iu,'(A)',iostat=ios) line
   if (ios /= 0) goto 900

   read(iu,'(A)',iostat=ios) line
   if (ios /= 0) goto 900

   ! Fourth line:
   !       2   211   832   1
   ! First number is ignored; the second is NBAS.
   read(iu,*,iostat=ios) dummy, nbas
   if (ios /= 0 .or. nbas <= 0) goto 900

   close(iu)
   return

900 continue
   write(*,'(A,I0)') 'Could not read NBAS from .31, IOSTAT = ', ios
   nbas = -1
   close(iu)

end function nbas_from_31     
                
end
