

!-------------------------------------------------------------------------------------------------------------------------------------------
  subroutine  ecmdsrPBEn2(mu,rho_a,rho_b,grad_rho_a_2,grad_rho_b_2,grad_rho_a_b,rho2,ec_srmuPBE,decdrho_a,decdrho_b, decdgrad_rho_a_2,decdgrad_rho_b_2,decdgrad_rho_a_b, decdrho2_a, decdrho2_b)

  implicit none
  BEGIN_DOC
  ! Calculation of correlation energy and chemical potential in PBE approximation using multideterminantal wave function (short-range part) with exact on top pair density
  END_DOC
 
  double precision, intent(in)  :: mu
  double precision, intent(in)  :: rho_a,rho_b,grad_rho_a_2,grad_rho_b_2,grad_rho_a_b, rho2
  double precision, intent(out) :: ec_srmuPBE,decdrho_a,decdrho_b,decdgrad_rho_a_2,decdgrad_rho_b_2,decdgrad_rho_a_b,decdrho2_a, decdrho2_b
  !double precision, intent(out) :: decdrho, decdgrad_rho_2, decdrho2 
  double precision              :: ecPBE, decPBEdrho_a, decPBEdrho_b, decPBEdgrad_rho_2, decPBEdgrad_rho_a_2, decPBEdgrad_rho_b_2, decPBEdgrad_rho_a_b
  double precision              :: rho_c, rho_o,grad_rho_c_2, grad_rho_o_2, grad_rho_o_c, decPBEdrho_c, decPBEdrho_o, decPBEdgrad_rho_c_2, decPBEdgrad_rho_o_2, decPBEdgrad_rho_c_o, decPBEdgrad_rho_o, grad_rho_2
  double precision              :: beta, dbetadrho_a, dbetadrho_b, dbetadgrad_rho_a_2, dbetadgrad_rho_b_2, dbetadgrad_rho_a_b
  double precision              :: denom, ddenomdrho_a, ddenomdrho_b, ddenomdgrad_rho_a_2,ddenomdgrad_rho_b_2,ddenomdgrad_rho_a_b, ddenomdrho2_a, ddenomdrho2_b
  double precision              :: pi, c, thr
  double precision              :: rho, m  
 
  if(abs(rho_a-rho_b) > 1.d-12)then
  stop "routine implemented only for closed-shell systems"
  endif 

  pi = dacos(-1.d0)
  rho = rho_a + rho_b
  m = rho_a - rho_b
  thr = 1.d-12
  
! correlation PBE standard and on-top pair distribution 
  call rho_ab_to_rho_oc(rho_a,rho_b,rho_o,rho_c)
  call grad_rho_ab_to_grad_rho_oc(grad_rho_a_2,grad_rho_b_2,grad_rho_a_b,grad_rho_o_2,grad_rho_2,grad_rho_o_c)

  call ec_pbe_sr(1.d-12,rho_c,rho_o,grad_rho_2,grad_rho_o_2,grad_rho_o_c,ecPBE,decPBEdrho_c,decPBEdrho_o,decPBEdgrad_rho_2,decPBEdgrad_rho_o_2, decPBEdgrad_rho_o)

  call v_rho_oc_to_v_rho_ab(decPBEdrho_o, decPBEdrho_c, decPBEdrho_a, decPBEdrho_b)
  call v_grad_rho_oc_to_v_grad_rho_ab(decPBEdgrad_rho_o_2, decPBEdgrad_rho_2, decPBEdgrad_rho_o, decPBEdgrad_rho_a_2, decPBEdgrad_rho_b_2, decPBEdgrad_rho_a_b)

! calculation of energy
  c = 2*dsqrt(pi)*(1.d0 - dsqrt(2.d0))/3.d0
   
  beta = ecPBE/(c*rho2)
  if(dabs(beta).lt.thr)then
   beta = 1.d-12
  endif

  denom = 1.d0 + beta*mu**3
  ec_srmuPBE=ecPBE/denom

! calculation of derivatives 
  !dec/dn
  dbetadrho_a = decPBEdrho_a/(c*rho2)
  dbetadrho_b = decPBEdrho_b/(c*rho2) 
 
  ddenomdrho_a = dbetadrho_a*mu**3
  ddenomdrho_b = dbetadrho_b*mu**3

  decdrho_a = decPBEdrho_a/denom - ecPBE*ddenomdrho_a/(denom**2)
  decdrho_b = decPBEdrho_b/denom - ecPBE*ddenomdrho_b/(denom**2)
  !decdrho   = 0.5d0*(decdrho_a + decdrho_b)

  !dec/((dgradn)^2)
  dbetadgrad_rho_a_2 = decPBEdgrad_rho_a_2/(c*rho2)
  dbetadgrad_rho_b_2 = decPBEdgrad_rho_b_2/(c*rho2) 
  dbetadgrad_rho_a_b = decPBEdgrad_rho_a_b/(c*rho2) 
  
  ddenomdgrad_rho_a_2 = dbetadgrad_rho_a_2*mu**3
  ddenomdgrad_rho_b_2 = dbetadgrad_rho_b_2*mu**3 
  ddenomdgrad_rho_a_b = dbetadgrad_rho_a_b*mu**3 
  
  decdgrad_rho_a_2 = decPBEdgrad_rho_a_2/denom - ecPBE*ddenomdgrad_rho_a_2/(denom**2)
  decdgrad_rho_b_2 = decPBEdgrad_rho_b_2/denom - ecPBE*ddenomdgrad_rho_b_2/(denom**2)
  decdgrad_rho_a_b = decPBEdgrad_rho_a_b/denom - ecPBE*ddenomdgrad_rho_a_b/(denom**2)
  !decdgrad_rho_2   = 0.25d0*(decdgrad_rho_a_2 + decdgrad_rho_b_2 + decdgrad_rho_a_b)

  !dec/dn2
  ddenomdrho2_a = - (mu**3)* ecPBE/(c*rho2**2)
  ddenomdrho2_b = - (mu**3)* ecPBE/(c*rho2**2)
 
  decdrho2_a  = - ecPBE*ddenomdrho2_a/(denom**2)
  decdrho2_b  = - ecPBE*ddenomdrho2_b/(denom**2)

  !decdrho2 = 0.5d0*(decdrho2_a + decdrho2_b)

  end subroutine ecmdsrPBE

!-----------------------------------------------------------------Integrales------------------------------------------------------------------

 BEGIN_PROVIDER[double precision, energy_c_md_sr_pbe_n2, (N_states) ]
 implicit none
 BEGIN_DOC
 ! Correlation energies  with the short-range version Perdew-Burke-Ernzerhof GGA functional using exact on-top pair density
 !
 ! defined in Chem. Phys.329, 276 (2006)
 END_DOC 
 integer :: istate,ipoint,j,m
 double precision :: two_dm_in_r_exact
 double precision :: weight, r(3)
 double precision :: ec_srmuPBE, mu
 double precision :: rho2, rho_a,rho_b,grad_rho_a(3),grad_rho_b(3),grad_rho_a_2,grad_rho_b_2,grad_rho_a_b
 double precision :: decdrho_a, decdrho_b, decdrho2_a, decdrho2_b, decdrho2
 double precision :: decdgrad_rho_a_2,decdgrad_rho_b_2,decdgrad_rho_a_b

 energy_c_md_sr_pbe_n2 = 0.d0
 do istate = 1, N_states
  do ipoint = 1, n_points_final_grid
   r(1) = final_grid_points(1,ipoint)
   r(2) = final_grid_points(2,ipoint)
   r(3) = final_grid_points(3,ipoint)

   weight = final_weight_at_r_vector(ipoint)
   rho_a =  one_e_dm_and_grad_alpha_in_r(4,ipoint,istate)
   rho_b =  one_e_dm_and_grad_beta_in_r(4,ipoint,istate)

   call give_on_top_in_r_one_state(r,istate,rho2)
   grad_rho_a(1:3) =  one_e_dm_and_grad_alpha_in_r(1:3,ipoint,istate)
   grad_rho_b(1:3) =  one_e_dm_and_grad_beta_in_r(1:3,ipoint,istate)
   grad_rho_a_2 = 0.d0
   grad_rho_b_2 = 0.d0
   grad_rho_a_b = 0.d0
   do m = 1, 3
    grad_rho_a_2 += grad_rho_a(m) * grad_rho_a(m)
    grad_rho_b_2 += grad_rho_b(m) * grad_rho_b(m)
    grad_rho_a_b += grad_rho_a(m) * grad_rho_b(m)
   enddo

   mu = mu_of_r_prov(ipoint,istate)
   rho2 = rho2*2.d0 ! normalization

   call ecmdsrPBEn2(mu,rho_a,rho_b,grad_rho_a_2,grad_rho_b_2,grad_rho_a_b,rho2,ec_srmuPBE,decdrho_a,decdrho_b,decdgrad_rho_a_2,decdgrad_rho_b_2,decdgrad_rho_a_b,decdrho2_a, decdrho2_b)

   decdrho2_a = 2.d0*decdrho2_a ! normalization
   decdrho2_b = 2.d0*decdrho2_b
   ! rho2 = rho2_a + rho2_b
   ! m2 = rho2_a - rho2_b
   ! rho2_a = 0.5(rho2 + m2)     rho2_b = 0.5(rho2 - m2)
   ! decrrho2 =  decdrho2_a * drho2_a/drho2 + decdrho2_b * drho2_b/drho2
   decdrho2   = 0.5d0*(decdrho2_a + decdrho2_b) !A verifier quand même
   energy_c_md_sr_pbe_n2(istate) += ec_srmuPBE * weight
  enddo
 enddo

END_PROVIDER


 BEGIN_PROVIDER [double precision, potential_c_alpha_mo_md_sr_pbe_n2,(mo_num,mo_num,N_states)]
&BEGIN_PROVIDER [double precision, potential_c_beta_mo_md_sr_pbe_n2,(mo_num,mo_num,N_states)]
   implicit none
 call ao_to_mo(potential_c_alpha_ao_md_sr_pbe_n2,ao_num,potential_c_alpha_mo_md_sr_pbe_n2,mo_num)
 call ao_to_mo(potential_c_beta_ao_md_sr_pbe_n2,ao_num,potential_c_beta_mo_md_sr_pbe_n2,mo_num)
END_PROVIDER 

 BEGIN_PROVIDER [double precision, potential_c_alpha_ao_md_sr_pbe_n2,(ao_num,ao_num,N_states)]
&BEGIN_PROVIDER [double precision, potential_c_beta_ao_md_sr_pbe_n2,(ao_num,ao_num,N_states)]
   implicit none
 BEGIN_DOC
 ! blablabla bis 
 !
 ! 
 END_DOC 
   integer :: i,j,istate
   do istate = 1, n_states 
    do i = 1, ao_num
     do j = 1, ao_num
      potential_c_alpha_ao_md_sr_pbe_n2(j,i,istate) = pot_scal_c_alpha_ao_md_sr_pbe_n2(j,i,istate) + pot_grad_c_alpha_ao_md_sr_pbe_n2(j,i,istate) + pot_grad_c_alpha_ao_md_sr_pbe_n2(i,j,istate)
      potential_c_beta_ao_md_sr_pbe_n2(j,i,istate) = pot_scal_c_beta_ao_md_sr_pbe_n2(j,i,istate) + pot_grad_c_beta_ao_md_sr_pbe_n2(j,i,istate) + pot_grad_c_beta_ao_md_sr_pbe_n2(i,j,istate)
     enddo
    enddo
   enddo

END_PROVIDER 

 BEGIN_PROVIDER[double precision, aos_vc_alpha_md_sr_pbe_w_n2  , (ao_num,n_points_final_grid,N_states)]
&BEGIN_PROVIDER[double precision, aos_vc_beta_md_sr_pbe_w_n2   , (ao_num,n_points_final_grid,N_states)]
&BEGIN_PROVIDER[double precision, aos_d_vc_alpha_md_sr_pbe_w_n2  , (ao_num,n_points_final_grid,N_states)]
&BEGIN_PROVIDER[double precision, aos_d_vc_beta_md_sr_pbe_w_n2   ,  (ao_num,n_points_final_grid,N_states)]
&BEGIN_PROVIDER[double precision, d_dn2_e_cmd_sr_pbe_n2, (n_points_final_grid,N_states) ]
 implicit none
 BEGIN_DOC
! intermediates to compute the sr_pbe potentials 
 END_DOC
 integer :: istate,ipoint,j,m
 double precision :: weight, r(3)
 double precision :: ec_srmuPBE,mu
 double precision :: rho_a,rho_b,grad_rho_a(3),grad_rho_b(3),grad_rho_a_2,grad_rho_b_2,grad_rho_a_b,rho2
 double precision :: contrib_grad_ca(3),contrib_grad_cb(3)
 double precision :: decdrho_a, decdrho_b,decdrho, decdrho2_a, decdrho2_b, decdrho2
 double precision :: decdgrad_rho_a_2,decdgrad_rho_b_2,decdgrad_rho_a_b, decdgrad_rho_2
 double precision :: mu_correction_of_on_top

 aos_d_vc_alpha_md_sr_pbe_w_n2 = 0.d0
 aos_d_vc_beta_md_sr_pbe_w_n2 = 0.d0
 do istate = 1, N_states
  do ipoint = 1, n_points_final_grid
   r(1) = final_grid_points(1,ipoint)
   r(2) = final_grid_points(2,ipoint)
   r(3) = final_grid_points(3,ipoint)
   weight = final_weight_at_r_vector(ipoint)
   rho_a =  one_e_dm_and_grad_alpha_in_r(4,ipoint,istate)
   rho_b =  one_e_dm_and_grad_beta_in_r(4,ipoint,istate)
   call give_on_top_in_r_one_state(r,istate,rho2)
   grad_rho_a(1:3) =  one_e_dm_and_grad_alpha_in_r(1:3,ipoint,istate)
   grad_rho_b(1:3) =  one_e_dm_and_grad_beta_in_r(1:3,ipoint,istate)
   grad_rho_a_2 = 0.d0
   grad_rho_b_2 = 0.d0
   grad_rho_a_b = 0.d0
   do m = 1, 3
    grad_rho_a_2 += grad_rho_a(m) * grad_rho_a(m)
    grad_rho_b_2 += grad_rho_b(m) * grad_rho_b(m)
    grad_rho_a_b += grad_rho_a(m) * grad_rho_b(m)
   enddo
   
   rho2 = 2.d0*rho2
   ! mu_erf_dft -> mu_b
   mu = mu_of_r_prov(ipoint,istate)
   call ecmdsrPBEn2(mu,rho_a,rho_b,grad_rho_a_2,grad_rho_b_2,grad_rho_a_b,rho2,ec_srmuPBE,decdrho_a,decdrho_b,decdgrad_rho_a_2,decdgrad_rho_b_2,decdgrad_rho_a_b,decdrho2_a,decdrho_b)
   
  
   decdrho_a *= weight
   decdrho_b *= weight

   do m= 1,3
    contrib_grad_ca(m) = weight * (2.d0 * decdgrad_rho_a_2 *  grad_rho_a(m) + decdgrad_rho_a_b  * grad_rho_b(m) )
    contrib_grad_cb(m) = weight * (2.d0 * decdgrad_rho_b_2 *  grad_rho_b(m) + decdgrad_rho_a_b  * grad_rho_a(m) )
   enddo

   do j = 1, ao_num
    aos_vc_alpha_md_sr_pbe_w_n2(j,ipoint,istate) = decdrho_a * aos_in_r_array(j,ipoint)
    aos_vc_beta_md_sr_pbe_w_n2 (j,ipoint,istate) = decdrho_b * aos_in_r_array(j,ipoint)
   enddo
   do j = 1, ao_num
    do m = 1,3
     aos_d_vc_alpha_md_sr_pbe_w_n2(j,ipoint,istate) += contrib_grad_ca(m) * aos_grad_in_r_array_transp(m,j,ipoint)
     aos_d_vc_beta_md_sr_pbe_w_n2 (j,ipoint,istate) += contrib_grad_cb(m) * aos_grad_in_r_array_transp(m,j,ipoint)
    enddo
   enddo
  enddo
 enddo

 END_PROVIDER

 BEGIN_PROVIDER [double precision, pot_scal_c_alpha_ao_md_sr_pbe_n2, (ao_num,ao_num,N_states)]
&BEGIN_PROVIDER [double precision, pot_scal_c_beta_ao_md_sr_pbe_n2, (ao_num,ao_num,N_states)]
 implicit none
! intermediates to compute the sr_pbe potentials 
! 
 integer                        :: istate
   BEGIN_DOC
   ! intermediate quantity for the calculation of the vxc potentials for the GGA functionals  related to the scalar part of the potential 
   END_DOC
   pot_scal_c_alpha_ao_md_sr_pbe_n2 = 0.d0
   pot_scal_c_beta_ao_md_sr_pbe_n2 = 0.d0
   double precision               :: wall_1,wall_2
   call wall_time(wall_1)
   do istate = 1, N_states
     ! correlation alpha
     call dgemm('N','T',ao_num,ao_num,n_points_final_grid,1.d0,                   &
                 aos_vc_alpha_md_sr_pbe_w_n2(1,1,istate),size(aos_vc_alpha_md_sr_pbe_w_n2,1), &
                 aos_in_r_array,size(aos_in_r_array,1),1.d0,                      &
                 pot_scal_c_alpha_ao_md_sr_pbe_n2(1,1,istate),size(pot_scal_c_alpha_ao_md_sr_pbe_n2,1))
     ! correlation beta
     call dgemm('N','T',ao_num,ao_num,n_points_final_grid,1.d0,                   &
                 aos_vc_beta_md_sr_pbe_w_n2(1,1,istate),size(aos_vc_beta_md_sr_pbe_w_n2,1),   &
                 aos_in_r_array,size(aos_in_r_array,1),1.d0,                      &
                 pot_scal_c_beta_ao_md_sr_pbe_n2(1,1,istate),size(pot_scal_c_beta_ao_md_sr_pbe_n2,1))
 
   enddo
 call wall_time(wall_2)

END_PROVIDER 

 BEGIN_PROVIDER [double precision, pot_grad_c_alpha_ao_md_sr_pbe_n2,(ao_num,ao_num,N_states)]
&BEGIN_PROVIDER [double precision, pot_grad_c_beta_ao_md_sr_pbe_n2,(ao_num,ao_num,N_states)]
   implicit none
   BEGIN_DOC
   ! intermediate quantity for the calculation of the vxc potentials for the GGA functionals  related to the gradienst of the density and orbitals 
   END_DOC
   integer                        :: istate
   double precision               :: wall_1,wall_2
   call wall_time(wall_1)
   pot_grad_c_alpha_ao_md_sr_pbe_n2 = 0.d0
   pot_grad_c_beta_ao_md_sr_pbe_n2 = 0.d0
   do istate = 1, N_states
       ! correlation alpha
       call dgemm('N','N',ao_num,ao_num,n_points_final_grid,1.d0,                     &
                  aos_d_vc_alpha_md_sr_pbe_w_n2(1,1,istate),size(aos_d_vc_alpha_md_sr_pbe_w_n2,1),  &
                  aos_in_r_array_transp,size(aos_in_r_array_transp,1),1.d0,           &
                  pot_grad_c_alpha_ao_md_sr_pbe_n2(1,1,istate),size(pot_grad_c_alpha_ao_md_sr_pbe_n2,1))
       ! correlation beta
       call dgemm('N','N',ao_num,ao_num,n_points_final_grid,1.d0,                     &
                  aos_d_vc_beta_md_sr_pbe_w_n2(1,1,istate),size(aos_d_vc_beta_md_sr_pbe_w_n2,1),    &
                  aos_in_r_array_transp,size(aos_in_r_array_transp,1),1.d0,           &
                  pot_grad_c_beta_ao_md_sr_pbe_n2(1,1,istate),size(pot_grad_c_beta_ao_md_sr_pbe_n2,1))
   enddo
   
 call wall_time(wall_2)

END_PROVIDER
