
subroutine diagonalize_CI_dressed(E_tc,norm,pt2_data,print_pt2)
  use selection_types
  implicit none
  double precision, intent(inout)  :: E_tc,norm
  type(pt2_type)  , intent(in)   :: pt2_data
  logical, intent(in) :: print_pt2
  BEGIN_DOC
!  Replace the coefficients of the CI states by the coefficients of the
!  eigenstates of the CI matrix
  END_DOC
  integer :: i,j
  do j=1,N_states
    do i=1,N_det
      psi_coef(i,j) = reigvec_tc(i,j)
    enddo
  enddo
  SOFT_TOUCH psi_coef
  print*,'*****'
  print*,'N_det tc               = ',N_det
  print*,'norm_ground_left_right = ',norm_ground_left_right
  print*,'eigval_right_tc = ',eigval_right_tc(1)
  print*,'Ndet, E_tc = ',N_det,eigval_right_tc(1)
  if(print_pt2)then
   print*,'norm(before)    = ',norm
   print*,'E(before)       = ',E_tc
   print*,'E(before) + PT2 = ',E_tc + (pt2_data % pt2(1))/norm
!  print*,'E+PT2           = ',eigval_right_tc(1) + pt2_data % pt2(1)
!  print*,'E+PT2/norm      = ',eigval_right_tc(1) + (pt2_data % pt2(1))/norm_ground_left_right
   print*,'PT2             = ',pt2_data % pt2(1)
   print*,'Ndet, E_tc, E+PT2 = ',N_det,eigval_right_tc(1),E_tc + (pt2_data % pt2(1))/norm
  endif
  E_tc  = eigval_right_tc(1)
  norm  = norm_ground_left_right
end
