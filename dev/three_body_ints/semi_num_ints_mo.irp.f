
BEGIN_PROVIDER [ double precision, mo_v_ij_erf_rk_naive, ( mo_num, mo_num,n_points_final_grid)]
 implicit none
 BEGIN_DOC
! int dr phi_i(r) phi_j(r) (erf(mu(R) |r - R|) - 1 )/(2|r - R|) on the MO basis
 END_DOC
 integer :: i,j,k,l,ipoint
 do ipoint = 1, n_points_final_grid
  mo_v_ij_erf_rk_naive(:,:,ipoint) = 0.d0
  do i = 1, mo_num
   do j = 1, mo_num
    do k = 1, ao_num
     do l = 1, ao_num
      mo_v_ij_erf_rk_naive(j,i,ipoint) += mo_coef(l,j) * 0.5d0 * v_ij_erf_rk(l,k,ipoint) * mo_coef(k,i)
     enddo
    enddo
   enddo
  enddo
 enddo
END_PROVIDER 

BEGIN_PROVIDER [ double precision, mo_v_ij_erf_rk, ( mo_num, mo_num,n_points_final_grid)]
 implicit none
 BEGIN_DOC
! int dr phi_i(r) phi_j(r) (erf(mu(R) |r - R|) - 1)/(2|r - R|) on the MO basis
 END_DOC
 integer :: ipoint
 do ipoint = 1, n_points_final_grid
   call ao_to_mo(v_ij_erf_rk(1,1,ipoint),size(v_ij_erf_rk,1),mo_v_ij_erf_rk(1,1,ipoint),size(mo_v_ij_erf_rk,1))
 enddo
 mo_v_ij_erf_rk = mo_v_ij_erf_rk * 0.5d0
END_PROVIDER 

BEGIN_PROVIDER [ double precision, mo_v_ij_erf_rk_transp, ( n_points_final_grid,mo_num, mo_num)]
 implicit none
 BEGIN_DOC
! int dr phi_i(r) phi_j(r) (erf(mu(R) |r - R|) - 1)/(2|r - R|) on the MO basis
 END_DOC
 integer :: ipoint,i,j
 do i = 1, mo_num
  do j = 1, mo_num
   do ipoint = 1, n_points_final_grid
    mo_v_ij_erf_rk_transp(ipoint,j,i) = mo_v_ij_erf_rk(j,i,ipoint)
   enddo
  enddo
 enddo
 FREE mo_v_ij_erf_rk
END_PROVIDER 


BEGIN_PROVIDER [ double precision, mo_x_v_ij_erf_rk_naive, ( mo_num, mo_num,3,n_points_final_grid)]
 implicit none
 BEGIN_DOC
! int dr  x * phi_i(r) phi_j(r) (erf(mu(R) |r - R|) - 1 )/|r - R| on the MO basis
 END_DOC
 integer :: i,j,k,l,ipoint,m
 do ipoint = 1, n_points_final_grid
  mo_x_v_ij_erf_rk_naive(:,:,:,ipoint) = 0.d0
  do i = 1, mo_num
   do j = 1, mo_num
    do m = 1, 3
     do k = 1, ao_num
      do l = 1, ao_num
       mo_x_v_ij_erf_rk_naive(j,i,m,ipoint) += mo_coef(l,j) * 0.5d0 * x_v_ij_erf_rk_transp(l,k,m,ipoint) * mo_coef(k,i)
      enddo
     enddo
    enddo
   enddo
  enddo
 enddo
END_PROVIDER 

BEGIN_PROVIDER [ double precision, mo_x_v_ij_erf_rk, ( mo_num, mo_num,3,n_points_final_grid)]
 implicit none
 BEGIN_DOC
! int dr x * phi_i(r) phi_j(r) (erf(mu(R) |r - R|) - 1)/|r - R| on the MO basis
 END_DOC
 integer :: ipoint,m
 do ipoint = 1, n_points_final_grid
  do m = 1, 3
   call ao_to_mo(x_v_ij_erf_rk_transp(1,1,m,ipoint),size(x_v_ij_erf_rk_transp,1),mo_x_v_ij_erf_rk(1,1,m,ipoint),size(mo_x_v_ij_erf_rk,1))
  enddo
 enddo
 mo_x_v_ij_erf_rk = 0.5d0 * mo_x_v_ij_erf_rk

END_PROVIDER 


BEGIN_PROVIDER [ double precision, x_W_ij_erf_rk, ( n_points_final_grid,3,mo_num, mo_num)]
 implicit none
 BEGIN_DOC
! W_mn^X(R) = \int dr phi_m(r) phi_n(r) (1 - erf(mu |r-R|)) (x-X)
 END_DOC
 integer :: ipoint,m,i,j
 double precision :: xyz
 do i = 1, mo_num
  do j = 1, mo_num
   do m = 1, 3
    do ipoint = 1, n_points_final_grid
     xyz = final_grid_points(m,ipoint)
     x_W_ij_erf_rk(ipoint,m,j,i) =  mo_x_v_ij_erf_rk(j,i,m,ipoint) - xyz * mo_v_ij_erf_rk_transp(ipoint,j,i)
    enddo
   enddo
  enddo
 enddo
 FREE mo_v_ij_erf_rk_transp 
 FREE mo_x_v_ij_erf_rk

END_PROVIDER 


