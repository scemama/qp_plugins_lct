program bi_ort_ints
  implicit none
  BEGIN_DOC
! TODO : Put the documentation of the program here
  END_DOC
  my_grid_becke = .True.
  my_n_pt_r_grid = 30
  my_n_pt_a_grid = 50
  touch  my_grid_becke my_n_pt_r_grid my_n_pt_a_grid
  call test_overlap
  call routine_twoe
  call routine_onee
end

subroutine test_overlap
 implicit none
 integer :: i,j
 print*,'********'
 print*,'Fock_matrix_tc_mo_tot'
 do i = 1, mo_num
  write(*,'(100(F15.10,X))')Fock_matrix_tc_mo_tot(i,:)
 enddo
 print*,'********'
 provide overlap_bi_ortho_un_norm
 provide overlap_bi_ortho
end

subroutine routine_twoe
 implicit none
 integer :: i,j,k,l
 double precision :: old, get_mo_two_e_integral_tc_int
 double precision :: ref,new, accu, contrib, bi_ortho_mo_ints
 accu = 0.d0
 do j = 1, mo_num
  do i = 1, mo_num
   do l = 1, mo_num
    do k = 1, mo_num
     ! mo_non_hermit_term(k,l,i,j) = <k l| V(r_12) |i j>
!      ref = bi_ortho_mo_ints(k,l,i,j)
      ref = bi_ortho_mo_ints(l,k,j,i)
      new = mo_bi_ortho_tc_two_e(l,k,j,i)
!      old = get_mo_two_e_integral_tc_int(k,l,i,j,mo_integrals_tc_int_map)
!      old += mo_non_hermit_term(l,k,j,i)

      contrib = dabs(ref - new)
      if(dabs(ref).gt.1.d-10)then
       if(contrib.gt.1.d-10)then
        print*,k,l,i,j
        print*,old,ref,contrib
       endif
      endif
      accu += contrib
    enddo
   enddo
  enddo
 enddo
 print*,'accu = ',accu/(dble(mo_num)**4)

end

subroutine routine_onee
 implicit none
 integer :: i,k
 double precision :: ref,new,accu,contrib
 accu = 0.d0
 do i = 1, mo_num
  do k = 1, mo_num
   ref = mo_bi_ortho_tc_one_e_slow(k,i)
   new = mo_bi_ortho_tc_one_e(k,i)
   contrib = dabs(ref - new)
   if(dabs(ref).gt.1.d-10)then
    if(contrib .gt. 1.d-10)then
     print*,'i,k',i,k
     print*,ref,new,contrib
    endif
   endif
   accu += contrib
  enddo
 enddo
 print*,'accu = ',accu/mo_num**2
end
