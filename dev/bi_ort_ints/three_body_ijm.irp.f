BEGIN_PROVIDER [ double precision, three_e_3_idx_direct_bi_ort, (mo_num, mo_num, mo_num)]
 implicit none
 BEGIN_DOC
! matrix element of the -L  three-body operator ON A BI ORTHONORMAL BASIS for the direct terms 
!
! three_e_3_idx_direct_bi_ort(m,j,i) = <mji|L|mji>
! 
! notice the -1 sign: in this way three_e_3_idx_direct_bi_ort can be directly used to compute Slater rules :)
 END_DOC
 integer :: i,j,m
 double precision :: integral, wall1, wall0
 character*(128) :: name_file 
 three_e_3_idx_direct_bi_ort = 0.d0
 print*,'Providing the three_e_3_idx_direct_bi_ort ...'
 call wall_time(wall0)
 name_file = 'six_index_tensor'
 provide x_W_ki_bi_ortho_erf_rk mos_r_in_r_array_transp mos_l_in_r_array_transp
 !$OMP PARALLEL                  &
 !$OMP DEFAULT (NONE)            &
 !$OMP PRIVATE (i,j,m,integral) & 
 !$OMP SHARED (mo_num,three_e_3_idx_direct_bi_ort)
 !$OMP DO SCHEDULE (dynamic)
  do i = 1, mo_num
   do j = 1, mo_num
    do m = 1, mo_num
      call give_integrals_3_body_bi_ort(m,j,i,m,j,i,integral)
      three_e_3_idx_direct_bi_ort(m,j,i) = -1.d0 * integral 
    enddo
   enddo
  enddo
 !$OMP END DO
 !$OMP END PARALLEL
 call wall_time(wall1)
 print*,'wall time for three_e_3_idx_direct_bi_ort',wall1 - wall0

END_PROVIDER 

BEGIN_PROVIDER [ double precision, three_e_3_idx_cycle_1_bi_ort, (mo_num, mo_num, mo_num)]
 implicit none
 BEGIN_DOC
! matrix element of the -L  three-body operator ON A BI ORTHONORMAL BASIS for the first cyclic permutation 
!
! three_e_3_idx_direct_bi_ort(m,j,i) = <mji|L|jim>
!
! notice the -1 sign: in this way three_e_3_idx_cycle_1_bi_ort can be directly used to compute Slater rules :)
 END_DOC
 integer :: i,j,m
 double precision :: integral, wall1, wall0
 character*(128) :: name_file 
 three_e_3_idx_cycle_1_bi_ort = 0.d0
 print*,'Providing the three_e_3_idx_cycle_1_bi_ort ...'
 call wall_time(wall0)
 name_file = 'six_index_tensor'
 provide x_W_ki_bi_ortho_erf_rk mos_r_in_r_array_transp mos_l_in_r_array_transp
 !$OMP PARALLEL                  &
 !$OMP DEFAULT (NONE)            &
 !$OMP PRIVATE (i,j,m,integral) & 
 !$OMP SHARED (mo_num,three_e_3_idx_cycle_1_bi_ort)
 !$OMP DO SCHEDULE (dynamic)
  do i = 1, mo_num
   do j = 1, mo_num
    do m = 1, mo_num
      call give_integrals_3_body_bi_ort(m,j,i,j,i,m,integral)
      three_e_3_idx_cycle_1_bi_ort(m,j,i) = -1.d0 * integral 
    enddo
   enddo
  enddo
 !$OMP END DO
 !$OMP END PARALLEL
 call wall_time(wall1)
 print*,'wall time for three_e_3_idx_cycle_1_bi_ort',wall1 - wall0

END_PROVIDER 

BEGIN_PROVIDER [ double precision, three_e_3_idx_cycle_2_bi_ort, (mo_num, mo_num, mo_num)]
 implicit none
 BEGIN_DOC
! matrix element of the -L  three-body operator ON A BI ORTHONORMAL BASIS for the second cyclic permutation 
!
! three_e_3_idx_direct_bi_ort(m,j,i) = <mji|L|imj>
!
! notice the -1 sign: in this way three_e_3_idx_cycle_2_bi_ort can be directly used to compute Slater rules :)
 END_DOC
 integer :: i,j,m
 double precision :: integral, wall1, wall0
 character*(128) :: name_file 
 three_e_3_idx_cycle_2_bi_ort = 0.d0
 print*,'Providing the three_e_3_idx_cycle_2_bi_ort ...'
 call wall_time(wall0)
 name_file = 'six_index_tensor'
 provide x_W_ki_bi_ortho_erf_rk mos_r_in_r_array_transp mos_l_in_r_array_transp
 !$OMP PARALLEL                  &
 !$OMP DEFAULT (NONE)            &
 !$OMP PRIVATE (i,j,m,integral) & 
 !$OMP SHARED (mo_num,three_e_3_idx_cycle_2_bi_ort)
 !$OMP DO SCHEDULE (dynamic)
  do i = 1, mo_num
   do j = 1, mo_num
    do m = 1, mo_num
      call give_integrals_3_body_bi_ort(m,j,i,i,m,j,integral)
      three_e_3_idx_cycle_2_bi_ort(m,j,i) = -1.d0 * integral 
    enddo
   enddo
  enddo
 !$OMP END DO
 !$OMP END PARALLEL
 call wall_time(wall1)
 print*,'wall time for three_e_3_idx_cycle_2_bi_ort',wall1 - wall0

END_PROVIDER 

BEGIN_PROVIDER [ double precision, three_e_3_idx_exch23_bi_ort, (mo_num, mo_num, mo_num)]
 implicit none
 BEGIN_DOC
! matrix element of the -L  three-body operator ON A BI ORTHONORMAL BASIS for the permutations of particle 2 and 3
!
! three_e_3_idx_exch23_bi_ort(m,j,i) = <mji|L|jmi>
! 
! notice the -1 sign: in this way three_e_3_idx_exch23_bi_ort can be directly used to compute Slater rules :)
 END_DOC
 integer :: i,j,m
 double precision :: integral, wall1, wall0
 character*(128) :: name_file 
 three_e_3_idx_exch23_bi_ort = 0.d0
 print*,'Providing the three_e_3_idx_exch23_bi_ort ...'
 call wall_time(wall0)
 name_file = 'six_index_tensor'
 provide x_W_ki_bi_ortho_erf_rk mos_r_in_r_array_transp mos_l_in_r_array_transp
 !$OMP PARALLEL                  &
 !$OMP DEFAULT (NONE)            &
 !$OMP PRIVATE (i,j,m,integral) & 
 !$OMP SHARED (mo_num,three_e_3_idx_exch23_bi_ort)
 !$OMP DO SCHEDULE (dynamic)
  do i = 1, mo_num
   do j = 1, mo_num
    do m = 1, mo_num
      call give_integrals_3_body_bi_ort(m,j,i,j,m,i,integral)
      three_e_3_idx_exch23_bi_ort(m,j,i) = -1.d0 * integral 
    enddo
   enddo
  enddo
 !$OMP END DO
 !$OMP END PARALLEL
 call wall_time(wall1)
 print*,'wall time for three_e_3_idx_exch23_bi_ort',wall1 - wall0

END_PROVIDER 

BEGIN_PROVIDER [ double precision, three_e_3_idx_exch13_bi_ort, (mo_num, mo_num, mo_num)]
 implicit none
 BEGIN_DOC
! matrix element of the -L  three-body operator ON A BI ORTHONORMAL BASIS for the permutations of particle 1 and 3
!
! three_e_3_idx_exch13_bi_ort(m,j,i) = <mji|L|ijm>
! 
! notice the -1 sign: in this way three_e_3_idx_exch13_bi_ort can be directly used to compute Slater rules :)
 END_DOC
 integer :: i,j,m
 double precision :: integral, wall1, wall0
 character*(128) :: name_file 
 three_e_3_idx_exch13_bi_ort = 0.d0
 print*,'Providing the three_e_3_idx_exch13_bi_ort ...'
 call wall_time(wall0)
 name_file = 'six_index_tensor'
 provide x_W_ki_bi_ortho_erf_rk mos_r_in_r_array_transp mos_l_in_r_array_transp
 !$OMP PARALLEL                  &
 !$OMP DEFAULT (NONE)            &
 !$OMP PRIVATE (i,j,m,integral) & 
 !$OMP SHARED (mo_num,three_e_3_idx_exch13_bi_ort)
 !$OMP DO SCHEDULE (dynamic)
  do i = 1, mo_num
   do j = 1, mo_num
    do m = 1, mo_num
      call give_integrals_3_body_bi_ort(m,j,i,i,j,m,integral)
      three_e_3_idx_exch13_bi_ort(m,j,i) = -1.d0 * integral 
    enddo
   enddo
  enddo
 !$OMP END DO
 !$OMP END PARALLEL
 call wall_time(wall1)
 print*,'wall time for three_e_3_idx_exch13_bi_ort',wall1 - wall0

END_PROVIDER 

BEGIN_PROVIDER [ double precision, three_e_3_idx_exch12_bi_ort, (mo_num, mo_num, mo_num)]
 implicit none
 BEGIN_DOC
! matrix element of the -L  three-body operator ON A BI ORTHONORMAL BASIS for the permutations of particle 1 and 2
!
! three_e_3_idx_exch12_bi_ort(m,j,i) = <mji|L|mij>
! 
! notice the -1 sign: in this way three_e_3_idx_exch12_bi_ort can be directly used to compute Slater rules :)
 END_DOC
 integer :: i,j,m
 double precision :: integral, wall1, wall0
 character*(128) :: name_file 
 three_e_3_idx_exch12_bi_ort = 0.d0
 print*,'Providing the three_e_3_idx_exch12_bi_ort ...'
 call wall_time(wall0)
 name_file = 'six_index_tensor'
 provide x_W_ki_bi_ortho_erf_rk mos_r_in_r_array_transp mos_l_in_r_array_transp
 !$OMP PARALLEL                  &
 !$OMP DEFAULT (NONE)            &
 !$OMP PRIVATE (i,j,m,integral) & 
 !$OMP SHARED (mo_num,three_e_3_idx_exch12_bi_ort)
 !$OMP DO SCHEDULE (dynamic)
  do i = 1, mo_num
   do j = 1, mo_num
    do m = 1, mo_num
      call give_integrals_3_body_bi_ort(m,j,i,m,i,j,integral)
      three_e_3_idx_exch12_bi_ort(m,j,i) = -1.d0 * integral 
    enddo
   enddo
  enddo
 !$OMP END DO
 !$OMP END PARALLEL
 call wall_time(wall1)
 print*,'wall time for three_e_3_idx_exch12_bi_ort',wall1 - wall0

END_PROVIDER 

