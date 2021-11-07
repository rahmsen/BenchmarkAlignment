#!/bin/bash

function usage() #shows how to use this script
{
	echo 
	echo "Run Alevin-fry sequentially"
	echo
	echo "Usage: $0 [-n name of the samples (comma separated)] [-f fastq file paths (comma separated)]"
	echo
	echo "OPTIONS:"
	echo "  [-o | -main_outpath]  - Path of the main directory"
	exit -1
}

#proceed parameters
while test $# -gt 0
	do
		case $1 in
			-h | -help) usage;;
			-o | -ouput) main_outpath=$2;;
			*) echo "ERROR: unknown argument $1" ; exit -1
	esac
	shift 2
	
done


## Change according to your desired
#github_path=/media/Helios_scStorage/Ralf/Benchmark/Gigascience/git/BenchmarkAlignment/
#main_outpath=/media/Storage/Benchmark_test2/
threads=16
app_dir=${main_outpath}software/
whitelist_dir=${app_dir}cellranger/cellranger-6.0.2/lib/python/cellranger/barcodes/

cd $main_outpath
mkdir MappedReads MappedReads/pbmc_10x/ MappedReads/pbmc_10x/alevin-fry/ MappedReads/pbmc_10x/cellranger6/ MappedReads/pbmc_10x/starsolo/ MappedReads/pbmc_10x/alevin/ MappedReads/pbmc_10x/kallisto/ references fastqs fastqs/pbmc_10x


# 2 Download & install Software
mkdir ${app_dir}
    ## 2.1 Cellranger
		mkdir ${app_dir}cellranger
		#cd ${app_dir}cellranger
		#curl -o cellranger-6.0.2.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-6.0.2.tar.gz?Expires=1635490832&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jZi4xMHhnZW5vbWljcy5jb20vcmVsZWFzZXMvY2VsbC1leHAvY2VsbHJhbmdlci02LjAuMi50YXIuZ3oiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2MzU0OTA4MzJ9fX1dfQ__&Signature=b2mcBCCMdb0oJ9-mIJXgZjWqXgemTxtBIgDScCgzZXZJ~Ia-3HDmU8RwjR1CU7fLFfJvV3Nnm~jUMMtG3UamjnSht7hAh7s0YZ2B96DN4jCquN1M2nJEl~MtbN2loxZ3va-E6pS1CylqITLs5zl~2d241PeyHM~MDym~Kh9pckmcdbq8~G-IKM4if8~Am8XFNTTcJrgLW8fexgwp5aYn1WxKlvov4aQPAzvYVc6Me37ptisphq3f5zTSFFQVbk1M5ipINBFo5t0VbLnQOsS6e5vxbnJ~jwk5PI-tO3vVZct~8jOE-26RM1aoL-pUHcQbwJQ2moi-KKSABtjsGxtiig__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA"
		#tar -xzf cellranger-6.0.2.tar.gz
		#gunzip ${whitelist_dir}3M-february-2018.txt.gz
		#export PATH=${app_dir}cellranger/cellranger-6.0.2/:$PATH

	## 2.2 STARsolo
		mkdir ${app_dir}starsolo
		cd ${app_dir}starsolo
		wget https://github.com/alexdobin/STAR/archive/2.7.3a.tar.gz
		tar -xzf 2.7.3a.tar.gz
		

	## 2.3 Alevin / Salmon
		mkdir ${app_dir}alevin
		cd ${app_dir}alevin
		wget https://github.com/COMBINE-lab/salmon/releases/download/v1.1.0/salmon-1.1.0_linux_x86_64.tar.gz
		tar -xzf salmon-1.1.0_linux_x86_64.tar.gz
		

	## 2.4 Alevin-fry
		mkdir ${app_dir}alevin_fry
		cd ${app_dir}alevin_fry
		curl https://sh.rustup.rs -sSf | sh
		source $HOME/.cargo/env
		cargo install alevin-fry --version 0.4.0

	## 2.5 Kalisto
		mkdir ${app_dir}kallisto
		cd ${app_dir}kallisto
		wget https://github.com/pachterlab/kallisto/releases/download/v0.46.1/kallisto_linux-v0.46.1.tar.gz
		tar -vxzf ${app_dir}kallisto/kallisto_linux-v0.46.1.tar.gz
		

		wget https://github.com/BUStools/bustools/releases/download/v0.39.3/bustools_linux-v0.39.3.tar.gz
        tar -vxzf ${app_dir}kallisto/bustools_linux-v0.39.3.tar.gz
		
        

