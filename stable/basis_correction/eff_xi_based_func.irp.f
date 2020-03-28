BEGIN_PROVIDER [double precision, ecmd_pbe_ueg_eff_xi_mu_of_r, (N_states)]
 BEGIN_DOC
 ! ecmd_pbe_ueg_eff_xi_mu_of_r = multi-determinantal Ecmd within the PBE-UEG and effective spin polarization approximation with mu(r),
 ! 
 ! see Eqs. 30 in ???????????
 !
 ! Based on the PBE-on-top functional (see Eqs. 26, 27 of J. Chem. Phys.150, 084103 (2019); doi: 10.1063/1.5082638)
 !
 ! but it replaces the approximation of the exact on-top pair density by the on-top of the UEG 
 !
 ! and uses the effective spin polarization (depending on the on-top density) as spin polarization in the PBE functional. 
 !
 ! See P. Perdew, A. Savin, and K. Burke, Phys. Rev. A 51, 4531 (1995). for original Ref., and Eq. 29 in ???????????
 END_DOC
 implicit none
 double precision :: weight,density
 integer :: ipoint,istate
 double precision,allocatable  :: eps_c_md_PBE(:),mu(:),rho_a(:),rho_b(:),grad_rho_a(:,:),grad_rho_b(:,:)

 allocate(eps_c_md_PBE(N_states),mu(N_states),rho_a(N_states),rho_b(N_states),grad_rho_a(3,N_states),grad_rho_b(3,N_states))
 ecmd_pbe_ueg_eff_xi_mu_of_r = 0.d0
  
 print*,'Providing ecmd_pbe_ueg_eff_xi_mu_of_r ...'
 call wall_time(wall0)
 do ipoint = 1, n_points_final_grid
  weight=final_weight_at_r_vector(ipoint)

  do istate = 1, N_states
   density =  one_e_dm_and_grad_alpha_in_r(4,ipoint,istate)  + one_e_dm_and_grad_beta_in_r(4,ipoint,istate) 
   rho_a(istate) = 0.5d0 * (density + effective_spin_dm(ipoint,istate))
   rho_b(istate) = 0.5d0 * (density - effective_spin_dm(ipoint,istate))
   grad_rho_a(1:3,istate) = one_e_dm_and_grad_alpha_in_r(1:3,ipoint,istate)
   grad_rho_b(1:3,istate) = one_e_dm_and_grad_beta_in_r(1:3,ipoint,istate)
   mu(istate) = mu_of_r_prov(ipoint,istate)
  enddo

  call eps_c_md_PBE_from_density(mu,rho_a,rho_b, grad_rho_a, grad_rho_b,eps_c_md_PBE)

  do istate = 1, N_states
   ecmd_pbe_ueg_eff_xi_mu_of_r(istate) += eps_c_md_PBE(istate) * weight
  enddo
 enddo
 double precision :: wall1, wall0
 call wall_time(wall1)
 print*,'Time for the ecmd_pbe_ueg_eff_xi_mu_of_r:',wall1-wall0

END_PROVIDER


 BEGIN_PROVIDER [double precision, ecmd_lda_eff_xi_mu_of_r, (N_states)]                                                                      
 BEGIN_DOC
 ! ecmd_lda_eff_xi_mu_of_r = multi-determinantal Ecmd within the LDA and effective spin polarization approximation with mu(r),
 !
 ! corresponds to equation 40 in J. Chem. Phys. 149, 194301 (2018); https://doi.org/10.1063/1.5052714 
 !
 ! BUT with an effective spin polarization depending on the on-top pair density 
 ! 
 ! See P. Perdew, A. Savin, and K. Burke, Phys. Rev. A 51, 4531 (1995). for original Ref., and Eq. 29 in ???????????
 END_DOC
 implicit none
 integer :: ipoint,istate
 double precision :: rho_a, rho_b, ec
 logical :: dospin
 double precision :: wall0,wall1,weight,mu,density
 dospin = .true. ! JT dospin have to be set to true for open shell
 print*,'Providing ecmd_lda_eff_xi_mu_of_r ...'

 ecmd_lda_eff_xi_mu_of_r = 0.d0
 call wall_time(wall0)
 do istate = 1, N_states
  do ipoint = 1, n_points_final_grid
   mu      = mu_of_r_prov(ipoint,istate)
   weight  = final_weight_at_r_vector(ipoint)

   density =  one_e_dm_and_grad_alpha_in_r(4,ipoint,istate)  + one_e_dm_and_grad_beta_in_r(4,ipoint,istate) 
   rho_a   = 0.5d0 * (density + effective_spin_dm(ipoint,istate))
   rho_b   = 0.5d0 * (density - effective_spin_dm(ipoint,istate))

   call ESRC_MD_LDAERF (mu,rho_a,rho_b,dospin,ec)
   if(isnan(ec))then
    print*,'ec is nan'
    stop
   endif
   ecmd_lda_eff_xi_mu_of_r(istate) += weight * ec
  enddo
 enddo
 call wall_time(wall1)
 print*,'Time for ecmd_lda_eff_xi_mu_of_r :',wall1-wall0
 END_PROVIDER 

