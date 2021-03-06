#!/bin/bash 
# specify the QP folder 
QP=$QP_ROOT
# sourcing the quantum_package.rc file
. ${QP}/quantum_package.rc


TEMP=$(getopt -o m:f:p:n:t:r:d:h -l mu:,func:pt2max:ndetmax:readints:damp:thresh,help -n $0 -- "$@") || exit 1 # get the input / options 
eval set -- "$TEMP" # set "--" in the string 

echo $TEMP
function help()
{
    cat <<EOF
Range Separated CIPSI program: 

Usage:
  $(basename $0) -m <real> -f <string> -n <integer> -p <real> [-t <real>] [--] EZFIO


Options:
  -m, --mu=<positive real>              range separation parameter (default=0.5)
  -f, --func=<LOWER CASE STRING>        range separated functional (default=sr_pbe)
  -n, --ndetmax=<positive integer>      max number of determinants in the CIPSI wf (default=1.e6)
  -p, --pt2max=<positive real>          max value of the PT2 correction (default=1.e-3)
  -t, --thresh=<positive real>          threshold on the convergence of the variational energy (default=1.e-10)
  -d, --damp=<positive real>            damping on the density: 0 == no density update, ==1 full density update (default=0.75)
  -r, --readints=<logical True/False>   if True: systematically reads the erf and regular bi-electronic integrals
                                        SPEEDS UP the calculation but you should pay attention 
                                        when using the EZFIO folder latter on as the integrals might not be coherent. 
                                        WARNING: can be dangerous if you interupt the calculation ...
  -h, --help                            Print the HELP message

Example:
  ./$(basename $0) -c config/gfortran.cfg


EOF
    exit
}


while true ; do
    case "$1" in
        -m|--mu) 
            case "$2" in
                "") help ; break;;
                *) mu="$2"
            esac 
            shift 2
	    ;;
        -f|--func) 
            case "$2" in
                "") help ; break;;
                *) functional="$2"
            esac 
            shift 2
	    ;;
        -n|--ndetmax) 
            case "$2" in
                "") help ; break;;
                *) ndetmax="$2"
            esac 
            shift 2
	    ;;
        -p|--pt2max) 
            case "$2" in
                "") help ; break;;
                *) pt2max="$2"
            esac 
            shift 2
	    ;;
        -t|--thresh) 
            case "$2" in
                "") help ; break;;
                *) thresh="$2"
            esac 
            shift 2
	    ;;
        -d|--damp) 
            case "$2" in
                "") help ; break;;
                *) damp="$2"
            esac 
            shift 2
	    ;;
        -r|--readints) 
            case "$2" in
                "") help ; break;;
                *) readints="$2"
            esac 
            shift 2
	    ;;
        -h|-help|--help) 
            help
            exit 0;;
        --) shift  ; break ;;
	"") help ; break ;;
    esac
done

ezfio=${1%/} # take off the / at the end

if [[ -z $ezfio ]]; then
   echo "You did not specify any input EZFIO folder ! "
   echo "stopping ..."
   echo "run $0 --help to have information on how to run the script !"
   echo "......"
   echo "......"
   exit
fi

echo "  **********"
echo "Here are the following INPUT parameters for the RSH-CIPSI run .."
echo "  **********"
echo "EZFIO folder         :  "$ezfio 
if [[ ! -d $ezfio ]]; then
   echo "Input EZFIO folder does not exists !"
   echo "Folder $ezfio does not exist."
   echo "stopping ..."
   echo "......"
   echo "......"
   echo "......"
   exit
fi
# define the exchange / correlation functionals to be used in RS-DFT calculation
if [[ -z $functional ]]; then
 echo "you did not specify the \$functional parameter, it will be set to sr_pbe by default (run --help for explanations)"
 functional="sr_pbe"
fi
echo "FUNCTIONAL for RS-DFT:  "$functional
# splitting of the interaction to be used in RS-DFT calculation 
if [[ -z $mu ]]; then
 echo "you did not specify the \$mu parameter, it will be set to 0.5 by default (run --help for explanations)"
 mu=0.5
fi
echo "MU for RS-DFT        :  "$mu
# maximum value of the PT2 for the CIPSI calculation (note that it is with the effective hamiltonian so it can be self-consistent)
if [[ -z $pt2max ]]; then
 echo "you did not specify the \$pt2max parameter, it will be set to 0.001 by default (run --help for explanations)"
 pt2max=0.001
fi
echo "PT2MAX for RS-DFT    :  "$pt2max
# ndetmax  : maximum size of the CIPSI wave function 
if [[  -z $ndetmax ]]; then
 echo "you did not specify the \$ndetmax parameter, it will be set to 10000000 by default (run --help for explanations)"
 ndetmax=10000000
fi
echo "NDETMAX for RS-DFT   :  "$ndetmax

# value of the convergence of the energy for the self-consistent CIPSI calculation at a given number of determinant
if [[ -z $thresh ]]; then
 echo "you did not specify the \$thresh parameter, it will be set to 0.001 by default (run --help for explanations)"
 thresh=${pt2max}
fi
echo "thresh of convergence:  "$thresh

# value of the damping factor for the density 
if [[ -z $damp ]]; then
 echo "you did not specify the \$damp parameter, it will be set to 0.75 by default (run --help for explanations)"
 damp="0.75"
fi
echo "damping factor       :  "$damp  
dampsave=$damp

# readints: true or false to read the integrals 
if [[  -z $readints ]]; then
 echo "you did not specify the \$readints parameter, it will be set to False by default (run --help for explanations)"
 readints="False"
fi
echo "READINTS             :  "$readints

qp set_file $ezfio

qp  set  dft_keywords       exchange_functional     "${functional}"
qp  set  dft_keywords       correlation_functional  "${functional}"
qp  set  ao_two_e_erf_ints  mu_erf                  $mu
qp  set  perturbation       pt2_max                 $pt2max
qp  set  determinants       n_det_max               $ndetmax
# Use the wave function stored in the EZFIO to build effective RS-DFT potential
qp  set  density_for_dft    density_for_dft         "WFT"
qp  set  density_for_dft    damping_for_rs_dft      $damp


if [[ $readints = "False" ]]; then
# write the effective Hamiltonian containing long-range interaction and short-range effective potential to be diagonalized in a self-consistent way
  echo "#" iter evar old     evar new    deltae      threshold  > ${ezfio}_data_rsdft-${mu}-${functional}
  qp run write_effective_rsdft_hamiltonian_old | tee ${ezfio}/work/rsdft-${mu}-${functional}-0
  EV_macro=`grep "TOTAL ENERGY        =" ${ezfio}/work/rsdft-${mu}-${functional}-0 | cut -d "=" -f 2`
# save the RS-KS one-e density for the damping on the density 
  qp run save_one_e_dm 

  qp  set  density_for_dft    density_for_dft         "damping_rs_dft"
# damping_for_rs_dft : 0 == no update of the density, 1 == full update of the density 


  for i in {1..100}
   do
#  run the CIPSI calculation with the effective Hamiltonian already stored in the EZFIO folder 
     qp set determinants read_wf "False"
     qp run fci  | tee ${ezfio}/work/fci-${mu}-${functional}-$i
     EV=0

     echo "#" iter evar old     evar new    deltae      threshold  >> ${ezfio}/work/data_conv-${mu}-${functional}-${i}
     for j in {1..100}
     do
        # write the new effective Hamiltonian with the damped density (and the current density to be damped with the next density)
        qp run write_effective_rsdft_hamiltonian_old | tee ${ezfio}/work/rsdft-${mu}-${functional}-${i}-${j}
        # value of the variational RS-DFT energy 
        EV_new=`grep "TOTAL ENERGY        =" ${ezfio}/work/rsdft-${mu}-${functional}-${i}-${j} | cut -d "=" -f 2`
        # rediagonalize the new effective Hamiltonian to obtain a new wave function and a new density 
        qp run diagonalize_h  | tee ${ezfio}/work/diag-${mu}-${functional}-${i}-${j}
        # checking the convergence
        DE=`echo "${EV_new} - ${EV}" | bc`
        DEabs=`echo "print(abs(${DE}))" | python `
        CONV=`echo  "print(${DEabs} < ${thresh})" | python`
        echo $j $EV $EV_new $DE $thresh >> ${ezfio}/work/data_conv-${mu}-${functional}-${i}
        if [ "$CONV" = "True" ]; then
          break
        fi
        EV=$EV_new
      done
     
      qp run  write_effective_rsdft_hamiltonian_old | tee ${ezfio}/work/rsdft-${mu}-${functional}-${i}-final
      EV_new_macro=`grep "TOTAL ENERGY        =" ${ezfio}/work/rsdft-${mu}-${functional}-${i}-final | cut -d "=" -f 2`
      # checking the convergence
      DE=`echo "${EV_new_macro} - ${EV_macro}" | bc`
      DEabs=`echo "print(abs(${DE}))" | python `
      CONV=`echo "print(${DEabs} < ${thresh})" | python`
      echo $i $EV_macro $EV_new_macro $DE $thresh >> ${ezfio}_data_rsdft-${mu}-${functional}
      if [ "$CONV" = "True" ]; then
        break
      fi
      EV_macro=$EV_new_macro
  done

else 

# write the effective Hamiltonian containing long-range interaction and short-range effective potential to be diagonalized in a self-consistent way
  echo "#" iter evar old     evar new    deltae      threshold  > ${ezfio}_data_rsdft-${mu}-${functional}
  qp run write_erf_and_regular_ints 
  for file in consolidated_idx consolidated_key consolidated_value
   do 
    cp ${ezfio}/work/work/mo_ints_regular_$file ${ezfio}/work/work/mo_ints_$file
   done
  qp run write_rsdft_h_read_ints | tee ${ezfio}/work/rsdft-${mu}-${functional}-0
  EV_macro=`grep "TOTAL ENERGY        =" ${ezfio}/work/rsdft-${mu}-${functional}-0 | cut -d "=" -f 2`
# save the RS-KS one-e density for the damping on the density 
  qp run save_one_e_dm 

  qp  set  density_for_dft    density_for_dft         "damping_rs_dft"
# damping_for_rs_dft : 0 == no update of the density, 1 == full update of the density 
  qp  set  density_for_dft    damping_for_rs_dft      0.75

  for i in {1..1000}
   do
#  run the CIPSI calculation with the effective Hamiltonian already stored in the EZFIO folder 
     qp set determinants read_wf "False"
     # save the erf integrals into the two-elec file
     for file in consolidated_idx consolidated_key consolidated_value
      do 
       cp ${ezfio}/work/work/mo_ints_erf_$file ${ezfio}/work/work/mo_ints_$file
      done
     qp run fci  | tee ${ezfio}/work/fci-${mu}-${functional}-$i
#     qp run cisd  | tee ${ezfio}/work/fci-${mu}-$i
     EV=0

     echo "#" iter evar old     evar new    deltae      threshold  >> ${ezfio}/work/data_conv-${mu}-${functional}-${i}
     for j in {1..100}
     do
        # save the regular integrals into the two-elec file
        for file in consolidated_idx consolidated_key consolidated_value
         do 
          cp ${ezfio}/work/work/mo_ints_regular_$file ${ezfio}/work/work/mo_ints_$file
         done
        # write the new effective Hamiltonian with the damped density (and the current density to be damped with the next density)
        qp run write_rsdft_h_read_ints | tee ${ezfio}/work/rsdft-${mu}-${functional}-${i}-${j}
        # value of the variational RS-DFT energy 
        EV_new=`grep "TOTAL ENERGY        =" ${ezfio}/work/rsdft-${mu}-${functional}-${i}-${j}| cut -d "=" -f 2`

        # save the erf integrals into the two-elec file
        for file in consolidated_idx consolidated_key consolidated_value
         do 
          cp ${ezfio}/work/work/mo_ints_erf_$file ${ezfio}/work/work/mo_ints_$file
         done
        # rediagonalize the new effective Hamiltonian to obtain a new wave function and a new density 
        qp run diagonalize_h  | tee ${ezfio}/work/diag-${mu}-${functional}-${i}-${j}
        # checking the convergence
        DE=`echo "${EV_new} - ${EV}" | bc`
        DEabs=`echo "print(abs(${DE}))" | python `
        neg=`echo "print(${DE} <= 0.)" | python`
        if [[ ! "$neg" = "True" ]]; then
         qp  set  density_for_dft    density_for_dft         "input_density"
######## damping_for_rs_dft : 0 == no update of the density, 1 == full update of the density 
         qp  set  density_for_dft    damping_for_rs_dft      ${damp} * 0.5 
        else 
         qp  set  density_for_dft    density_for_dft         "damping_rs_dft"
         damp=$dampsave
        fi
        CONV=`echo "print(${DEabs} < ${thresh})" | python`
        echo $j $EV $EV_new $DE $thresh >> ${ezfio}/work/data_conv-${mu}-${functional}-${i}
        if [ "$CONV" = "True" ]; then
          break
        fi
        EV=$EV_new
      done
     
      # save the regular integrals into the two-elec file
      for file in consolidated_idx consolidated_key consolidated_value
       do 
        cp ${ezfio}/work/work/mo_ints_regular_$file ${ezfio}/work/work/mo_ints_$file
       done
      qp run  write_rsdft_h_read_ints | tee ${ezfio}/work/rsdft-${mu}-${functional}-${i}-final
      EV_new_macro=`grep "TOTAL ENERGY        =" ${ezfio}/work/rsdft-${mu}-${functional}-${i}-final  | cut -d "=" -f 2`
      # checking the convergence
      DE=`echo "${EV_new_macro} - ${EV_macro}" | bc`
      DEabs=`echo "print(abs(${DE}))" | python `
      CONV=`echo "print(${DEabs}) < ${thresh}" | python`
      echo $i $EV_macro $EV_new_macro $DE $thresh >> ${ezfio}_data_rsdft-${mu}-${functional}
      if [ "$CONV" = "True" ]; then
        break
      fi
      EV_macro=$EV_new_macro
     
  done



fi
