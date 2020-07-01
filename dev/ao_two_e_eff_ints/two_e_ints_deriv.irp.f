double precision function ao_two_e_integral_schwartz_accel_dr12_coul(i,j,k,l)
  implicit none
  BEGIN_DOC
  !  integral of the AO basis <jl|1/r12 * r_{12}.d/dr12 |ik> 
  !  j(r1) l(r2) (1 - erf(mu r12))/(2 r12) (x_1 - x_2) (d/dx1 - d/dx2) + (y_1 - y_2) (d/dy1 - d/dy2) + (z_1 - z_2) (d/dz1 - d/dz2) i(r1) k(r2)
  !  
  ! WARNING <ik|jl> IS NOT EQUAL TO <kl|ik> because of the first-order differential operator
  END_DOC
  integer,intent(in)             :: i,j,k,l
  integer                        :: p,q,r,s
  double precision               :: I_center(3),J_center(3),K_center(3),L_center(3)
  integer                        :: num_i,num_j,num_k,num_l,dim1,I_power(3),J_power(3),K_power(3),L_power(3)
  double precision               :: integral
  include 'utils/constants.include.F'
  double precision               :: P_new(0:max_dim,3),P_center(3),fact,pp
  double precision               :: Q_new(0:max_dim,3),Q_center(3),fact_q,qq
  integer                        :: iorder(3), iorder_q(3)
  double precision, allocatable  :: schwartz_kl(:,:)
  double precision               :: schwartz_ij
  double precision :: scw_gauss_int,general_primitive_integral_gauss

  dim1 = n_pt_max_integrals

  num_i = ao_nucl(i)
  num_j = ao_nucl(j)
  num_k = ao_nucl(k)
  num_l = ao_nucl(l)
  ao_two_e_integral_schwartz_accel_dr12_coul = 0.d0
  double precision               :: thr
  thr = ao_integrals_threshold*ao_integrals_threshold

  allocate(schwartz_kl(0:ao_prim_num(l),0:ao_prim_num(k)))

      double precision               :: coef3
      double precision               :: coef2
      double precision               :: p_inv,q_inv
      double precision               :: coef1
      double precision               :: coef4

    do p = 1, 3
      I_power(p) = ao_power(i,p)
      J_power(p) = ao_power(j,p)
      K_power(p) = ao_power(k,p)
      L_power(p) = ao_power(l,p)
      I_center(p) = nucl_coord(num_i,p)
      J_center(p) = nucl_coord(num_j,p)
      K_center(p) = nucl_coord(num_k,p)
      L_center(p) = nucl_coord(num_l,p)
    enddo

    call give_poly_ij(k,l,P_kl,center_kl,p_exp_kl,fact_kl,iorder_kl,coef_prod_kl)
    call give_poly_ij(i,j,P_ij,center_ij,p_exp_ij,fact_ij,iorder_ij,coef_prod_ij)

 double precision :: P_ij(0:max_dim,3,ao_prim_num_max,ao_prim_num_max) ! new polynom for each couple of prim
 integer          :: iorder_ij(3,ao_prim_num_max,ao_prim_num_max) ! order of the polynoms for each couple of prim
 double precision :: center_ij(3,ao_prim_num_max,ao_prim_num_max) ! new center for each couple of prim
 double precision :: p_exp_ij(ao_prim_num_max,ao_prim_num_max) ! new gaussian exponents for each couple of prim
 double precision :: fact_ij(ao_prim_num_max,ao_prim_num_max) ! factor for each couple of primitive 
 double precision :: coef_prod_ij(ao_prim_num_max,ao_prim_num_max) ! produc of coef for each couple of primitive 

 double precision :: P_j_xyz_i(0:max_dim,3,2,ao_prim_num_max,ao_prim_num_max) ! new polynom for each couple of prim
 integer          :: iorder_j_xyz_i(3,2,ao_prim_num_max,ao_prim_num_max) ! order of the polynoms for each couple of prim
 double precision :: P_j_dxyz_i(0:max_dim,3,2,ao_prim_num_max,ao_prim_num_max) ! new polynom for each couple of prim
 integer          :: iorder_j_dxyz_i(3,2,ao_prim_num_max,ao_prim_num_max) ! order of the polynoms for each couple of prim
 double precision :: P_j_xyz_dxyz_i(0:max_dim,3,4,ao_prim_num_max,ao_prim_num_max) ! new polynom for each couple of prim
 integer          :: iorder_j_xyz_dxyz_i(3,4,ao_prim_num_max,ao_prim_num_max) ! order of the polynoms for each couple of prim

 double precision :: P_kl(0:max_dim,3,ao_prim_num_max,ao_prim_num_max) ! new polynom for each couple of prim
 integer          :: iorder_kl(3,ao_prim_num_max,ao_prim_num_max) ! order of the polynoms for each couple of prim
 double precision :: center_kl(3,ao_prim_num_max,ao_prim_num_max) ! new center for each couple of prim
 double precision :: p_exp_kl(ao_prim_num_max,ao_prim_num_max) ! new gaussian exponents for each couple of prim
 double precision :: fact_kl(ao_prim_num_max,ao_prim_num_max) ! factor for each couple of primitive 
 double precision :: coef_prod_kl(ao_prim_num_max,ao_prim_num_max) ! produc of coef for each couple of primitive 

 double precision :: P_l_xyz_k(0:max_dim,3,2,ao_prim_num_max,ao_prim_num_max) ! new polynom for each couple of prim
 integer          :: iorder_l_xyz_k(3,2,ao_prim_num_max,ao_prim_num_max) ! order of the polynoms for each couple of prim
 double precision :: P_l_dxyz_k(0:max_dim,3,2,ao_prim_num_max,ao_prim_num_max) ! new polynom for each couple of prim
 integer          :: iorder_l_dxyz_k(3,2,ao_prim_num_max,ao_prim_num_max) ! order of the polynoms for each couple of prim
 double precision :: P_l_xyz_dxyz_k(0:max_dim,3,4,ao_prim_num_max,ao_prim_num_max) ! new polynom for each couple of prim
 integer          :: iorder_l_xyz_dxyz_k(3,4,ao_prim_num_max,ao_prim_num_max) ! order of the polynoms for each couple of prim


 call give_all_poly_for_r12_deriv(i,j,P_ij,iorder_ij,center_ij,p_exp_ij,fact_ij,coef_prod_ij,& 
            P_j_xyz_i,iorder_j_xyz_i, iorder_j_dxyz_i,P_j_dxyz_i, P_j_xyz_dxyz_i, iorder_j_xyz_dxyz_i)
 call give_all_poly_for_r12_deriv(k,l,P_kl,iorder_kl,center_kl,p_exp_kl,fact_kl,coef_prod_kl,& 
            P_l_xyz_k,iorder_l_xyz_k, iorder_l_dxyz_k,P_l_dxyz_k, P_l_xyz_dxyz_k, iorder_l_xyz_dxyz_k)
    schwartz_kl(0,0) = 0.d0
    do r = 1, ao_prim_num(k)
      coef1 = ao_coef_normalized_ordered_transp(r,k)*ao_coef_normalized_ordered_transp(r,k)
      schwartz_kl(0,r) = 0.d0
      do s = 1, ao_prim_num(l)
        coef2 = coef1 * ao_coef_normalized_ordered_transp(s,l) * ao_coef_normalized_ordered_transp(s,l)
        qq = p_exp_kl(r,s)
        q_inv = 1.d0/qq
!        schwartz_kl(s,r) = general_primitive_integral_erf_new(dim1,          &
!            P_kl(0,1,r,s),center_kl(1,r,s),fact_kl(r,s),p_exp_kl(r,s),q_inv,iorder_kl(1,r,s),                 &
!            P_kl(0,1,r,s),center_kl(1,r,s),fact_kl(r,s),p_exp_kl(r,s),q_inv,iorder_kl(1,r,s))      &
!            * coef2
        schwartz_kl(0,r) = max(schwartz_kl(0,r),schwartz_kl(s,r))
      enddo
      schwartz_kl(0,0) = max(schwartz_kl(0,r),schwartz_kl(0,0))
    enddo

    do p = 1, ao_prim_num(i)
      coef1 = ao_coef_normalized_ordered_transp(p,i)
      do q = 1, ao_prim_num(j)
        coef2 = coef1*ao_coef_normalized_ordered_transp(q,j)
        pp = p_exp_ij(p,q)
        p_inv = 1.d0/pp
!        schwartz_ij = general_primitive_integral_erf_new(dim1,               &
!            P_ij(0,1,p,q),center_ij(1,p,q),fact_ij(p,q),p_exp_ij(p,q),p_inv,iorder_ij(1,p,q),                 &
!            P_ij(0,1,p,q),center_ij(1,p,q),fact_ij(p,q),p_exp_ij(p,q),p_inv,iorder_ij(1,p,q)) *               &
!            coef2*coef2
        if (schwartz_kl(0,0)*schwartz_ij < thr) then
           cycle
        endif
        do r = 1, ao_prim_num(k)
          if (schwartz_kl(0,r)*schwartz_ij < thr) then
             cycle
          endif
          coef3 = coef2*ao_coef_normalized_ordered_transp(r,k)
          do s = 1, ao_prim_num(l)
            if (schwartz_kl(s,r)*schwartz_ij < thr) then
               cycle
            endif
            coef4 = coef3*ao_coef_normalized_ordered_transp(s,l)
            qq = p_exp_kl(r,s)
            q_inv = 1.d0/qq
!            integral = general_primitive_integral_erf_new(dim1,              &
!                P_ij(0,1,p,q),center_ij(1,p,q),fact_ij(p,q),p_exp_ij(p,q),p_inv,iorder_ij(1,p,q), & 
!                P_kl(0,1,r,s),center_kl(1,r,s),fact_kl(r,s),p_exp_kl(r,s),q_inv,iorder_kl(1,r,s))
!            ao_two_e_integral_schwartz_accel_erf_new = ao_two_e_integral_schwartz_accel_erf_new + coef4 * integral
          enddo ! s
        enddo  ! r
      enddo   ! q
    enddo    ! p

end

subroutine general_primitive_integral_d_dr12(d_dr12,mu_in,            &
     P_ij,iorder_ij,center_ij,p_exp_ij,fact_ij,coef_prod_ij,            &
     P_j_xyz_i,iorder_j_xyz_i, iorder_j_dxyz_i,P_j_dxyz_i, P_j_xyz_dxyz_i, iorder_j_xyz_dxyz_i, &
     P_kl,iorder_kl,center_kl,p_exp_kl,fact_kl,coef_prod_kl,            &
     P_l_xyz_k,iorder_l_xyz_k, iorder_l_dxyz_k,P_l_dxyz_k, P_l_xyz_dxyz_k, iorder_l_xyz_dxyz_k) 
      
  include 'utils/constants.include.F'
  implicit none
  double precision, intent(out) :: d_dr12(2)
  double precision, intent(in) :: mu_in
  double precision,intent(in) :: P_ij(0:max_dim,3) 
  integer         ,intent(in) :: iorder_ij(3) 
  double precision,intent(in) :: center_ij(3) 
  double precision,intent(in) :: p_exp_ij 
  double precision,intent(in) :: fact_ij 
  double precision,intent(in) :: coef_prod_ij 
  double precision,intent(in) :: P_j_xyz_i(0:max_dim,3,2) 
  integer         ,intent(in) :: iorder_j_xyz_i(3,2) 
  double precision,intent(in) :: P_j_dxyz_i(0:max_dim,3,2) 
  integer         ,intent(in) :: iorder_j_dxyz_i(3,2) 
  double precision,intent(in) :: P_j_xyz_dxyz_i(0:max_dim,3,4) 
  integer         ,intent(in) :: iorder_j_xyz_dxyz_i(3,4) 

  double precision,intent(in) :: P_kl(0:max_dim,3) 
  integer         ,intent(in) :: iorder_kl(3) 
  double precision,intent(in) :: center_kl(3) 
  double precision,intent(in) :: p_exp_kl 
  double precision,intent(in) :: fact_kl 
  double precision,intent(in) :: coef_prod_kl 
  double precision,intent(in) :: P_l_xyz_k(0:max_dim,3,2) 
  integer         ,intent(in) :: iorder_l_xyz_k(3,2) 
  double precision,intent(in) :: P_l_dxyz_k(0:max_dim,3,2) 
  integer         ,intent(in) :: iorder_l_dxyz_k(3,2) 
  double precision,intent(in) :: P_l_xyz_dxyz_k(0:max_dim,3,4) 
  integer         ,intent(in) :: iorder_l_xyz_dxyz_k(3,4) 

  BEGIN_DOC
  ! 
  END_DOC

  double precision               :: rho,dist,p,q,p_inv,q_inv
  double precision               :: Ixyz_pol(0:max_dim,3),Iprod_xyz(0:max_dim,3)
  integer                        :: n_Ixyz(3),m,i,n_Iprod_xyz(3),kk,ll
  double precision               :: accu,pq,const
  double precision               :: pq_inv, p10_1, p10_2, p01_1, p01_2,pq_inv_2
  integer                        :: n_pt_tmp,n_pt_out, iorder
  double precision               :: d1(0:max_dim),d_poly(0:max_dim),rint
  double precision               :: dtmp(0:max_dim),n_dtmp,dsum(0:max_dim,3),n_dsum(3)
  integer  :: dim
  dim = n_pt_max_integrals

  p = p_exp_ij
  p_inv = 1.d0/p
  q = p_exp_kl
  q_inv = 1.d0/q


  !DIR$ ATTRIBUTES ALIGN : $IRP_ALIGN :: Ixyz_pol
  !DIR$ ATTRIBUTES ALIGN : $IRP_ALIGN :: d1, d_poly

  ! Gaussian Product
  ! ----------------
  double precision :: p_plus_q
  p_plus_q = (p+q) * ((p*q)/(p+q) + mu_in*mu_in)/(mu_in*mu_in)
  pq = p_inv*0.5d0*q_inv

  pq_inv = 0.5d0/p_plus_q
  p10_1 = q*pq  ! 1/(2p)
  p01_1 = p*pq  ! 1/(2q)
  pq_inv_2 = pq_inv+pq_inv
  p10_2 = pq_inv_2 * p10_1*q !0.5d0*q/(pq + p*p)
  p01_2 = pq_inv_2 * p01_1*p !0.5d0*p/(q*q + pq)

  rho = p*q *pq_inv_2  ! le rho qui va bien
  dist =  (center_ij(1) - center_kl(1))*(center_ij(1) - center_kl(1)) +  &
      (center_ij(2) - center_kl(2))*(center_ij(2) - center_kl(2)) +      &
      (center_ij(3) - center_kl(3))*(center_ij(3) - center_kl(3))
  const = dist*rho


  accu = 0.d0
  n_Ixyz = 0 
  Ixyz_pol = 0.d0
  ! You get the polynoms Ixyz_pol(:,1), Ixyz_pol(:,2), Ixyz_pol(:,3) 
  ! for the (x1,x2), (y1,y2)  and (z1,z2) integration of the product j(1)i(1) l(2)k(2)
  do m = 1, 3
   call give_polynom_x_for_erf_int(                                              &
       P_ij(0,m),center_ij(m),p,iorder_ij(m),pq_inv,pq_inv_2,        &
       P_kl(0,m),center_kl(m),q,iorder_kl(m),p10_1,p01_1,p10_2,p01_2,&
       n_Ixyz(m), Ixyz_pol(0,m))
   if(n_Ixyz(m) == -1) then
    return
   endif
  enddo

  
  Iprod_xyz = 0.d0
  n_Iprod_xyz = 0
  ! common polynoms corresponding to the integration over 2 couple of space variable 
  ! Iprod_xyz(:,1) = Ix * Iy 
  call multiply_poly(Ixyz_pol(0,1),n_Ixyz(1),Ixyz_pol(0,2),n_Ixyz(2),Iprod_xyz(0,1),n_Iprod_xyz(1))
  if(n_Iprod_xyz(1) == -1)then
   return
  endif
  ! Iprod_xyz(:,2) = Ix * Iz 
  call multiply_poly(Ixyz_pol(0,1),n_Ixyz(1),Ixyz_pol(0,3),n_Ixyz(3),Iprod_xyz(0,2),n_Iprod_xyz(2))
  if(n_Iprod_xyz(2) == -1)then
   return
  endif
  ! Iprod_xyz(:,3) = Iy * Iz 
  call multiply_poly(Ixyz_pol(0,2),n_Ixyz(2),Ixyz_pol(0,3),n_Ixyz(3),Iprod_xyz(0,3),n_Iprod_xyz(3))
  if(n_Iprod_xyz(3) == -1)then
   return
  endif

! dsum(0:,1) =  (x1,x2) integration of the j(r1) l(r2) (x1 - x2)(dx1 - dx2) i(x1) k(x2) 
! dsum(0:,2) =  (y1,y2) integration of the j(r1) l(r2) (y1 - y2)(dy1 - dy2) i(y1) k(y2) 
! dsum(0:,3) =  (z1,z2) integration of the j(r1) l(r2) (z1 - z2)(dz1 - dz2) i(z1) k(z2) 
   dsum = 0.d0 
   n_dsum = 0
  do m = 1, 3
  ! computing the X part of the r12 derivative : j(r1) l(r2) (x1 - x2)(dx1 - dx2) i(r1) k(r2)
  !
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! j(r1) l(r2) (x1 dx1 i(r1) ) k(r2)
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   do kk = 1, 4 ! you loop over the four polynoms of P_j_xyz_dxyz_i
    ! the polynom in x1 is [j(r1) (x1 dx1 i(r1))] 
    ! the polynom in x2 is l(r2) k(r2)
    call give_polynom_x_for_erf_int(                                              &
        P_j_xyz_dxyz_i(0,m,kk),center_ij(m),p,iorder_j_xyz_dxyz_i(m,kk),pq_inv,pq_inv_2,        &
        P_kl(0,m),center_kl(m),q,iorder_kl(m),p10_1,p01_1,p10_2,p01_2,&
        n_dtmp, dtmp) !  dtmp = the polynom for [j(r1) (x1 dx1 i(r1))] l(r2) k(r2)
    ! you sum up dtmp into dsum to accumulate 
    call add_poly_multiply(dtmp,n_dtmp,1.d0,dsum(0,m),n_dsum(m))
   enddo
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! j(r1) l(r2) (x2 dx2 k(r2) ) i(r2)
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   do kk = 1, 4 ! you loop over the four polynoms of P_l_xyz_dxyz_k
    ! the polynom in x1 is j(r1) i(r1)
    ! the polynom in x2 is l(r2) (x2 dx2 k(r2))
    call give_polynom_x_for_erf_int(                                              &
        P_ij(0,m),center_ij(m),p,iorder_ij(m),pq_inv,pq_inv_2,        &
        P_l_xyz_dxyz_k(0,m,kk),center_kl(m),q,iorder_l_xyz_dxyz_k(m,kk),p10_1,p01_1,p10_2,p01_2,&
        n_dtmp, dtmp) ! dtmp = j(r1) i(r1) l(r2) [(x2 dx2 k(r2))]
    ! you sum up dtmp into dsum to accumulate 
    call add_poly_multiply(dtmp,n_dtmp,1.d0,dsum(0,m),n_dsum(m))
   enddo
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! - j(r1) l(r2) (x1 i(r1)) (dx2 k(r2))
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   do kk = 1, 2 ! you loop over the two polynoms of P_j_xyz_i 
    do ll = 1, 2 ! you loop over two polynoms of P_l_dxyz_k
     ! the polynom in x1 is [j(r1) (x1 i(r1))] 
     ! the polynom in x2 is  l(r2) (dx2 k(r2))
     call give_polynom_x_for_erf_int(                                              &
         P_j_xyz_i(0,m,kk),center_ij(m),p,iorder_j_xyz_i(m,kk),pq_inv,pq_inv_2,        &
         P_l_dxyz_k(0,m,ll),center_kl(m),q,iorder_l_dxyz_k(m,ll),p10_1,p01_1,p10_2,p01_2,&
         n_dtmp, dtmp) ! dtmp = [j(r1) (x1 i(r1))] l(r2) (dx2 k(r2))
     ! you sum up dtmp into dsum to accumulate !!! WARNING !!! NOTE THE -1.d0 because of -x1 dx2 
     call add_poly_multiply(dtmp,n_dtmp,-1.d0,dsum(0,m),n_dsum(m))
    enddo
   enddo

  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! - j(r1) l(r2) (dx1 i(r1)) (x2 k(r2)) 
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   do kk = 1, 2 ! you loop over the two polynoms of P_j_dxyz_i
    do ll = 1, 2 ! you loop over the two polynoms of P_l_xyz_k
     ! the polynom in x1 is [j(r1) (x1  i(r1))] 
     ! the polynom in x2 is  l(r2) (dx2 k(r2))
     call give_polynom_x_for_erf_int(                                              &
         P_j_dxyz_i(0,m,kk),center_ij(m),p,iorder_j_dxyz_i(m,kk),pq_inv,pq_inv_2,        &
         P_l_xyz_k(0,m,ll),center_kl(m),q,iorder_l_xyz_k(m,ll),p10_1,p01_1,p10_2,p01_2,&
         n_dtmp, dtmp) ! dtmp = [j(r1) (x1 i(r1))] l(r2) (dx2 k(r2))
     ! you sum up dtmp into dsum to accumulate !!! WARNING !!! NOTE THE -1.d0 because of -x2 dx1 
     call add_poly_multiply(dtmp,n_dtmp,-1.d0,dsum(0,m),n_dsum(m))
    enddo
   enddo
  enddo ! m 

  double precision :: rint_sum
  ! j(x1) l(x2) (x1 - x2)(dx1 - dx2) i(x1) k(x2) * P_ij(y1) P_kl(y1) * P_ij(z1) P_kl(z1)
  ! ==> you multiply dsum(:,1) with the polynoms in y * z == d1
  d1 =0.d0
  n_pt_out = 0
   call multiply_poly(Iprod_xyz(0,3),n_Iprod_xyz(3),dsum(0,1),n_dsum(1),d1,n_pt_out)
  ! then you integrate over [0,1] d1(t) * exp(-const * t^2)
   accu = rint_sum(n_pt_out,const,d1)
   d_dr12(1) = fact_ij * fact_kl * accu *pi_5_2*p_inv*q_inv/dsqrt(p_plus_q)

  ! j(y1) l(y2) (y1 - y2)(dy1 - dy2) i(y1) k(y2) * P_ij(x1) P_kl(x1) * P_ij(z1) P_kl(z1) 
  ! ==> you multiply dsum(:,2) with the polynoms in x * z == d1
  d1 =0.d0
  n_pt_out = 0
   call multiply_poly(Iprod_xyz(0,2),n_Iprod_xyz(2),dsum(0,2),n_dsum(2),d1,n_pt_out)
  ! then you integrate over [0,1] d1(t) * exp(-const * t^2)
   accu = rint_sum(n_pt_out,const,d1)
   d_dr12(2) = fact_ij * fact_kl * accu *pi_5_2*p_inv*q_inv/dsqrt(p_plus_q)

  ! j(z1) l(z2) (z1 - z2)(dz1 - dz2) i(z1) k(z2) * P_ij(x1) P_kl(x1) * P_ij(y1) P_kl(y1) 
  ! ==> you multiply dsum(:,3) with the polynoms in x * y == d1
  d1 =0.d0
  n_pt_out = 0
   call multiply_poly(Iprod_xyz(0,1),n_Iprod_xyz(1),dsum(0,3),n_dsum(3),d1,n_pt_out)
  ! then you integrate over [0,1] d1(t) * exp(-const * t^2)
   accu = rint_sum(n_pt_out,const,d1)
   d_dr12(1) = fact_ij * fact_kl * accu *pi_5_2*p_inv*q_inv/dsqrt(p_plus_q)
end
