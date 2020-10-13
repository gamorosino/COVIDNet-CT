#! /bin/bash

#########################################################################################################################
#########################################################################################################################
###################		            							      ###################
###################	title:	            	  CovidNEt-CT Inference				      ###################
###################		           							      ###################
###################	description:	Scripts that performs inferce on a series of slice	      ###################
###################			using COVIDNet-CT					      ###################
###################										      ###################
###################	version:	0.1.0        				                      ###################
###################	notes:	        .							      ###################
###################	bash version:   tested on GNU bash, version 4.2.53			      ###################
###################		           							      ###################
###################	autor: gamorosino     							      ###################
###################     email: g.amorosino@gmail.com						      ###################
###################		           							      ###################
#########################################################################################################################
#########################################################################################################################

#########################################################################################################################
### Input parsing
#########################################################################################################################

input_path=$1
COVIDNet_model=$2
output_txt=$3


		if [ $# -lt 1 ]; then							# usage dello script							
			    echo $0: "usage: COVIDNet-CT_inference.sh <input_path> [<COVIDNet_model>] [<output_txt>]"			    
			    echo     "COVIDNet_model:   "
			    echo     "                1. COVIDNet-CT-A"
			    echo     "                2. COVIDNet-CT-B"
			    exit 1;		    
		fi   

#########################################################################################################################
### Functions
#########################################################################################################################

str_index() {    
                
                ############# ############# ############# ############# ############# ############# 
                ############        Find the first index of a substring in a string     ########### 
                ############# ############# ############# ############# ############# #############   

		if [ $# -lt 2 ]; then							# usage dello script							
			    echo $0: "usage: str_index <string> <substrin> "
			    return 1;		    
		fi       

                x="${1%%$2*}";   
                [[ $x = $1 ]] && echo -1 || echo ${#x}; 
                };

fbasename () {
                ############# ############# ############# ############# ############# ############# 
                #############      Remove directory and extension from a file name    ############# 
                ############# ############# ############# ############# ############# #############
                  
                echo ` basename $1 | cut -d '.' -f 1 `
		
		};
error() 	{       
	       ############# ############# ############# ############# ############# #############
               #############  	    Print an error message on the screen             ############# 
               ############# ############# ############# ############# ############# ############# 
			
  			echo "$@" 1>&2
  			
			};

fail() 		{

	       ############# ############# ############# ############# ############# ############# #############
               #############  	     Exit the script and print an error message on the screen      ############# 
               ############# ############# ############# ############# ############# ############# #############
                        
  			error "$@"
  			exit 1
		};

check_type() { 
		local input_path=$1
		local temp_dir=$2
		# check file type
		file_mime=$( file --mime-type -b  ${input_path} )
		file_type=$( echo $file_mime | rev | cut -d"/" -f1  | rev )

		case "${file_type}" in

			"dicom")

				source /env/bin/activate
				source ${utilities}
				
				input_path_jpg=${temp_dir}"/"$( fbasename ${input_path} )".jpg"
				echo "Conversion from DICOM to JPEG..." >> ${temp_txt}
				imm_dcm2jpg ${input_path} ${temp_dir}   1>> ${temp_txt}  2>> ${temp_err}
				input_path=${input_path_jpg}
				deactivate
				echo ${input_path}
			;;


			"png")

				#source  /env/bin/activate
				#source ${utilities}
				#input_path_jpg=$( dirname ${input_path} )"/"$( fbasename ${input_path} )".jpg"
				#echo "Conversion from PNG to JPEG..."
				#imm_png2jpg ${input_path} 1>> ${temp_txt}  2>> ${temp_err}   ;
				#input_path=${input_path_jpg}
				#deactivate

				echo $( dirname ${input_path} )"/"$( basename ${input_path} )

			;;

			"jpeg")

				echo $( dirname ${input_path} )"/"$( basename ${input_path} )
			;;

			*)
				echo "None"
			;;
		    esac

		    

		}


exists () {
                ############# ############# ############# ############# ############# ############# #############
                #############  		      Controlla l'esistenza di un file o directory	    ############# 
                ############# ############# ############# ############# ############# ############# #############  		                      			
		if [ $# -lt 1 ]; then
		    echo $0: "usage: exists <filename> "
		    echo "    echo 1 if the file (or folder) exists, 0 otherwise"
		    return 1;		    
		fi 
		
		if [ -d "${1}" ]; then 

			echo 1;
		else
			([ -e "${1}" ] && [ -f "${1}" ]) && { echo 1; } || { echo 0; }	
		fi		
		};


#########################################################################################################################
### main
#########################################################################################################################


SCRIPT=`realpath -s $0`
dir_script=`dirname $SCRIPT`
utilities=${dir_script}"/utilities.sh"

# define default inputs
COVIDNet_DIR=${dir_script} 
COVIDNET_models=${COVIDNet_DIR}"/models/"
[ -z ${COVIDNet_model} ] && { COVIDNet_model="COVIDNet-CT-B"; }
weightspath=${COVIDNET_models}"/"${COVIDNet_model}
model_v=( $( ls ${weightspath}"/model"*"data"* )  )
model_str=${model_v[0]}
sind=$( str_index ${model_v[0]} "." )
ckptname=$( basename ${model_str:0:${sind}} )
[ -z ${output_txt} ] && \
	{ output_txt=$( dirname ${input_path} )'/'$( fbasename ${input_path} )"_"${COVIDNet_model}"_inference_output.txt"; }

( [ "${COVIDNet_model}" ==  "COVIDNet-CXR-Large"  ] || \
	[  "${COVIDNet_model}" ==  "COVIDNet-CXR-Small" ] ) &&\
	 { ocommands=" --out_tensor dense_3/Softmax:0 --input_size 224 " ; }


printf "" > ${output_txt}

# define text files
time_=$( date +%D_%T )
time_=${time_//'/'/'_'}
time_=${time_//':'/'_'}
temp_txt=$( dirname ${input_path} )"/"$( fbasename ${input_path} )"_"${COVIDNet_model}"_inference_"${time_}".txt"
temp_err=$( dirname ${input_path} )"/"$( fbasename ${input_path} )"_"${COVIDNet_model}"_inference_"${time_}".err"
temp_log=$( dirname ${input_path} )"/"$( fbasename ${input_path} )"_"${COVIDNet_model}"_inference_"${time_}".log"
printf "" >> $temp_err;

if [ -d ${input_path} ]; then

	input_folder=${input_path}
	slices=( $( ls ${input_folder} ) )
	temp_dir=${input_folder}"/tmp_"$( date +%s )
	idx=0
	count_H=0
	count_P=0
	count_C=0
	for slice in ${slices[@]}; do  \
		printf "Slice "${idx}" - "
		printf "filename: "${slice}" "; 
		idx=$(( $idx + 1 ))
		input_path=$( check_type ${input_folder}"/"${slice} ${temp_dir}  )
		[ "$input_path" == "None" ] && { continue; }
		printf "Slice "${idx}" ; "  >> ${output_txt};
		python ${COVIDNet_DIR}"/run_covidnet_ct.py" infer     \
					--model_dir ${weightspath}     \
					--meta_name "model.meta"     \
					--ckpt_name ${ckptname}     \
					--image_file ${input_path} \
					1>> ${temp_txt}  2>> ${temp_err}   ; \
					printf "filename: "${slice}" ; "  >> ${output_txt};  \

					prediction=$( cat ${temp_txt} | grep   "Predicted" ) ; \
					prediction_v=( $( echo ${prediction} ) )
					prediction_t=${prediction_v[2]}					
				

					Confidence=$( cat ${temp_txt} | grep   "Confidence"  ) ; 
					
					Confidence_v=( $( echo "${Confidence}" ) )
					Confidence_H=${Confidence_v[2]}
					Confidence_H=${Confidence_H//','/''}
					Confidence_P=${Confidence_v[4]}
					Confidence_P=${Confidence_P//','/''}
					Confidence_C=${Confidence_v[6]}
					Confidence_C=${Confidence_C//','/''}
					#echo "confidence H: "${Confidence_H}
					#echo "confidence P: "${Confidence_P}
					#echo "confidence C: "${Confidence_C}

					case ${prediction_t} in 

						Normal)
						Confidence_H=`printf "%.3f" $Confidence_H`
						Confidence="Confidence: "${Confidence_H}
						count_H=$(( $count_H + 1 ))
						;;

						Pneumonia)
						Confidence_P=`printf "%.3f" $Confidence_P`
						Confidence="Confidence: "${Confidence_P}
						count_P=$(( $count_P + 1 ))
						;;

						COVID-19)
						Confidence_C=`printf "%.3f" $Confidence_C`
						Confidence="Confidence: "${Confidence_C}
						count_C=$(( $count_C + 1 ))
						;;

					esac

					printf " -  ${prediction} "
#					sleep 1.5
					echo " -  "${Confidence}; \
					echo ${prediction}" ; "${Confidence} >> ${output_txt} ; 
					
					cat ${temp_txt} >> ${temp_log};
					rm ${temp_txt}; 
					

					
	done

	echo "Number of slice Predicted as Normal: "${count_H}
	echo "Number of slice Predicted as Pneumonia: "${count_P}
	echo "Number of slice Predicted as COVID-19: "${count_C}

	[ $( exists ${temp_dir} ) -eq 1 ] && { rm -rf ${temp_dir} ; }

else



	input_path=$( check_type ${input_path}  )
	[ "$input_path" == "None" ] && { fail "Unsupported file type '$file_type'";} 
	sleep 1
	printf "Image: "$( fbasename ${input_path} )" "; 

	# perform prediction
	
	python ${COVIDNet_DIR}"/run_covidnet_ct.py" infer     \
					--model_dir ${weightspath}     \
					--meta_name "model.meta"     \
					--ckpt_name ${ckptname}     \
					--image_file ${input_path} \
					1>> ${temp_txt}  2>> ${temp_err}   ; \
					printf "Image: "$( fbasename ${input_path} )" ; "  >> ${output_txt};  \
					prediction=$( cat ${temp_txt} | grep   "Predicted" ) ; \
					Confidence=$( cat ${temp_txt} | grep   "Confidence" ) ; \
					printf " -  ${prediction} "
					sleep 1.5
					echo " -  "${Confidence}; \
					echo ${prediction}" ; "${Confidence} >> ${output_txt} ;
					cp ${temp_txt}  ${temp_log}
					rm ${temp_txt};
					sleep 0.5
					[ -z ${input_path_jpg} ] || { rm ${input_path_jpg} ; }

fi


