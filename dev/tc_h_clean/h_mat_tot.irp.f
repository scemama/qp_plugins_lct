
subroutine htilde_mu_mat_tot(key_j, key_i, Nint, htot)

  BEGIN_DOC
  ! <key_j | H_tilde | key_i> 
  !!
  !! WARNING !!
  ! 
  ! Non hermitian !!
  END_DOC

  use bitmasks

  implicit none
  integer, intent(in)           :: Nint
  integer(bit_kind), intent(in) :: key_j(Nint,2),key_i(Nint,2)
  double precision, intent(out) :: htot
  double precision              :: hmono, heff, hderiv, hthree

  call htilde_mu_mat(key_j, key_i, Nint, hmono, heff, hderiv, hthree, htot)
  htot = hmono + heff + hderiv + hthree

end subroutine htilde_mu_mat_tot



subroutine htilde_mu_mat(key_j, key_i, Nint, hmono, heff, hderiv, hthree, htot)

  BEGIN_DOC
  ! <key_j | H_tilde | key_i> 
  !!
  !! WARNING !!
  ! 
  ! Non hermitian !!
  END_DOC

  use bitmasks
  implicit none
  integer,           intent(in) :: Nint
  integer(bit_kind), intent(in) :: key_j(Nint,2), key_i(Nint,2)
  double precision, intent(out) :: hmono, heff, hderiv, hthree, htot
  integer                       :: degree

  call get_excitation_degree(key_j, key_i, degree, Nint)

  hmono  = 0.d0
  heff   = 0.d0
  hderiv = 0.d0
  hthree = 0.d0
  htot   = 0.d0

  if(degree.gt.3)then
    return
  else if(degree == 2) then
    call double_htilde_mu_mat_scal_map(Nint, key_j, key_i, hmono, heff, hderiv, htot)
  else if(degree == 1) then
    call single_htilde_mu_mat_scal_map(Nint, key_j, key_i, hmono, heff, hderiv, htot)
  else if(degree == 0) then
    call diag_htilde_mu_mat_scal_map(Nint, key_i, hmono, heff, hderiv, htot)
  endif

  if(three_body_h_tc) then
    if(degree == 2) then
      if(.not.double_normal_ord) then
        call double_htilde_mu_mat_three_body(Nint, key_j, key_i, hthree)
      endif
    else if(degree == 1)then
      call single_htilde_mu_mat_three_body(Nint, key_j, key_i, hthree)
    else if(degree == 0)then
      call diag_htilde_mu_mat_three_body(Nint, key_i, hthree)
    endif
  endif

  htot += hthree
   
end subroutine htilde_mu_mat




! -------------------------------------------------------------------------------------------------

! ---

subroutine htildedag_mu_mat_tot(key_j, key_i, Nint, htot)

  BEGIN_DOC
  ! <key_j | H_tilde_dag | key_i> 
  !!
  !! WARNING !!
  ! 
  ! Non hermitian !!
  END_DOC

  use bitmasks

  implicit none
  integer,           intent(in) :: Nint
  integer(bit_kind), intent(in) :: key_j(Nint,2), key_i(Nint,2)
  double precision, intent(out) :: htot
  double precision              :: hmono, heff, hderiv, hthree

  call htildedag_mu_mat(key_j, key_i, Nint, hmono, heff, hderiv, hthree, htot)
  htot = hmono + heff + hderiv + hthree

end subroutine htildedag_mu_mat_tot

! ---

subroutine htildedag_mu_mat(key_j, key_i, Nint, hmono, heff, hderiv, hthree, htot)

  BEGIN_DOC
  ! <key_j | H_tilde_dag | key_i> 
  !!
  !! WARNING !!
  ! 
  ! Non hermitian !!
  END_DOC

  use bitmasks

  implicit none
  integer,           intent(in) :: Nint
  integer(bit_kind), intent(in) :: key_j(Nint,2), key_i(Nint,2)
  double precision, intent(out) :: hmono, heff, hderiv, hthree, htot
  integer                       :: degree

  hmono  = 0.d0
  heff   = 0.d0
  hderiv = 0.d0
  hthree = 0.d0
  htot   = 0.d0

  call get_excitation_degree(key_j, key_i, degree, Nint)

  if(degree.gt.3) then
    return
  else if(degree == 2) then
    call double_htildedag_mu_mat_scal_map(Nint, key_j, key_i, hmono, heff, hderiv, htot)
  else if(degree == 1) then
    call single_htildedag_mu_mat_scal_map(Nint, key_j, key_i, hmono, heff, hderiv, htot)
  else if(degree == 0) then
    call diag_htildedag_mu_mat_scal_map(Nint, key_i, hmono, heff, hderiv, htot)
  endif

  if(three_body_h_tc) then
    if(degree == 2) then
      if(.not.double_normal_ord) then
        call double_htilde_mu_mat_three_body(Nint, key_j, key_i, hthree)
        hthree = -hthree !dag
      endif
    else if(degree == 1) then
      call single_htilde_mu_mat_three_body(Nint, key_j, key_i, hthree)
    else if(degree == 0) then
      call diag_htilde_mu_mat_three_body(Nint, key_i,hthree)
    endif
  endif
  
  htot += hthree
   
end subroutine htildedag_mu_mat

! ---

! -------------------------------------------------------------------------------------------------
