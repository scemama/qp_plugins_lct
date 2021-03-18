program density_mulliken
 implicit none
  read_wf = .True.
  touch read_wf
  call routine 

end 

subroutine routine
 implicit none
 double precision :: accu
 integer :: i
 integer :: j
 print*,'Mulliken density analysis '
 accu= 0.d0
 do i = 1, nucl_num
  print*,i,nucl_charge(i)-mulliken_density_densities(i)
  accu += nucl_charge(i)-mulliken_density_densities(i)
 enddo
end
