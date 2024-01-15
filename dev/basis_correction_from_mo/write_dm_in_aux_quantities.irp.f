program write_dm_in_aux_quantities
  implicit none
  BEGIN_DOC
! READ the one-e density matrix (in MO basis )in a file and write it in aux_quantities/
! also convert from MO to AO basis
! Input files are labeled mo_alpha_1rdm.txt and mo_beta_1rdm.txt
  END_DOC

  double precision, dimension (mo_num, mo_num) :: one_e_dm_beta_mo_from_file_mo_num_size
  double precision, dimension (mo_num, mo_num) :: one_e_dm_alpha_mo_from_file_mo_num_size
  double precision, dimension (n_act_orb, n_act_orb) :: one_e_dm_beta_mo_from_file
  double precision, dimension (n_act_orb, n_act_orb) :: one_e_dm_alpha_mo_from_file
  double precision, dimension (ao_num, ao_num) :: one_e_dm_alpha_ao_from_file
  double precision, dimension (ao_num, ao_num) :: one_e_dm_beta_ao_from_file
  integer :: i, j


  one_e_dm_alpha_mo_from_file_mo_num_size = 0.d0 
  one_e_dm_beta_mo_from_file_mo_num_size = 0.d0 
  
  do i=1, n_core_orb
    one_e_dm_alpha_mo_from_file_mo_num_size(i,i) = 1.d0
    one_e_dm_beta_mo_from_file_mo_num_size(i,i) = 1.d0
  enddo

  ! READ 1-e alpha density matrix in MO basis:
  open(12, file="mo_alpha_1rdm.txt") 
  read(12,*) one_e_dm_alpha_mo_from_file
  one_e_dm_alpha_mo_from_file = transpose(one_e_dm_alpha_mo_from_file)

  ! READ 1-e beta density matrix in MO basis:
  open(13, file="mo_beta_1rdm.txt") 
  read(13,*) one_e_dm_beta_mo_from_file
  one_e_dm_beta_mo_from_file = transpose(one_e_dm_beta_mo_from_file)

  do i=1, n_act_orb
   do j=1, n_act_orb
    one_e_dm_alpha_mo_from_file_mo_num_size(i+n_core_orb,j+n_core_orb) = one_e_dm_alpha_mo_from_file(i,j)
    one_e_dm_beta_mo_from_file_mo_num_size(i+n_core_orb,j+n_core_orb) = one_e_dm_beta_mo_from_file(i,j) 
   enddo
  enddo
  
  ! BUILD density matrix in AO basis:
  call mo_to_ao_no_overlap(one_e_dm_alpha_mo_from_file_mo_num_size,mo_num,one_e_dm_alpha_ao_from_file,ao_num)
  call mo_to_ao_no_overlap(one_e_dm_beta_mo_from_file_mo_num_size,mo_num,one_e_dm_beta_ao_from_file,ao_num)

  ! Write in EZFIO 
  call ezfio_set_aux_quantities_data_one_e_dm_alpha_mo(one_e_dm_alpha_mo_from_file_mo_num_size)
  call ezfio_set_aux_quantities_data_one_e_dm_beta_mo(one_e_dm_beta_mo_from_file_mo_num_size) 
  call ezfio_set_aux_quantities_data_one_e_dm_alpha_ao(one_e_dm_alpha_ao_from_file)
  call ezfio_set_aux_quantities_data_one_e_dm_beta_ao(one_e_dm_beta_ao_from_file)

  close(12)
  close(13)
end
