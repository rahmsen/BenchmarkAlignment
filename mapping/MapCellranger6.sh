#!/bin/bash

function usage() #shows how to use this script
{
	echo 
	echo "Run Cellranger sequentially"
	
	echo
	echo "Usage: $0 [-n name of the samples (comma separated)] [-f fastq file paths (comma separated)]"
	echo
	echo "OPTIONS:"
	echo "  [-s | -samples SampleName1,SampleName2,SampleName3] - Sample Names (comma separated"
	echo "  [-d | -sampleDirs Path1,Path2,Path3]    - Path of folder created by mkfastq or bcl2fastq. (comma separated, d)"
	echo "  [-i | -index RefGenome Path]    - Path of folder containing 10x-compatible reference."
	echo "  [-t | -threads ]   - Number of threads to use."
	exit -1
}

#proceed parameters
while test $# -gt 0
	do
		case $1 in
			-h | -help) usage;;
			-s | -samples) IFS=',' read -r -a SAMPLENAMES <<< "$2";;
			-d | -sampleDirs) IFS=',' read -r -a SAMPLEDIRS <<< $2;;
			-i | -index) index=$2;;
            -t | -threads) threads=$2;;
			*) echo "ERROR: unknown argument $1" ; exit -1
	esac
	shift 2
	
done

i=0


for sampledir in ${SAMPLEDIRS[*]}; do
	SAMPLENAME=${SAMPLENAMES[i]}
	outFolderSample=${sampledir}
	echo "Start Analysis for " $SAMPLENAME
	
    #print raw commands to the log file
    echo "#raw command" >> ${sampledir}${SAMPLENAME}"commands_Cellranger.txt"
    echo $0 $@ >> ${sampledir}${SAMPLENAME}"commands_Cellranger.txt"
    
	echo Samplename: ${SAMPLENAME}
	echo outFolderSample: ${outFolderSample}

	#mkdir ${outFolderSample}
	#write commands to commands.txt in output folder

	#run command
	#Alignment 
	echo "Run Cellranger for ${SAMPLENAME}"
	echo "/opt/cellranger-6.0.2/cellranger count \
		--id=${SAMPLENAME} \
		--transcriptome=$index \
		--fastqs=$sampledir \
		--nosecondary \
		--localcores=$threads 2> ${SAMPLENAME}outLog.log " >>  $outFolder"commands_Cellranger.txt"
	

	{ time /opt/cellranger-6.0.2/cellranger count \
		--id=${SAMPLENAME} \
		--transcriptome=$index \
		--fastqs=$sampledir \
		--nosecondary \
		--localcores=$threads > ${SAMPLENAME}outLog.log ; } 2> ${SAMPLENAME}runtime.txt

	let i++

done







