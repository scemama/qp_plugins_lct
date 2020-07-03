subroutine big_thing
 implicit none 
 double precision :: weight1,r1(3),weight2,r2(3),int_ao
 double precision :: ao_two_e_integral_schwartz_accel_gauss
 double precision :: int_r2(3),int_gauss_num,alpha_r12,coef,r12,int_r2_bis(3)
 integer :: ipoint,i,j,n_pt_in,jpoint,m
 double precision :: aos_array_r1(ao_num),aos_array_r2(ao_num),aos_grad_array_r1(3,ao_num),aos_grad_array_r2(3,ao_num)
 double precision :: accu_relat(3),accu_abs(3),err_relat,err_abs
 double precision :: accu_tmp(3),d_dr12(3),mu_in,derf_mu_x,accu_tmp_bis(3)
 include 'utils/constants.include.F'
 integer :: iao,jao,kao,lao
 mu_in = mu_erf
 accu_abs = 0.d0
 accu_relat = 0.d0
 do jao = 1, ao_num ! r1
  do lao = 1, ao_num ! r2
   do iao = 1, ao_num ! r1
    do kao = 1, ao_num ! r2
! do jao = 1, 1! r1
!  do lao = 1, 1 ! r2
!   do iao = 1, 1 ! r1
!    do kao = 3, 3 ! r2
     print*,'<ij|kl> = ',iao,jao,kao,lao
     call ao_two_e_d_dr12_int(iao,jao,kao,lao,mu_in,d_dr12)
     int_gauss_num = 0.d0
     accu_tmp = 0.d0
     accu_tmp_bis = 0.d0
     do ipoint = 1, n_points_final_grid
      r1(1) = final_grid_points(1,ipoint)
      r1(2) = final_grid_points(2,ipoint)
      r1(3) = final_grid_points(3,ipoint)
      call give_all_aos_and_grad_at_r(r1,aos_array_r1,aos_grad_array_r1)
      weight1 = final_weight_at_r_vector(ipoint)
      int_r2 = 0.d0
      int_r2_bis = 0.d0
      do jpoint = 1, n_points_final_grid
       r2(1) = final_grid_points(1,jpoint)
       r2(2) = final_grid_points(2,jpoint)
       r2(3) = final_grid_points(3,jpoint)
       weight2 = final_weight_at_r_vector(jpoint)
       call give_all_aos_and_grad_at_r(r2,aos_array_r2,aos_grad_array_r2)
       r12 = (r1(1) - r2(1))**2.d0 + (r1(2) - r2(2))**2.d0 + (r1(3) - r2(3))**2.d0 
       r12 = dsqrt(r12)
       do m = 1, 3

        int_r2_bis(m) += weight2 * 0.5d0 * derf_mu_x(mu_in,r12) & 
                             * (r1(m) - r2(m)) *  aos_array_r1(jao) * aos_array_r2(lao)  & 
                             * (aos_grad_array_r1(m,iao) * aos_array_r2(kao) - aos_grad_array_r2(m,kao) * aos_array_r1(iao))

!       !!!!!!!!! x1 dx1 i(r1)
        int_r2(m) += weight2 * 0.5d0 * derf_mu_x(mu_in,r12)      & 
                             * r1(m) * aos_grad_array_r1(m,iao)  & 
                             *  aos_array_r2(kao)                & 
                             *  aos_array_r1(jao) * aos_array_r2(lao)  
       !!!!!!!!! x2 dx2 k(r2)
        int_r2(m) += weight2 * 0.5d0 * derf_mu_x(mu_in,r12)      & 
                             * r2(m) * aos_grad_array_r2(m,kao)  & 
                             *  aos_array_r1(iao)                & 
                             *  aos_array_r1(jao) * aos_array_r2(lao)  
!       !!!!!!!!! x1 i(r1) dx2 k(r1)
        int_r2(m) -= weight2 * 0.5d0 * derf_mu_x(mu_in,r12)      & 
                             * r1(m) * aos_array_r1(iao)  & 
                             *  aos_grad_array_r2(m,kao)                & 
                             *  aos_array_r1(jao) * aos_array_r2(lao)  
!       !!!!!!!!! x2 k(r2) dx1 i(r1)
        int_r2(m) -= weight2 * 0.5d0 * derf_mu_x(mu_in,r12)      & 
                             * r2(m) * aos_array_r2(kao)  & 
                             *  aos_grad_array_r1(m,iao)                & 
                             *  aos_array_r1(jao) * aos_array_r2(lao)  
       enddo
      enddo
      do m = 1, 3
       accu_tmp(m) += weight1 * int_r2(m)
       accu_tmp_bis(m) += weight1 * int_r2_bis(m)
      enddo
     enddo
     do m = 1, 3
      int_gauss_num = accu_tmp(m)
      int_ao = d_dr12(m)
      err_abs = dabs(int_gauss_num - int_ao)
      if(int_gauss_num.gt.1.d-10)then
       err_relat = err_abs/dabs(int_gauss_num)
      else
       err_relat = 0.d0
      endif
      print*,'m = ',m
      print*,'int_gauss_num = ',int_gauss_num
      print*,'accu_tmp_bis(m)=',accu_tmp_bis(m)
      print*,'int_ao        = ',int_ao
      print*,'abs error     = ',err_abs
      print*,'err_relat     = ',err_relat
      if(err_relat .gt. 1.d-6)then
       print*,'AHAHAHAAH'
       stop
      endif
      accu_abs(m) += err_abs
      accu_relat(m) += err_relat
     enddo
    enddo
   enddo
  enddo
 enddo
 print*,''
 print*,''
 print*,''
 print*,'Summary'
 print*,''
 print*,''
 print*,''
 print*,'accu_abs   = ',accu_abs/dble(ao_num**4)
 print*,'accu_relat = ',accu_relat/dble(ao_num**4)
end

double precision function derf_mu_x(mu,x)
 implicit none
 include 'utils/constants.include.F'
 double precision, intent(in) :: mu,x
  if(dabs(x).gt.1.d-6)then
   derf_mu_x = derf(mu * x)/x
  else
   derf_mu_x =  inv_sq_pi * 2.d0 * mu * (1.d0 - mu*mu*x*x/3.d0)
  endif

end
