#!/bin/bash

function usage() #shows how to use this script
{
	echo 
	echo "Run Alevin sequentially"
	
	echo
	echo "Usage: $0 [-n name of the samples (comma separated)] [-f fastq file paths (comma separated)]"
	echo
	echo "OPTIONS:"
	echo "  [-s | -samples SampleName1,SampleName2,SampleName3] - Sample Names (comma separated, --sample in cellranger command)"
	echo "  [-d | -sampleDirs Path1,Path2,Path3]    - Paths to samplefolders which contain the Fastq files (comma separated, d)"
	echo "  [-i | -index RefGenome Path]    - Path that contains the reference sequences (--transcriptome in cellranger command)"
	echo "  [-t | -tech Seq Kit used]    - Used sequencing Kit (either 'chromium' or 'chromiumV3'  )"
	echo "  [-x | -txp txp Path Path]    - Path to the Trancript to gene file "
	echo "  [-o | -outFolder Output folder]	- Path were the Kallisto files are written to"
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
			-x | -txp) txp=$2;;
			-t | -tech) technology=$2;;
			-o | -outFolder) outFolder=$2;;
			*) echo "ERROR: unknown argument $1" ; exit -1
	esac
	shift 2
	
done

i=0
#print raw commands to the log file
echo "#raw command" >> $outFolder"commands_Alevin.txt"
echo $0 $@ >> $outFolder"commands_Alevin.txt"

for sampledir in ${SAMPLEDIRS[*]}; do
	SAMPLENAME=${SAMPLENAMES[i]}
	outFolderSample=${outFolder}${SAMPLENAME}/
	echo "Start Analysis for " $SAMPLENAME
	READ1=$sampledir"*_R1_*.fastq.gz"
	READ2=$sampledir"*_R2_*.fastq.gz" 
	

	echo Samplename: ${SAMPLENAME}
	echo outFolderSample: ${outFolderSample}

	mkdir ${outFolderSample}
	#write commands to commands.txt in output folder

	#run command
	#Alignement 
	echo "Run Alevin for ${SAMPLENAME}"
	echo "/opt/salmon-latest_linux_x86_64/bin/salmon alevin \
		-l ISR \
		-1 $READ1 \
		-2 $READ2 \
		$technology \
		-p 16 \
		-i $index \
		-o ${outFolderSample} \
		--tgMap ${txp} 2> ${outFolderSample}${SAMPLENAME}outLog.log ;" >>  $outFolder"commands_Alevin.txt"
	

	/opt/salmon-latest_linux_x86_64/bin/salmon alevin \
		-l ISR \
		-1 $READ1 \
		-2 $READ2 \
		$technology \
		-p 16 \
		-i $index \
		-o ${outFolderSample} \
		--tgMap ${txp} 2> ${outFolderSample}${SAMPLENAME}outLog.log ;

	let i++

done







