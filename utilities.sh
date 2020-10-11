#! /bin/bash


#########################################################################################################################
#########################################################################################################################
###################		            							      ###################
###################	title:	            	  Utilities					      ###################
###################		           							      ###################
###################	description:	Useful BASH functions					      ###################
###################										      ###################
###################	version:	0.0     				                      ###################
###################	notes:	        needs utilities.py		 			      ###################
###################										      ###################
###################	bash version:   tested on GNU bash, version 4.2.53			      ###################
###################		           							      ###################
###################	autor: gamorosino     							      ###################
###################     email: g.amorosino@gmail.com						      ###################
###################		           							      ###################
#########################################################################################################################
#########################################################################################################################


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/"
pyutilities=${SCRIPT_DIR}"/pyutilities.py"


gdrive_getID () {
		    	############# ############# ############# ############# ############# ############# #############
		    	############# 	            Get the ID of the Goole Drive file from the link        ############# 
		    	############# ############# ############# ############# ############# ############# #############

			if [ $# -lt 1 ]; then												
			    echo $0: usage: "gdrive_getID <url>  "
			    return 1;		    
			fi
			local url=$1
			fileid=""
			declare -a patterns=("s/.*\/file\/d\/\(.*\)\/.*/\1/p" "s/.*id\=\(.*\)/\1/p" "s/\(.*\)/\1/p")
			for i in "${patterns[@]}"
			do
   				fileid=$(echo $url | sed -n $i)
   				[ ! -z "$fileid" ] && break
			done

			[ -z "${fileid}" ] && { echo "None" ; }	

			echo "${fileid}"

		}

gdrive_download () {


		    	############# ############# ############# ############# ############# ############# #############
		    	############# 	   		Google drive direct download			    ############# 
		    	############# ############# ############# ############# ############# ############# #############

			if [ $# -lt 2 ]; then							# usage dello script							
			    echo $0: usage: "gdrive_download <url> <filename.ext> "
			    return 1;		    
			fi

			local url=$1
			local filename=$2

			fileid=$( gdrive_getID ${url}  )


			[ "${fileid}" == "None" ] && { echo "Could not find Google ID"; exit 1 ; }	

			echo "File ID: "$fileid 
			
			temp_folder=$( dirname ${filename} )"/gdrive_download_"$( date +%s)"/"
			cookies_txt=${temp_folder}"/cookies.txt"			
			header_txt=${temp_folder}"/header.txt"
			confirm_txt=${temp_folder}"/confirm.txt"

			mkdir -p $temp_folder
			
			wget --save-cookies ${cookies_txt} 'https://docs.google.com/uc?export=download&id='$fileid -O- \
     			| sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p' > ${confirm_txt}

			wget --load-cookies ${cookies_txt} -O $filename \
     			'https://docs.google.com/uc?export=download&id='$fileid'&confirm='$(<${confirm_txt})

			rm -rf ${temp_folder}

			};	


imm_dcm2jpg () {


		if [ $# -lt 1 ]; then							# usage dello script							
		    echo $0: usage: "imm_dcm2jpg <dcm_path> [<outputdir>] "		
		    return 1
		fi

		local dcm_path=$1
		local outputdir=$2
		local modulepy=$( fbasename ${pyutilities} )
		local scriptpydir=$( dirname ${pyutilities} )
		
		[ -z ${outputdir} ] &&  { outputdir=None;}
		
		if [ "${outputdir}" == "None" ]; then
			python -c "import sys;sys.path.append('$SCRIPT_DIR');\
			from ${modulepy} import dcm2jpg; dcm2jpg('${dcm_path}');"; 
		else
			python -c "import sys;sys.path.append('$SCRIPT_DIR');	\
			from ${modulepy} import dcm2jpg; dcm2jpg('$dcm_path','${outputdir}');";
		fi


		};

imm_png2jpg () {


		if [ $# -lt 1 ]; then							# usage dello script							
		    echo $0: usage: "imm_png2jpg <png_path> [<outputdir>] "		
		    return 1
		fi

		local png_path=$1
		local outputdir=$2
		local modulepy=$( fbasename ${pyutilities} )
		local scriptpydir=$( dirname ${pyutilities} )
		
		[ -z ${outputdir} ] &&  { outputdir=None;}
		
		if [ "${outputdir}" == "None" ]; then
			python -c "import sys;sys.path.append('$SCRIPT_DIR');\
			from ${modulepy} import png2jpg; png2jpg('${png_path}');"; 
		else
			python -c "import sys;sys.path.append('$SCRIPT_DIR');	\
			from ${modulepy} import png2jpg; png2jpg('$png_path','${outputdir}');";
		fi


		};
