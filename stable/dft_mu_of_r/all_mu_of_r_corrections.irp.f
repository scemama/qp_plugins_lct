program write_integrals_for_dft
 implicit none
 read_wf = .true.
 touch read_wf
 io_mo_one_e_integrals = "None"
 touch io_mo_two_e_integrals
 io_ao_two_e_integrals = "None"
 touch io_ao_two_e_integrals


 print*,'**********************'
 print*,'**********************'
 print*,'LDA / HF coallescence'
 mu_of_r_functional ="basis_set_LDA"
 touch mu_of_r_functional
 mu_of_r_potential = "hf_coallescence"
 touch mu_of_r_potential 
 call print_contribution_dft_mu_of_r
 print*,'**********************'
 print*,'**********************'
 print*,'LDA and PBE / HF coallescence'
 mu_of_r_functional ="basis_set_on_top_PBE"
 touch mu_of_r_functional
 mu_of_r_potential = "hf_coallescence" 
 touch mu_of_r_potential 
 call print_contribution_dft_mu_of_r

 print*,'**********************'
 print*,'**********************'
 print*,'LDA and PBE / PSI coallescence'
 mu_of_r_functional ="basis_set_on_top_PBE"
 touch mu_of_r_functional
 mu_of_r_potential = "psi_coallescence"
 touch mu_of_r_potential 
 call print_contribution_dft_mu_of_r

end

