! routine that helps in building the x/c potentials on the AO basis for a GGA functional with a short-range interaction
 ! From Emmanuel's plugins: dft_utils_one_e/utils.irp.f
 !
 !-----------------------------------------------------------------------------------------------------------------------------------
 ! Parameter             : Definition                                                                   ; Source
 ! ----------------------------------------------------------------------------------------------------------------------------------
 ! a, b and c            :                                                                              ; from (2), eq. ??
 ! B1, C1, D1, E1, F1    :                                                                              ; from (2)
 ! beta                  :                                                                              ; from (2), eq. ??
 ! delta                 :                                                                              ; from (2), eq. ??
 ! dbetadrho             : dbeta/dn                                                                     ;
 ! ddeltadrho            : ddelta/dn                                                                    ;
 ! dgammadrho            : dgamma/dn                                                                    ;
 ! dg0drho               : dg0/dn                                                                       ; from (5), eq. 12
 ! dg0drs                : dg0/drs                                                                      ; from (5), eq. 14
 ! decdrho, decdgrad_rho : decsrmuPBE/dn and decsrmuPBE/dgradrho                                        ; from (3) and (4)
 ! decPBEdrho            : decPBE/dn                                                                    ;
 ! decPBEdgrad_rho_2     :                                                                              ; 
 ! dexdrho, dexdgrad_rho : dexsrmuPBE/dn and dexsrmuPBE/dgradrho                                        ; from (3) and (4)
 ! dexPBEdrho            : dexPBE/dn                                                                    ;
 ! dexPBEdgrad_rho_2     : dexPBE/dgrad(n)^2                                                            ;
 ! ecPBE                 : Usual density of correlation energy                                          ; from (1), already done in QP
 ! ec_srmuPBE            :
 ! exPBE                 : Usual density of exchange energy                                             ; from (1), already done in QP
 ! ex_srmuPBE            :
 ! gamma                 :                                                                              ; from (2), eq. ??
 ! g0                    : On-top pair-distribution function of the spin-unpolarized UEG                ;
 ! g0_UEG_mu_inf         :                                                                              ; rsdft_ecmd/ueg_on_top.irp.f
 ! grad_rho              : gradient of density                                                          ; 
 ! n2_UEG                : On-top pair density of the uniform electron gas                              ; from (2), eq. 51
 ! n2xc_UEG              : On-top exchange-correlation pair density of the uniform electron gas         ; from (2), below eq. 55
 ! rho                   : rho_a + rho_b (both densities of spins alpha and beta)                       ;
 ! rs                    : Seitz radius                                                                 ; rsdft_ecmd/ueg_on_top.irp.f
 !-----------------------------------------------------------------------------------------------------------------------------------
 ! SOURCES
 !-----------------------------------------------------------------------------------------------------------------------------------
 ! (1) : Generalized Gradient Approximation Made Simple - J. P. Perdew, K. Burke, M. Ernzerhof - PRL(77),18 (28/10/96)
 ! (2) : Short-range exchange and correlation density functionnals - J. Toulouse (Odense-Paris collaboration)
 ! (3) : A. Ferté's Thesis
 ! (4) : Developpement of eq. to be done
 ! (5) : Supplementary Materials for 'A density-based basis-set incomleteness correction for GW Methods' 
 !       - P.-F. Loos, B. Pradines, A. Scemama, E. Giner, J. Toulouse - ???????????
 ! 
 ! n = na + nb  | m = na - nb
 ! na = (n+m)/2 | nb = (n-m)/2
 ! gn2       = ga2 + gb2 + 2 gab | ga2 = (gn2 + gm2 + 2gnm)/4
 ! gm2       = ga2 + gb2 - 2 gab | gb2 = (gn2 + gm2 - 2gnm)/4
 ! gnm       = ga2 - gb2         | gab = (gn2 - gm2)/4
 ! dedn      = dedna * dnadn + dednb * dnbdn = (1/2) * (dedna + dednb)
 ! dedgn2    = dedga2 * dga2/dgn2    + dedgb2 * dgb2dgn2     + dedgab * dgabdgn2       = 0.25*(dedga2 + dedgb2 + dedgagb) 
 ! dedgna2   = dedgn2 * dgn2/dgna2   + dedgm2 * dgm2/dgna2   + dedgngm * dgngm/dgna    = dedgn2 + dedgm2 + dedgngm
 ! dedgnb2   = dedgn2 * dgn2/dgnb2   + dedgm2 * dgm2/dgnb2   + dedgngm * dgngm/dgnb    = dedgn2 + dedgm2 - dedgngm
 ! dedgnagnb = dedgn2 * dgn2/dgnagnb + dedgm2 * dgm2/dgnagnb + dedgngm * dgngm/dgnagnb = 2*dedgn2 - 2*dedgm2 
 !----------------------------------------------------------------------------------------------------------------------------------- 
!-------------------------------------------------------------------------------------------------------------------------------------------
  subroutine exmdsrPBE(mu,rho_a,rho_b,grad_rho_a_2,grad_rho_b_2,grad_rho_a_b,ex_srmuPBE,dexdrho_a,dexdrho_b, dexdgrad_rho_a_2,dexdgrad_rho_b_2,dexdgrad_rho_a_b)
  
  implicit none
  BEGIN_DOC
  ! Calculation of exchange energy and chemical potential in PBE approximation using multideterminantal wave function (short-range part)
  END_DOC
  double precision, intent(in)  :: mu
  double precision, intent(in)  :: rho_a, rho_b, grad_rho_a_2, grad_rho_b_2, grad_rho_a_b
  double precision, intent(out) :: ex_srmuPBE, dexdrho_a, dexdrho_b, dexdgrad_rho_a_2, dexdgrad_rho_b_2, dexdgrad_rho_a_b
   double precision              :: dexdrho, dexdgrad_rho_2
  double precision              :: exPBE, dexPBEdrho_a, dexPBEdrho_b, dexPBEdrho, dexPBEdgrad_rho_a_2, dexPBEdgrad_rho_b_2, dexPBEdgrad_rho_a_b, dexPBEdgrad_rho_2
  double precision              :: gamma, dgammadrho_a, dgammadrho_b, dgammadgrad_rho_a_2, dgammadgrad_rho_b_2, dgammadgrad_rho_a_b
  double precision              :: delta, ddeltadrho_a, ddeltadrho_b, ddeltadgrad_rho_a_2, ddeltadgrad_rho_b_2, ddeltadgrad_rho_a_b
  double precision              :: denom, ddenomdrho_a, ddenomdrho_b, ddenomdgrad_rho_a_2, ddenomdgrad_rho_b_2, ddenomdgrad_rho_a_b  
  double precision              :: pi, a, b, thr
  double precision              :: rho, m  
  double precision              :: n2_UEG, dn2_UEGdrho, dn2_UEGdrho_a, dn2_UEGdrho_b
  double precision              :: n2xc_UEG, dn2xc_UEGdrho, dn2xc_UEGdrho_a, dn2xc_UEGdrho_b
  double precision              :: g0, dg0drho
  
  pi = dacos(-1.d0)
  rho = rho_a + rho_b
  m = rho_a - rho_b
  thr = 1.d-12

  if(dabs(rho) > 1.d-12)then
   if(abs(rho_a-rho_b)/rho > 1.d-3)then
     print*, 'rho_a - rho_b= ', rho_a - rho_b
     stop "routine implemented only for closed-shell systems"
   endif 
  endif

! exchange PBE standard and on-top pair distribution
  call ex_pbe_sr(1.d-12,rho_a,rho_b,grad_rho_a_2,grad_rho_b_2,grad_rho_a_b,exPBE,dexPBEdrho_a,dexPBEdrho_b,dexPBEdgrad_rho_a_2,dexPBEdgrad_rho_b_2,dexPBEdgrad_rho_a_b)
  call g0_dg0(rho, rho_a, rho_b, g0, dg0drho)
  
  if(dabs(exPBE).lt.thr)then
   exPBE = 1.d-12
  endif

  if(dabs(rho).lt.thr)then
   rho = 1.d-12
  endif

  if(dabs(g0).lt.thr)then
    g0 = 1.d-12
  endif

! calculation of energy
  a = pi / 2.d0
  b = 2*dsqrt(pi)*(2*dsqrt(2.d0) - 1.d0)/3.d0   
  
  n2_UEG = (rho**2)*g0
  if(dabs(n2_UEG).lt.thr)then
   n2_UEG = 1.d-12
  endif
  
  n2xc_UEG = n2_UEG - rho**2
  if(dabs(n2xc_UEG).lt.thr)then
   n2xc_UEG = 1.d-12
  endif

  gamma = exPBE / (a*n2xc_UEG)
  if(dabs(gamma).lt.thr)then
   gamma = 1.d-12
  endif

  delta = -(b*n2_UEG*gamma**2) / exPBE
  if(dabs(delta).lt.thr)then
   delta = 1.d-12
  endif
  
  denom = 1.d0 + delta*mu + gamma*(mu**2)

  ex_srmuPBE=exPBE/denom

! calculation of derivatives
  !dex/dn
  dn2_UEGdrho = 2.d0*rho*g0 + (rho**2)*dg0drho
  dn2_UEGdrho_a = 2.d0*rho*g0 + (rho**2)*dg0drho
  dn2_UEGdrho_b = 2.d0*rho*g0 + (rho**2)*dg0drho
  dn2xc_UEGdrho = dn2_UEGdrho - 2.d0*rho
  dn2xc_UEGdrho_a = dn2xc_UEGdrho
  dn2xc_UEGdrho_b = dn2xc_UEGdrho
  
  dgammadrho_a = (1.d0/(a*n2xc_UEG))*dexPBEdrho_a  - (exPBE/(a*n2xc_UEG**2))*dn2xc_UEGdrho_a
  ddeltadrho_a = -((b*gamma**2)/exPBE)*dn2_UEGdrho_a -(b*n2_UEG/exPBE)*2.d0*gamma*dgammadrho_a + (b*n2_UEG*gamma**2)/(exPBE**2)*dexPBEdrho_a
  dgammadrho_b = (1.d0/(a*n2xc_UEG))*dexPBEdrho_b  - (exPBE/(a*n2xc_UEG**2))*dn2xc_UEGdrho_b
  ddeltadrho_b = -((b*gamma**2)/exPBE)*dn2_UEGdrho_b -(b*n2_UEG/exPBE)*2.d0*gamma*dgammadrho_b + (b*n2_UEG*gamma**2)/(exPBE**2)*dexPBEdrho_b

  ddenomdrho_a = ddeltadrho_a * mu + dgammadrho_a * (mu**2)
  ddenomdrho_b = ddeltadrho_b * mu + dgammadrho_b * (mu**2)
  
  dexdrho_a = dexPBEdrho_a/denom - exPBE*ddenomdrho_a/denom**2
  dexdrho_b = dexPBEdrho_b/denom - exPBE*ddenomdrho_b/denom**2
  
!  dexdrho = 0.5d0*(dexdrho_a + dexdrho_b)
 
  !dex/d((gradn)^2)
  dgammadgrad_rho_a_2 =dexPBEdgrad_rho_a_2/(a*n2xc_UEG)
  dgammadgrad_rho_b_2 =dexPBEdgrad_rho_b_2/(a*n2xc_UEG)
  dgammadgrad_rho_a_b =dexPBEdgrad_rho_a_b/(a*n2xc_UEG)

  ddeltadgrad_rho_a_2 = ((b*n2_UEG*gamma**2)/(exPBE**2))*dexPBEdgrad_rho_a_2 - b*(n2_UEG/exPBE)*2.d0*gamma*dgammadgrad_rho_a_2
  ddeltadgrad_rho_b_2 = ((b*n2_UEG*gamma**2)/(exPBE**2))*dexPBEdgrad_rho_b_2 - b*(n2_UEG/exPBE)*2.d0*gamma*dgammadgrad_rho_b_2
  ddeltadgrad_rho_a_b = ((b*n2_UEG*gamma**2)/(exPBE**2))*dexPBEdgrad_rho_a_b - b*(n2_UEG/exPBE)*2.d0*gamma*dgammadgrad_rho_a_b

  ddenomdgrad_rho_a_2 = ddeltadgrad_rho_a_2*mu + dgammadgrad_rho_a_2*mu**2  
  ddenomdgrad_rho_b_2 = ddeltadgrad_rho_b_2*mu + dgammadgrad_rho_b_2*mu**2
  ddenomdgrad_rho_a_b =ddeltadgrad_rho_a_b*mu + dgammadgrad_rho_a_b*mu**2
  
  dexdgrad_rho_a_2 = dexPBEdgrad_rho_a_2/denom - exPBE*ddenomdgrad_rho_a_2/(denom**2)
  dexdgrad_rho_b_2 = dexPBEdgrad_rho_b_2/denom  - exPBE*ddenomdgrad_rho_b_2/(denom**2)
  dexdgrad_rho_a_b = dexPBEdgrad_rho_a_b/denom - exPBE*ddenomdgrad_rho_a_b/(denom**2)

!  print*, 'rho_a - rhob= ', rho_a - rho_b
!  dexdgrad_rho_2 = 0.25d0*(dexdgrad_rho_a_2 + dexdgrad_rho_b_2 + dexdgrad_rho_a_b)
  
!  print*, '..................................'
!  print*, 'rhoa                =', rho_a
!  print*, 'rhob                =', rho_b

!  print*, 'gradrho_a_2         =', grad_rho_a_2
!  print*, 'gradrho_b_2         =', grad_rho_b_2
!  print*, 'gradrho_a_b         =', grad_rho_a_b
!  print*, 'exPBE =', exPBE, 'ex_srmuPBE =', ex_srmuPBE
!  print*, 'dexPBEdrho_a        =', dexPBEdrho_a 
!  print*, 'dexPBEdrho_b        =', dexPBEdrho_b
!  print*, 'dexPBEdgrad_rho_a_2 =', dexPBEdgrad_rho_a_2
!  print*, 'dexPBEdgrad_rho_b_2 =', dexPBEdgrad_rho_b_2
!  print*, 'dexPBEdgrad_rho_a_b= ', dexPBEdgrad_rho_a_b
!  print*, 'dexPBEdgrad_rho_2   =', dexPBEdgrad_rho_2
!  print*, 'dexdrho_a           =', dexdrho_a          
!  print*, 'dexdrho_b           =', dexdrho_b          
!  print*, 'dexdgrad_rho_a_2    =', dexdgrad_rho_a_2   
!  print*, 'dexdgrad_rho_b_2    =', dexdgrad_rho_b_2   
!  print*, 'dexdgrad_rho_a_b    =', dexdgrad_rho_a_b   
!  print*, 'dgammadgrad_rho_a_2 =', dgammadgrad_rho_a_2  
!  print*, 'ddeltadgrad_rho_a_2 =', ddeltadgrad_rho_a_2  
!  print*, 'dgammadgrad_rho_b_2 =', dgammadgrad_rho_b_2  
!  print*, 'ddeltadgrad_rho_b_2 =', ddeltadgrad_rho_b_2  
!  print*, 'dgammadgrad_rho_a_b =', dgammadgrad_rho_a_b  
!  print*, 'ddeltadgrad_rho_a_b =', ddeltadgrad_rho_a_b
!  print*, 'denom               =', denom
!  print*, 'ddenomdgrad_rho_a_2 =', ddenomdgrad_rho_a_2 
!  print*, 'ddenomdgrad_rho_b_2 =', ddenomdgrad_rho_b_2 
!  print*, 'ddenomdgrad_rho_a_b =', ddenomdgrad_rho_a_b 
!  print*, '------> dexdgradrho =', dexdgrad_rho_2   
! print*, '..................................'
  end subroutine exmdsrPBE
!---------------------------------------------------------------------------------------------------------------------------------------------

  subroutine ecmdsrPBE(mu,rho_a,rho_b,grad_rho_a_2,grad_rho_b_2,grad_rho_a_b,ec_srmuPBE,decdrho_a,decdrho_b, decdgrad_rho_a_2,decdgrad_rho_b_2,decdgrad_rho_a_b)

  implicit none
  BEGIN_DOC
  ! Calculation of correlation energy and chemical potential in PBE approximation using multideterminantal wave function (short-range part)
  END_DOC
 
  double precision, intent(in)  :: mu
  double precision, intent(in)  :: rho_a, rho_b, grad_rho_a_2, grad_rho_b_2, grad_rho_a_b
  double precision, intent(out) :: ec_srmuPBE, decdrho_a, decdrho_b, decdgrad_rho_a_2, decdgrad_rho_b_2, decdgrad_rho_a_b
  ! double precision              :: decdgrad_rho_2, decdrho 
  double precision              :: ecPBE, decPBEdrho_a, decPBEdrho_b, decPBEdgrad_rho_a_2, decPBEdgrad_rho_b_2,decPBEdgrad_rho_a_b
  double precision              :: rho_c, rho_o, grad_rho_c_2, grad_rho_o_2, grad_rho_o_c, decPBEdrho_c, decPBEdrho_o, decPBEdgrad_rho_c_2, decPBEdgrad_rho_o_2, decPBEdgrad_rho_c_o
  double precision              :: beta, dbetadrho_a, dbetadrho_b, dbetadgradrho_a_2, dbetadgradrho_b_2, dbetadgradrho_a_b
  double precision              :: denom, ddenomdrho_a, ddenomdrho_b, ddenomdgrad_rho_a_2, ddenomdgrad_rho_b_2, ddenomdgrad_rho_a_b
  double precision              :: pi, c, thr
  double precision              :: rho, m  
  double precision              :: n2_UEG, dn2_UEGdrho_a, dn2_UEGdrho_b
  double precision              :: g0, dg0drho

  pi = dacos(-1.d0)
  rho = rho_a + rho_b
  m = rho_a - rho_b
  thr = 1.d-12
 
  if(dabs(rho) > 1.d-12)then
   if(abs(rho_a-rho_b)/rho > 1.d-3)then
     print*, 'rho_a - rho_b= ', rho_a - rho_b
     stop "routine implemented only for closed-shell systems"
   endif 
  endif
 
! correlation PBE standard and on-top pair distribution 
  call rho_ab_to_rho_oc(rho_a,rho_b,rho_o,rho_c)
  call grad_rho_ab_to_grad_rho_oc(grad_rho_a_2,grad_rho_b_2,grad_rho_a_b,grad_rho_o_2,grad_rho_c_2,grad_rho_o_c)

  call ec_pbe_sr(1.d-12,rho_c,rho_o,grad_rho_c_2,grad_rho_o_2,grad_rho_o_c,ecPBE,decPBEdrho_c,decPBEdrho_o,decPBEdgrad_rho_c_2,decPBEdgrad_rho_o_2, decPBEdgrad_rho_c_o)

  call v_rho_oc_to_v_rho_ab(decPBEdrho_o, decPBEdrho_c, decPBEdrho_a, decPBEdrho_b)
  call v_grad_rho_oc_to_v_grad_rho_ab(decPBEdgrad_rho_o_2, decPBEdgrad_rho_c_2, decPBEdgrad_rho_c_o, decPBEdgrad_rho_a_2, decPBEdgrad_rho_b_2, decPBEdgrad_rho_a_b)

  call g0_dg0(rho, rho_a, rho_b, g0, dg0drho)

! calculation of energy
  c = 2*dsqrt(pi)*(1.d0 - dsqrt(2.d0))/3.d0
  
  n2_UEG = (rho**2)*g0
  if(dabs(n2_UEG).lt.thr)then
   n2_UEG = 1.d-12
  endif  
  
  beta = ecPBE/(c*n2_UEG)
  if(dabs(beta).lt.thr)then
   beta = 1.d-12
  endif

  denom = 1.d0 + beta*mu**3
  ec_srmuPBE=ecPBE/denom

! calculation of derivatives 
  !dec/dn
  
  !n2_UEG = (na^2 + nb^2 + 2nanb)g0
  !dn2_UEGdrhoa = (2na + 2nb)g0 + (na + nb)^2 * dg0drhoa
  !dn2_UEGdrhoa = 2*rho*g0 + rho^2 *dg0drho
  dn2_UEGdrho_a = 2.d0*rho*g0 + (rho**2)*dg0drho
  dn2_UEGdrho_b = 2.d0*rho*g0 + (rho**2)*dg0drho
  
  dbetadrho_a  = decPBEdrho_a/(c*n2_UEG) - (ecPBE/(c*n2_UEG**2))*dn2_UEGdrho_a
  dbetadrho_b  = decPBEdrho_b/(c*n2_UEG) - (ecPBE/(c*n2_UEG**2))*dn2_UEGdrho_b

  ddenomdrho_a = dbetadrho_a*mu**3
  ddenomdrho_b = dbetadrho_b*mu**3
  decdrho_a = decPBEdrho_a/denom - ecPBE*ddenomdrho_a/(denom**2)
  decdrho_b = decPBEdrho_b/denom - ecPBE*ddenomdrho_b/(denom**2)
  ! decdrho = 0.5d0*(decdrho_a + decdrho_b)
  
  !dec/((dgradn)^2)
  dbetadgradrho_a_2 = decPBEdgrad_rho_a_2/(c*n2_UEG)
  dbetadgradrho_b_2 = decPBEdgrad_rho_b_2/(c*n2_UEG)
  dbetadgradrho_a_b = decPBEdgrad_rho_a_b/(c*n2_UEG)
  
  ddenomdgrad_rho_a_2 = dbetadgradrho_a_2*mu**3
  ddenomdgrad_rho_b_2 = dbetadgradrho_b_2*mu**3
  ddenomdgrad_rho_a_b = dbetadgradrho_a_b*mu**3
  
  decdgrad_rho_a_2 = decPBEdgrad_rho_a_2/denom - ecPBE*ddenomdgrad_rho_a_2/(denom**2)
  decdgrad_rho_b_2 = decPBEdgrad_rho_b_2/denom - ecPBE*ddenomdgrad_rho_b_2/(denom**2)
  decdgrad_rho_a_b = decPBEdgrad_rho_a_b/denom - ecPBE*ddenomdgrad_rho_a_b/(denom**2)

  ! decdgrad_rho_2 = 0.25d0*(decdgrad_rho_a_2 + decdgrad_rho_b_2 + decdgrad_rho_a_b)
  end subroutine ecmdsrPBE

!---------------------------------------------------------------------------------------------------------------------------------------------

subroutine exc_dexc_md_sr_PBE(mu,rho_a,rho_b,grad_rho_a_2,grad_rho_b_2,grad_rho_a_b, &
       ex_srmuPBE,dexdrho_a,dexdrho_b,dexdgrad_rho_a_2,dexdgrad_rho_b_2,dexdgrad_rho_a_b, &
       ec_srmuPBE,decdrho_a,decdrho_b,decdgrad_rho_a_2,decdgrad_rho_b_2,decdgrad_rho_a_b)
 
 implicit none
 BEGIN_DOC
 ! Give exchange and correlation energies and chemical potentials
 ! Use qp_plugins_dtraore/sr_md_energies/utils_modified_jt.irp.f's plugins : exmdsrPBE and ecmdsrPBE
 END_DOC
 double precision, intent(in)  :: mu
 double precision, intent(in)  :: rho_a,rho_b,grad_rho_a_2,grad_rho_b_2,grad_rho_a_b
 double precision, intent(out) :: ex_srmuPBE,dexdrho_a,dexdrho_b,dexdgrad_rho_a_2,dexdgrad_rho_b_2,dexdgrad_rho_a_b
 double precision, intent(out) :: ec_srmuPBE,decdrho_a,decdrho_b,decdgrad_rho_a_2,decdgrad_rho_b_2,decdgrad_rho_a_b

 call exmdsrPBE(mu,rho_a,rho_b,grad_rho_a_2,grad_rho_b_2,grad_rho_a_b,ex_srmuPBE,dexdrho_a,dexdrho_b,dexdgrad_rho_a_2,dexdgrad_rho_b_2,dexdgrad_rho_a_b)

 call ecmdsrPBE(mu,rho_a,rho_b,grad_rho_a_2,grad_rho_b_2,grad_rho_a_b,ec_srmuPBE,decdrho_a,decdrho_b,decdgrad_rho_a_2,decdgrad_rho_b_2,decdgrad_rho_a_b)

 end subroutine excmdsrPBE


!-----------------------------------------------------------------Integrales------------------------------------------------------------------
 BEGIN_PROVIDER[double precision, energy_x_md_sr_pbe, (N_states) ]
&BEGIN_PROVIDER[double precision, energy_c_md_sr_pbe, (N_states) ]
 implicit none
 BEGIN_DOC
 ! exchange / correlation energies  with the short-range version Perdew-Burke-Ernzerhof GGA functional 
 !
 ! defined in Chem. Phys.329, 276 (2006)
 END_DOC 
 BEGIN_DOC
! exchange/correlation energy with the short range pbe functional
 END_DOC
 integer :: istate,i,j,m
 double precision :: weight
 double precision :: ex_srmuPBE, ec_srmuPBE
 double precision :: rho_a,rho_b,grad_rho_a(3),grad_rho_b(3),grad_rho_a_2,grad_rho_b_2,grad_rho_a_b
 double precision :: decdrho_a, decdrho_b, dexdrho_a, dexdrho_b
 double precision :: dexdgrad_rho_a_2,dexdgrad_rho_b_2,dexdgrad_rho_a_b,decdgrad_rho_a_2,decdgrad_rho_b_2,decdgrad_rho_a_b



 energy_x_md_sr_pbe = 0.d0
 energy_c_md_sr_pbe = 0.d0
 do istate = 1, N_states
  do i = 1, n_points_final_grid
   weight = final_weight_at_r_vector(i)
   rho_a =  one_e_dm_and_grad_alpha_in_r(4,i,istate)
   rho_b =  one_e_dm_and_grad_beta_in_r(4,i,istate)
   grad_rho_a(1:3) =  one_e_dm_and_grad_alpha_in_r(1:3,i,istate)
   grad_rho_b(1:3) =  one_e_dm_and_grad_beta_in_r(1:3,i,istate)
   grad_rho_a_2 = 0.d0
   grad_rho_b_2 = 0.d0
   grad_rho_a_b = 0.d0
   do m = 1, 3
    grad_rho_a_2 += grad_rho_a(m) * grad_rho_a(m)
    grad_rho_b_2 += grad_rho_b(m) * grad_rho_b(m)
    grad_rho_a_b += grad_rho_a(m) * grad_rho_b(m)
   enddo

   call exc_dexc_md_sr_PBE(mu_erf_dft,rho_a,rho_b,grad_rho_a_2,grad_rho_b_2,grad_rho_a_b, &
       ex_srmuPBE,dexdrho_a,dexdrho_b,dexdgrad_rho_a_2,dexdgrad_rho_b_2,dexdgrad_rho_a_b, &
       ec_srmuPBE,decdrho_a,decdrho_b,decdgrad_rho_a_2,decdgrad_rho_b_2,decdgrad_rho_a_b)

   energy_x_md_sr_pbe(istate) += ex_srmuPBE * weight
   energy_c_md_sr_pbe(istate) += ec_srmuPBE * weight
  enddo
 enddo

END_PROVIDER


!1
 BEGIN_PROVIDER [double precision, potential_x_alpha_ao_md_sr_pbe,(ao_num,ao_num,N_states)]
&BEGIN_PROVIDER [double precision, potential_x_beta_ao_md_sr_pbe,(ao_num,ao_num,N_states)]
&BEGIN_PROVIDER [double precision, potential_c_alpha_ao_md_sr_pbe,(ao_num,ao_num,N_states)]
&BEGIN_PROVIDER [double precision, potential_c_beta_ao_md_sr_pbe,(ao_num,ao_num,N_states)]
   implicit none
 BEGIN_DOC
 ! exchange / correlation potential for alpha / beta electrons  with the short-range version Perdew-Burke-Ernzerhof GGA functional 
 !
 ! defined in Chem. Phys.329, 276 (2006)
 END_DOC 
   integer :: i,j,istate
   do istate = 1, n_states 
    do i = 1, ao_num
     do j = 1, ao_num
      potential_x_alpha_ao_md_sr_pbe(j,i,istate) = pot_scal_x_alpha_ao_md_sr_pbe(j,i,istate) + pot_grad_x_alpha_ao_md_sr_pbe(j,i,istate) + pot_grad_x_alpha_ao_md_sr_pbe(i,j,istate)
      potential_x_beta_ao_md_sr_pbe(j,i,istate) = pot_scal_x_beta_ao_md_sr_pbe(j,i,istate) + pot_grad_x_beta_ao_md_sr_pbe(j,i,istate) + pot_grad_x_beta_ao_md_sr_pbe(i,j,istate)

      potential_c_alpha_ao_md_sr_pbe(j,i,istate) = pot_scal_c_alpha_ao_md_sr_pbe(j,i,istate) + pot_grad_c_alpha_ao_md_sr_pbe(j,i,istate) + pot_grad_c_alpha_ao_md_sr_pbe(i,j,istate)
      potential_c_beta_ao_md_sr_pbe(j,i,istate) = pot_scal_c_beta_ao_md_sr_pbe(j,i,istate) + pot_grad_c_beta_ao_md_sr_pbe(j,i,istate) + pot_grad_c_beta_ao_md_sr_pbe(i,j,istate)
     enddo
    enddo
   enddo

END_PROVIDER 

!2
 BEGIN_PROVIDER [double precision, potential_xc_alpha_ao_md_sr_pbe,(ao_num,ao_num,N_states)]
&BEGIN_PROVIDER [double precision, potential_xc_beta_ao_md_sr_pbe,(ao_num,ao_num,N_states)]
   implicit none
 BEGIN_DOC
 ! exchange / correlation potential for alpha / beta electrons  with the Perdew-Burke-Ernzerhof GGA functional 
 END_DOC 
   integer :: i,j,istate
   do istate = 1, n_states 
    do i = 1, ao_num
     do j = 1, ao_num
      potential_xc_alpha_ao_md_sr_pbe(j,i,istate) = pot_scal_xc_alpha_ao_md_sr_pbe(j,i,istate) + pot_grad_xc_alpha_ao_md_sr_pbe(j,i,istate) + pot_grad_xc_alpha_ao_md_sr_pbe(i,j,istate)
      potential_xc_beta_ao_md_sr_pbe(j,i,istate)  = pot_scal_xc_beta_ao_md_sr_pbe(j,i,istate)  + pot_grad_xc_beta_ao_md_sr_pbe(j,i,istate)  + pot_grad_xc_beta_ao_md_sr_pbe(i,j,istate)
     enddo
    enddo
   enddo

END_PROVIDER 


!3
 BEGIN_PROVIDER[double precision, aos_vc_alpha_md_sr_pbe_w  , (ao_num,n_points_final_grid,N_states)]
&BEGIN_PROVIDER[double precision, aos_vc_beta_md_sr_pbe_w   , (ao_num,n_points_final_grid,N_states)]
&BEGIN_PROVIDER[double precision, aos_vx_alpha_md_sr_pbe_w  , (ao_num,n_points_final_grid,N_states)]
&BEGIN_PROVIDER[double precision, aos_vx_beta_md_sr_pbe_w   , (ao_num,n_points_final_grid,N_states)]
&BEGIN_PROVIDER[double precision, aos_d_vc_alpha_md_sr_pbe_w  , (ao_num,n_points_final_grid,N_states)]
&BEGIN_PROVIDER[double precision, aos_d_vc_beta_md_sr_pbe_w   ,  (ao_num,n_points_final_grid,N_states)]
&BEGIN_PROVIDER[double precision, aos_d_vx_alpha_md_sr_pbe_w  , (ao_num,n_points_final_grid,N_states)]
&BEGIN_PROVIDER[double precision, aos_d_vx_beta_md_sr_pbe_w   ,  (ao_num,n_points_final_grid,N_states)]
 implicit none
 BEGIN_DOC
! intermediates to compute the sr_pbe potentials 
! 
! aos_vxc_alpha_pbe_w(j,i) = ao_i(r_j) * (v^x_alpha(r_j) + v^c_alpha(r_j)) * W(r_j)
 END_DOC
 integer :: istate,i,j,m
 double precision :: weight
 double precision :: ex_srmuPBE, ec_srmuPBE
 double precision :: rho_a,rho_b,grad_rho_a(3),grad_rho_b(3),grad_rho_a_2,grad_rho_b_2,grad_rho_a_b
 double precision :: contrib_grad_xa(3),contrib_grad_xb(3),contrib_grad_ca(3),contrib_grad_cb(3)
 double precision :: decdrho_a, decdrho_b, dexdrho_a, dexdrho_b
 double precision :: dexdgrad_rho_a_2,dexdgrad_rho_b_2,dexdgrad_rho_a_b,decdgrad_rho_a_2,decdgrad_rho_b_2,decdgrad_rho_a_b

 aos_d_vc_alpha_md_sr_pbe_w= 0.d0
 aos_d_vc_beta_md_sr_pbe_w = 0.d0
 aos_d_vx_alpha_md_sr_pbe_w= 0.d0
 aos_d_vx_beta_md_sr_pbe_w = 0.d0
 do istate = 1, N_states
  do i = 1, n_points_final_grid
   weight = final_weight_at_r_vector(i)

   rho_a =  one_e_dm_and_grad_alpha_in_r(4,i,istate)
   rho_b =  one_e_dm_and_grad_beta_in_r(4,i,istate)
   grad_rho_a(1:3) =  one_e_dm_and_grad_alpha_in_r(1:3,i,istate)
   grad_rho_b(1:3) =  one_e_dm_and_grad_beta_in_r(1:3,i,istate)
   grad_rho_a_2 = 0.d0
   grad_rho_b_2 = 0.d0
   grad_rho_a_b = 0.d0
   do m = 1, 3
    grad_rho_a_2 += grad_rho_a(m) * grad_rho_a(m)
    grad_rho_b_2 += grad_rho_b(m) * grad_rho_b(m)
    grad_rho_a_b += grad_rho_a(m) * grad_rho_b(m)
   enddo

   call exc_dexc_md_sr_PBE(mu_erf_dft,rho_a,rho_b,grad_rho_a_2,grad_rho_b_2,grad_rho_a_b, &
       ex_srmuPBE,dexdrho_a,dexdrho_b,dexdgrad_rho_a_2,dexdgrad_rho_b_2,dexdgrad_rho_a_b, &
       ec_srmuPBE,decdrho_a,decdrho_b,decdgrad_rho_a_2,decdgrad_rho_b_2,decdgrad_rho_a_b)

   dexdrho_a *= weight
   decdrho_a *= weight
   dexdrho_b *= weight
   decdrho_b *= weight

   do m= 1,3
    contrib_grad_ca(m) = weight * (2.d0 * decdgrad_rho_a_2 *  grad_rho_a(m) + decdgrad_rho_a_b  * grad_rho_b(m) )
    contrib_grad_xa(m) = weight * (2.d0 * dexdgrad_rho_a_2 *  grad_rho_a(m) + dexdgrad_rho_a_b  * grad_rho_b(m) )
    contrib_grad_cb(m) = weight * (2.d0 * decdgrad_rho_b_2 *  grad_rho_b(m) + decdgrad_rho_a_b  * grad_rho_a(m) )
    contrib_grad_xb(m) = weight * (2.d0 * dexdgrad_rho_b_2 *  grad_rho_b(m) + dexdgrad_rho_a_b  * grad_rho_a(m) )    
   enddo

   do j = 1, ao_num
    aos_vc_alpha_md_sr_pbe_w(j,i,istate) = decdrho_a * aos_in_r_array(j,i)
    aos_vc_beta_md_sr_pbe_w (j,i,istate) = decdrho_b * aos_in_r_array(j,i)
    aos_vx_alpha_md_sr_pbe_w(j,i,istate) = dexdrho_a * aos_in_r_array(j,i)
    aos_vx_beta_md_sr_pbe_w (j,i,istate) = dexdrho_b * aos_in_r_array(j,i)
   enddo
   do j = 1, ao_num
    do m = 1,3
     aos_d_vc_alpha_md_sr_pbe_w(j,i,istate) += contrib_grad_ca(m) * aos_grad_in_r_array_transp(m,j,i)
     aos_d_vc_beta_md_sr_pbe_w (j,i,istate) += contrib_grad_cb(m) * aos_grad_in_r_array_transp(m,j,i)
     aos_d_vx_alpha_md_sr_pbe_w(j,i,istate) += contrib_grad_xa(m) * aos_grad_in_r_array_transp(m,j,i)
     aos_d_vx_beta_md_sr_pbe_w (j,i,istate) += contrib_grad_xb(m) * aos_grad_in_r_array_transp(m,j,i)
    enddo
   enddo
  enddo
 enddo

 END_PROVIDER

!4
 BEGIN_PROVIDER [double precision, pot_scal_x_alpha_ao_md_sr_pbe, (ao_num,ao_num,N_states)]
&BEGIN_PROVIDER [double precision, pot_scal_c_alpha_ao_md_sr_pbe, (ao_num,ao_num,N_states)]
&BEGIN_PROVIDER [double precision, pot_scal_x_beta_ao_md_sr_pbe, (ao_num,ao_num,N_states)]
&BEGIN_PROVIDER [double precision, pot_scal_c_beta_ao_md_sr_pbe, (ao_num,ao_num,N_states)]
 implicit none
! intermediates to compute the sr_pbe potentials 
! 
 integer                        :: istate
   BEGIN_DOC
   ! intermediate quantity for the calculation of the vxc potentials for the GGA functionals  related to the scalar part of the potential 
   END_DOC
   pot_scal_c_alpha_ao_md_sr_pbe = 0.d0
   pot_scal_x_alpha_ao_md_sr_pbe = 0.d0
   pot_scal_c_beta_ao_md_sr_pbe = 0.d0
   pot_scal_x_beta_ao_md_sr_pbe = 0.d0
   double precision               :: wall_1,wall_2
   call wall_time(wall_1)
   do istate = 1, N_states
     ! correlation alpha
     call dgemm('N','T',ao_num,ao_num,n_points_final_grid,1.d0,                   &
                 aos_vc_alpha_md_sr_pbe_w(1,1,istate),size(aos_vc_alpha_md_sr_pbe_w,1), &
                 aos_in_r_array,size(aos_in_r_array,1),1.d0,                      &
                 pot_scal_c_alpha_ao_md_sr_pbe(1,1,istate),size(pot_scal_c_alpha_ao_md_sr_pbe,1))
     ! correlation beta
     call dgemm('N','T',ao_num,ao_num,n_points_final_grid,1.d0,                   &
                 aos_vc_beta_md_sr_pbe_w(1,1,istate),size(aos_vc_beta_md_sr_pbe_w,1),   &
                 aos_in_r_array,size(aos_in_r_array,1),1.d0,                      &
                 pot_scal_c_beta_ao_md_sr_pbe(1,1,istate),size(pot_scal_c_beta_ao_md_sr_pbe,1))
     ! exchange alpha
     call dgemm('N','T',ao_num,ao_num,n_points_final_grid,1.d0,                   &
                 aos_vx_alpha_md_sr_pbe_w(1,1,istate),size(aos_vx_alpha_md_sr_pbe_w,1), &
                 aos_in_r_array,size(aos_in_r_array,1),1.d0,                      &
                 pot_scal_x_alpha_ao_md_sr_pbe(1,1,istate),size(pot_scal_x_alpha_ao_md_sr_pbe,1))
     ! exchange beta
     call dgemm('N','T',ao_num,ao_num,n_points_final_grid,1.d0,                   &
                 aos_vx_beta_md_sr_pbe_w(1,1,istate),size(aos_vx_beta_md_sr_pbe_w,1),   &
                 aos_in_r_array,size(aos_in_r_array,1),1.d0,                      &
                 pot_scal_x_beta_ao_md_sr_pbe(1,1,istate), size(pot_scal_x_beta_ao_md_sr_pbe,1))
 
   enddo
 call wall_time(wall_2)

END_PROVIDER 

!5
 BEGIN_PROVIDER [double precision, pot_grad_x_alpha_ao_md_sr_pbe,(ao_num,ao_num,N_states)]
&BEGIN_PROVIDER [double precision, pot_grad_x_beta_ao_md_sr_pbe,(ao_num,ao_num,N_states)]
&BEGIN_PROVIDER [double precision, pot_grad_c_alpha_ao_md_sr_pbe,(ao_num,ao_num,N_states)]
&BEGIN_PROVIDER [double precision, pot_grad_c_beta_ao_md_sr_pbe,(ao_num,ao_num,N_states)]
   implicit none
   BEGIN_DOC
   ! intermediate quantity for the calculation of the vxc potentials for the GGA functionals  related to the gradienst of the density and orbitals 
   END_DOC
   integer                        :: istate
   double precision               :: wall_1,wall_2
   call wall_time(wall_1)
   pot_grad_c_alpha_ao_md_sr_pbe = 0.d0
   pot_grad_x_alpha_ao_md_sr_pbe = 0.d0
   pot_grad_c_beta_ao_md_sr_pbe = 0.d0
   pot_grad_x_beta_ao_md_sr_pbe = 0.d0
   do istate = 1, N_states
       ! correlation alpha
       call dgemm('N','N',ao_num,ao_num,n_points_final_grid,1.d0,                     &
                  aos_d_vc_alpha_md_sr_pbe_w(1,1,istate),size(aos_d_vc_alpha_md_sr_pbe_w,1),  &
                  aos_in_r_array_transp,size(aos_in_r_array_transp,1),1.d0,           &
                  pot_grad_c_alpha_ao_md_sr_pbe(1,1,istate),size(pot_grad_c_alpha_ao_md_sr_pbe,1))
       ! correlation beta
       call dgemm('N','N',ao_num,ao_num,n_points_final_grid,1.d0,                     &
                  aos_d_vc_beta_md_sr_pbe_w(1,1,istate),size(aos_d_vc_beta_md_sr_pbe_w,1),    &
                  aos_in_r_array_transp,size(aos_in_r_array_transp,1),1.d0,           &
                  pot_grad_c_beta_ao_md_sr_pbe(1,1,istate),size(pot_grad_c_beta_ao_md_sr_pbe,1))
       ! exchange alpha
       call dgemm('N','N',ao_num,ao_num,n_points_final_grid,1.d0,                     &
                  aos_d_vx_alpha_md_sr_pbe_w(1,1,istate),size(aos_d_vx_alpha_md_sr_pbe_w,1),  &
                  aos_in_r_array_transp,size(aos_in_r_array_transp,1),1.d0,           &
                  pot_grad_x_alpha_ao_md_sr_pbe(1,1,istate),size(pot_grad_x_alpha_ao_md_sr_pbe,1))
       ! exchange beta
       call dgemm('N','N',ao_num,ao_num,n_points_final_grid,1.d0,                     &
                  aos_d_vx_beta_md_sr_pbe_w(1,1,istate),size(aos_d_vx_beta_md_sr_pbe_w,1),    &
                  aos_in_r_array_transp,size(aos_in_r_array_transp,1),1.d0,           &
                  pot_grad_x_beta_ao_md_sr_pbe(1,1,istate),size(pot_grad_x_beta_ao_md_sr_pbe,1))
   enddo
   
 call wall_time(wall_2)

END_PROVIDER

!6
 BEGIN_PROVIDER[double precision, aos_vxc_alpha_md_sr_pbe_w  , (ao_num,n_points_final_grid,N_states)]  ! sr_pbe
&BEGIN_PROVIDER[double precision, aos_vxc_beta_md_sr_pbe_w   , (ao_num,n_points_final_grid,N_states)]
&BEGIN_PROVIDER[double precision, aos_d_vxc_alpha_md_sr_pbe_w  , (ao_num,n_points_final_grid,N_states)]
&BEGIN_PROVIDER[double precision, aos_d_vxc_beta_md_sr_pbe_w   ,  (ao_num,n_points_final_grid,N_states)]
 implicit none
 BEGIN_DOC
! aos_vxc_alpha_pbe_w(j,i) = ao_i(r_j) * (v^x_alpha(r_j) + v^c_alpha(r_j)) * W(r_j)
 END_DOC
 integer :: istate,i,j,m
 double precision :: weight
 double precision :: ex_srmuPBE, ec_srmuPBE
 double precision :: rho_a,rho_b,grad_rho_a(3),grad_rho_b(3),grad_rho_a_2,grad_rho_b_2,grad_rho_a_b
 double precision :: contrib_grad_xa(3),contrib_grad_xb(3),contrib_grad_ca(3),contrib_grad_cb(3)
 double precision :: decdrho_a, decdrho_b, dexdrho_a, dexdrho_b
 double precision :: dexdgrad_rho_a_2,dexdgrad_rho_b_2,dexdgrad_rho_a_b,decdgrad_rho_a_2,decdgrad_rho_b_2,decdgrad_rho_a_b
 
 aos_d_vxc_alpha_md_sr_pbe_w = 0.d0
 aos_d_vxc_beta_md_sr_pbe_w = 0.d0

 do istate = 1, N_states
  do i = 1, n_points_final_grid
   weight = final_weight_at_r_vector(i)
   rho_a =  one_e_dm_and_grad_alpha_in_r(4,i,istate)
   rho_b =  one_e_dm_and_grad_beta_in_r(4,i,istate)
   grad_rho_a(1:3) =  one_e_dm_and_grad_alpha_in_r(1:3,i,istate)
   grad_rho_b(1:3) =  one_e_dm_and_grad_beta_in_r(1:3,i,istate)
   grad_rho_a_2 = 0.d0
   grad_rho_b_2 = 0.d0
   grad_rho_a_b = 0.d0
   do m = 1, 3
    grad_rho_a_2 += grad_rho_a(m) * grad_rho_a(m)
    grad_rho_b_2 += grad_rho_b(m) * grad_rho_b(m)
    grad_rho_a_b += grad_rho_a(m) * grad_rho_b(m)
   enddo

   call exc_dexc_md_sr_PBE(mu_erf_dft,rho_a,rho_b,grad_rho_a_2,grad_rho_b_2,grad_rho_a_b, &
       ex_srmuPBE,dexdrho_a,dexdrho_b,dexdgrad_rho_a_2,dexdgrad_rho_b_2,dexdgrad_rho_a_b, &
       ec_srmuPBE,decdrho_a,decdrho_b,decdgrad_rho_a_2,decdgrad_rho_b_2,decdgrad_rho_a_b)
 
   dexdrho_a *= weight
   decdrho_a *= weight
   dexdrho_b *= weight
   decdrho_b *= weight
   do m= 1,3
    contrib_grad_ca(m) = weight * (2.d0 * decdgrad_rho_a_2 *  grad_rho_a(m) + decdgrad_rho_a_b  * grad_rho_b(m) )
    contrib_grad_xa(m) = weight * (2.d0 * dexdgrad_rho_a_2 *  grad_rho_a(m) + dexdgrad_rho_a_b  * grad_rho_b(m) )
    contrib_grad_cb(m) = weight * (2.d0 * decdgrad_rho_b_2 *  grad_rho_b(m) + decdgrad_rho_a_b  * grad_rho_a(m) )
    contrib_grad_xb(m) = weight * (2.d0 * dexdgrad_rho_b_2 *  grad_rho_b(m) + dexdgrad_rho_a_b  * grad_rho_a(m) )
   enddo
   do j = 1, ao_num
    aos_vxc_alpha_md_sr_pbe_w(j,i,istate) = ( decdrho_a + dexdrho_a ) * aos_in_r_array(j,i)
    aos_vxc_beta_md_sr_pbe_w (j,i,istate) = ( decdrho_b + dexdrho_b ) * aos_in_r_array(j,i)
   enddo
   do j = 1, ao_num
    do m = 1,3
     aos_d_vxc_alpha_md_sr_pbe_w(j,i,istate) += ( contrib_grad_ca(m) + contrib_grad_xa(m) ) * aos_grad_in_r_array_transp(m,j,i)
     aos_d_vxc_beta_md_sr_pbe_w (j,i,istate) += ( contrib_grad_cb(m) + contrib_grad_xb(m) ) * aos_grad_in_r_array_transp(m,j,i)
    enddo
   enddo
  enddo
 enddo

 END_PROVIDER

!7
 BEGIN_PROVIDER [double precision, pot_scal_xc_alpha_ao_md_sr_pbe, (ao_num,ao_num,N_states)]
&BEGIN_PROVIDER [double precision, pot_scal_xc_beta_ao_md_sr_pbe, (ao_num,ao_num,N_states)]
 implicit none
 integer                        :: istate
   BEGIN_DOC
   ! intermediate quantity for the calculation of the vxc potentials for the GGA functionals  related to the scalar part of the potential 
   END_DOC
   pot_scal_xc_alpha_ao_md_sr_pbe = 0.d0
   pot_scal_xc_beta_ao_md_sr_pbe = 0.d0
   double precision               :: wall_1,wall_2
   call wall_time(wall_1)
   do istate = 1, N_states
     ! exchange - correlation alpha
     call dgemm('N','T',ao_num,ao_num,n_points_final_grid,1.d0,                     &
                 aos_vxc_alpha_md_sr_pbe_w(1,1,istate),size(aos_vxc_alpha_md_sr_pbe_w,1), &
                 aos_in_r_array,size(aos_in_r_array,1),1.d0,                        &
                 pot_scal_xc_alpha_ao_md_sr_pbe(1,1,istate),size(pot_scal_xc_alpha_ao_md_sr_pbe,1))
     ! exchange - correlation beta
     call dgemm('N','T',ao_num,ao_num,n_points_final_grid,1.d0,                     &
                 aos_vxc_beta_md_sr_pbe_w(1,1,istate),size(aos_vxc_beta_md_sr_pbe_w,1),   &
                 aos_in_r_array,size(aos_in_r_array,1),1.d0,                        &
                 pot_scal_xc_beta_ao_md_sr_pbe(1,1,istate),size(pot_scal_xc_beta_ao_md_sr_pbe,1))
   enddo
 call wall_time(wall_2)

END_PROVIDER 

!8
 BEGIN_PROVIDER [double precision, pot_grad_xc_alpha_ao_md_sr_pbe,(ao_num,ao_num,N_states)]
&BEGIN_PROVIDER [double precision, pot_grad_xc_beta_ao_md_sr_pbe,(ao_num,ao_num,N_states)]
   implicit none
   BEGIN_DOC
   ! intermediate quantity for the calculation of the vxc potentials for the GGA functionals  related to the gradienst of the density and orbitals 
   END_DOC
   integer                        :: istate
   double precision               :: wall_1,wall_2
   call wall_time(wall_1)
   pot_grad_xc_alpha_ao_md_sr_pbe = 0.d0
   pot_grad_xc_beta_ao_md_sr_pbe = 0.d0
   do istate = 1, N_states
       ! exchange - correlation alpha
       call dgemm('N','N',ao_num,ao_num,n_points_final_grid,1.d0,                      &
                  aos_d_vxc_alpha_md_sr_pbe_w(1,1,istate),size(aos_d_vxc_alpha_md_sr_pbe_w,1), &
                  aos_in_r_array_transp,size(aos_in_r_array_transp,1),1.d0,            &
                  pot_grad_xc_alpha_ao_md_sr_pbe(1,1,istate),size(pot_grad_xc_alpha_ao_md_sr_pbe,1))
       ! exchange - correlation beta
       call dgemm('N','N',ao_num,ao_num,n_points_final_grid,1.d0,                      &
                  aos_d_vxc_beta_md_sr_pbe_w(1,1,istate),size(aos_d_vxc_beta_md_sr_pbe_w,1),   &
                  aos_in_r_array_transp,size(aos_in_r_array_transp,1),1.d0,            &
                  pot_grad_xc_beta_ao_md_sr_pbe(1,1,istate),size(pot_grad_xc_beta_ao_md_sr_pbe,1))
   enddo
   
 call wall_time(wall_2)

END_PROVIDER

