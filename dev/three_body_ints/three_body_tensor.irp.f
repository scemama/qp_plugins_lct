BEGIN_PROVIDER [ double precision, three_body_ints, (mo_num, mo_num, mo_num, mo_num, mo_num, mo_num)]
 implicit none
 BEGIN_DOC
! matrix element of the -L  three-body operator 
!
! notice the -1 sign: in this way three_body_ints can be directly used to compute Slater rules :)
 END_DOC
 integer :: i,j,k,l,m,n
 double precision :: integral, wall1, wall0
 character*(128) :: name_file 
 three_body_ints = 0.d0
 print*,'Providing the three_body_ints ...'
 call wall_time(wall0)
 name_file = 'six_index_tensor'
 if(read_3_body_tc_ints)then
  call read_fcidump_3_tc(three_body_ints)
 else
  if(read_six_index_tensor)then
   print*,'Reading three_body_ints from disk ...'
   call read_array_6_index_tensor(mo_num,three_body_ints,name_file)
  else
  provide x_W_ij_erf_rk
  !$OMP PARALLEL                  &
  !$OMP DEFAULT (NONE)            &
  !$OMP PRIVATE (i,j,k,l,m,n,integral) & 
  !$OMP SHARED (mo_num,three_body_ints)
  !$OMP DO SCHEDULE (dynamic)
   do n = 1, mo_num
    do l = 1, mo_num
     do k = 1, mo_num
      do m = n, mo_num
       do j = l, mo_num
        do i = k, mo_num
!!         if(i>=j)then
           integral = 0.d0
           call give_integrals_3_body(i,j,m,k,l,n,integral)
 
           three_body_ints(i,j,m,k,l,n) = -1.d0 * integral 
   
           ! permutation with k,i
           three_body_ints(k,j,m,i,l,n) = -1.d0 * integral ! i,k
           ! two permutations with k,i
           three_body_ints(k,l,m,i,j,n) = -1.d0 * integral 
           three_body_ints(k,j,n,i,l,m) = -1.d0 * integral 
           ! three permutations with k,i
           three_body_ints(k,l,n,i,j,m) = -1.d0 * integral 
   
           ! permutation with l,j
           three_body_ints(i,l,m,k,j,n) = -1.d0 * integral ! j,l
           ! two permutations with l,j
           three_body_ints(k,l,m,i,j,n) = -1.d0 * integral 
           three_body_ints(i,l,n,k,j,m) = -1.d0 * integral 
           ! two permutations with l,j
!!!!        three_body_ints(k,l,n,i,j,m) = -1.d0 * integral 
   
           ! permutation with m,n
           three_body_ints(i,j,n,k,l,m) = -1.d0 * integral ! m,n
           ! two permutations with m,n
           three_body_ints(k,j,n,i,l,m) = -1.d0 * integral ! m,n
           three_body_ints(i,l,n,k,j,m) = -1.d0 * integral ! m,n
           ! three permutations with k,i
!!!!        three_body_ints(k,l,n,i,j,m) = -1.d0 * integral ! m,n
 
!!         endif
        enddo
       enddo
      enddo
     enddo
    enddo
   enddo
  !$OMP END DO
  !$OMP END PARALLEL
  endif
 endif
 call wall_time(wall1)
 print*,'wall time for three_body_ints',wall1 - wall0
 if(write_six_index_tensor)then
  print*,'Writing three_body_ints on disk ...'
  call write_array_6_index_tensor(mo_num,three_body_ints,name_file)
  call ezfio_set_three_body_ints_io_six_index_tensor("Read")
 endif

END_PROVIDER 

subroutine give_integrals_3_body(i,j,m,k,l,n,integral)
 implicit none
 double precision, intent(out) :: integral
 integer, intent(in) :: i,j,m,k,l,n
 double precision :: weight
 BEGIN_DOC
! <ijm|L|kln>
 END_DOC
 integer :: ipoint,mm
 integral = 0.d0
 do mm = 1, 3
  do ipoint = 1, n_points_final_grid
   weight = final_weight_at_r_vector(ipoint)                                                                          
   integral += weight * mos_in_r_array_transp(ipoint,i) * mos_in_r_array_transp(ipoint,k) * x_W_ij_erf_rk(ipoint,mm,m,n) * x_W_ij_erf_rk(ipoint,mm,j,l) 
   integral += weight * mos_in_r_array_transp(ipoint,j) * mos_in_r_array_transp(ipoint,l) * x_W_ij_erf_rk(ipoint,mm,m,n) * x_W_ij_erf_rk(ipoint,mm,i,k) 
   integral += weight * mos_in_r_array_transp(ipoint,m) * mos_in_r_array_transp(ipoint,n) * x_W_ij_erf_rk(ipoint,mm,j,l) * x_W_ij_erf_rk(ipoint,mm,i,k) 
  enddo
 enddo
end

BEGIN_PROVIDER [ double precision, three_body_5_index, (mo_num, mo_num, mo_num, mo_num, mo_num)]
 implicit none
 BEGIN_DOC
! 5 index matrix element of the -L  three-body operator 
!
! three_body_5_index(i,j,m,l,n) = < phi_i phi_j phi_m | phi_i phi_l phi_n >
!
! notice the -1 sign: in this way three_body_5_index can be directly used to compute Slater rules :)
 END_DOC
 integer :: j,k,l,m,n
 double precision :: integral, wall1, wall0
 character*(128) :: name_file 
 name_file = 'six_index_tensor'
 provide x_W_ij_erf_rk
 three_body_5_index = 0.d0
 print*,'Providing the three_body_5_index ...'
 call wall_time(wall0)
!if(read_six_index_tensor)then
! print*,'Reading three_body_5_index from disk ...'
! call read_array_6_index_tensor(mo_num,three_body_5_index,name_file)
!else
 !$OMP PARALLEL                  &
 !$OMP DEFAULT (NONE)            &
 !$OMP PRIVATE (j,k,l,m,n,integral) & 
 !$OMP SHARED (mo_num,three_body_5_index)
 !$OMP DO SCHEDULE (guided) COLLAPSE(2)
  do n = 1, mo_num
   do l = 1, mo_num
    do k = 1, mo_num
     do m = n, mo_num
      do j = l, mo_num
        integral = 0.d0
        
        call give_integrals_3_body(j,m,k,l,n,k,integral)

        three_body_5_index(k,j,m,l,n) = -1.d0 * integral 
  
        ! permutation with k,i
        three_body_5_index(k,l,m,j,n) = -1.d0 * integral 
        three_body_5_index(k,j,n,l,m) = -1.d0 * integral 
        ! three permutations with k,i
        three_body_5_index(k,l,n,j,m) = -1.d0 * integral 
  
        ! permutation with l,j
        three_body_5_index(k,l,m,j,n) = -1.d0 * integral ! j,l
        ! two permutations with l,j
        three_body_5_index(k,l,m,j,n) = -1.d0 * integral 
        three_body_5_index(k,l,n,j,m) = -1.d0 * integral 
        ! two permutations with l,j
  
        ! permutation with m,n
        three_body_5_index(k,j,n,l,m) = -1.d0 * integral ! m,n
        ! two permutations with m,n
        three_body_5_index(k,j,n,l,m) = -1.d0 * integral ! m,n
        three_body_5_index(k,l,n,j,m) = -1.d0 * integral ! m,n
        ! three permutations with k,i
      enddo
     enddo
    enddo
   enddo
  enddo
 !$OMP END DO
 !$OMP END PARALLEL
!endif
 call wall_time(wall1)
 print*,'wall time for three_body_5_index',wall1 - wall0
!if(write_six_index_tensor)then
! print*,'Writing three_body_5_index on disk ...'
! call write_array_6_index_tensor(mo_num,three_body_5_index,name_file)
! call ezfio_set_three_body_5_index_io_six_index_tensor("Read")
!endif

END_PROVIDER 

BEGIN_PROVIDER [ double precision, three_body_5_index_exch_13, (mo_num, mo_num, mo_num, mo_num, mo_num)]
 implicit none
 BEGIN_DOC
! 5 index matrix element of the -L  three-body operator 
!
! three_body_5_index_exch_13(k,j,m,l,n) = < phi_j phi_m phi_k | phi_k phi_n phi_l >
!
! notice the -1 sign: in this way three_body_5_index_exch_13 can be directly used to compute Slater rules :)
 END_DOC
 integer :: j,k,l,m,n
 double precision :: integral, wall1, wall0
 character*(128) :: name_file 
 provide x_W_ij_erf_rk
 name_file = 'six_index_tensor'
 three_body_5_index_exch_13 = 0.d0
 print*,'Providing the three_body_5_index_exch_13 ...'
 call wall_time(wall0)
!if(read_six_index_tensor)then
! print*,'Reading three_body_5_index_exch_13 from disk ...'
! call read_array_6_index_tensor(mo_num,three_body_5_index_exch_13,name_file)
!else
 !$OMP PARALLEL                  &
 !$OMP DEFAULT (NONE)            &
 !$OMP PRIVATE (j,k,l,m,n,integral) & 
 !$OMP SHARED (mo_num,three_body_5_index_exch_13)
 !$OMP DO SCHEDULE (guided) COLLAPSE(2)
  do n = 1, mo_num
   do l = 1, mo_num
    do k = 1, mo_num
     do m = n, mo_num
      do j = l, mo_num
        integral = 0.d0
!                                  j,m,k,l,n,k : direct
        call give_integrals_3_body(j,m,k,k,n,l,integral)
!                                  j,m,k,k,n,l : exchange 1 3

        three_body_5_index_exch_13(k,j,m,l,n) = -1.d0 * integral 
  
        ! permutation with k,i
        three_body_5_index_exch_13(k,l,m,j,n) = -1.d0 * integral 
        three_body_5_index_exch_13(k,j,n,l,m) = -1.d0 * integral 
        ! three permutations with k,i
        three_body_5_index_exch_13(k,l,n,j,m) = -1.d0 * integral 
  
        ! permutation with l,j
        three_body_5_index_exch_13(k,l,m,j,n) = -1.d0 * integral ! j,l
        ! two permutations with l,j
        three_body_5_index_exch_13(k,l,m,j,n) = -1.d0 * integral 
        three_body_5_index_exch_13(k,l,n,j,m) = -1.d0 * integral 
        ! two permutations with l,j
  
        ! permutation with m,n
        three_body_5_index_exch_13(k,j,n,l,m) = -1.d0 * integral ! m,n
        ! two permutations with m,n
        three_body_5_index_exch_13(k,j,n,l,m) = -1.d0 * integral ! m,n
        three_body_5_index_exch_13(k,l,n,j,m) = -1.d0 * integral ! m,n
        ! three permutations with k,i
      enddo
     enddo
    enddo
   enddo
  enddo
 !$OMP END DO
 !$OMP END PARALLEL
!endif
 call wall_time(wall1)
 print*,'wall time for three_body_5_index_exch_13',wall1 - wall0
!if(write_six_index_tensor)then
! print*,'Writing three_body_5_index_exch_13 on disk ...'
! call write_array_6_index_tensor(mo_num,three_body_5_index_exch_13,name_file)
! call ezfio_set_three_body_5_index_exch_13_io_six_index_tensor("Read")
!endif

END_PROVIDER 

BEGIN_PROVIDER [ double precision, three_body_5_index_exch_32, (mo_num, mo_num, mo_num, mo_num, mo_num)]
 implicit none
 BEGIN_DOC
! 5 index matrix element of the -L  three-body operator 
!
! three_body_5_index_exch_32(i,j,m,l,n) = < phi_i phi_j phi_m | phi_i phi_l phi_n >
!
! notice the -1 sign: in this way three_body_5_index_exch_32 can be directly used to compute Slater rules :)
 END_DOC
 integer :: i,j,k,l,m,n
 double precision :: integral, wall1, wall0
 character*(328) :: name_file 
 provide x_W_ij_erf_rk
 name_file = 'six_index_tensor'
 three_body_5_index_exch_32 = 0.d0
 print*,'Providing the three_body_5_index_exch_32 ...'
 call wall_time(wall0)
!if(read_six_index_tensor)then
! print*,'Reading three_body_5_index_exch_32 from disk ...'
! call read_array_6_index_tensor(mo_num,three_body_5_index_exch_32,name_file)
!else
 !$OMP PARALLEL                  &
 !$OMP DEFAULT (NONE)            &
 !$OMP PRIVATE (j,k,l,m,n,integral) & 
 !$OMP SHARED (mo_num,three_body_5_index_exch_32)
 !$OMP DO SCHEDULE (guided) COLLAPSE(2)
  do n = 1, mo_num
   do l = 1, mo_num
    do k = 1, mo_num
     do m = n, mo_num
      do j = l, mo_num
        integral = 0.d0
!                                  j,m,k,l,n,k : direct
        call give_integrals_3_body(j,m,k,l,k,n,integral)
!                                  j,m,k,l,k,n : exchange 2 3

        three_body_5_index_exch_32(k,j,m,l,n) = -1.d0 * integral 
  
        ! permutation with k,i
        three_body_5_index_exch_32(k,l,m,j,n) = -1.d0 * integral 
        three_body_5_index_exch_32(k,j,n,l,m) = -1.d0 * integral 
        ! three permutations with k,i
        three_body_5_index_exch_32(k,l,n,j,m) = -1.d0 * integral 
  
        ! permutation with l,j
        three_body_5_index_exch_32(k,l,m,j,n) = -1.d0 * integral ! j,l
        ! two permutations with l,j
        three_body_5_index_exch_32(k,l,m,j,n) = -1.d0 * integral 
        three_body_5_index_exch_32(k,l,n,j,m) = -1.d0 * integral 
        ! two permutations with l,j
  
        ! permutation with m,n
        three_body_5_index_exch_32(k,j,n,l,m) = -1.d0 * integral ! m,n
        ! two permutations with m,n
        three_body_5_index_exch_32(k,j,n,l,m) = -1.d0 * integral ! m,n
        three_body_5_index_exch_32(k,l,n,j,m) = -1.d0 * integral ! m,n
        ! three permutations with k,i
      enddo
     enddo
    enddo
   enddo
  enddo
 !$OMP END DO
 !$OMP END PARALLEL
!endif
 call wall_time(wall1)
 print*,'wall time for three_body_5_index_exch_32',wall1 - wall0
!if(write_six_index_tensor)then
! print*,'Writing three_body_5_index_exch_32 on disk ...'
! call write_array_6_index_tensor(mo_num,three_body_5_index_exch_32,name_file)
! call ezfio_set_three_body_5_index_exch_32_io_six_index_tensor("Read")
!endif

END_PROVIDER 



