#!/bin/bash

function usage() #shows how to use this script
{
	echo 
	echo "Run STARsolo sequentially"
	
	echo
	echo "Usage: $0 [-n name of the samples (comma separated)] [-f fastq file paths (comma separated)]"
	echo
	echo "OPTIONS:"
	echo "  [-s | -samples SampleName1,SampleName2,SampleName3] - Sample Names (comma separated, --sample in cellranger command)"
	echo "  [-d | -sampleDirs Path1,Path2,Path3]    - Paths to samplefolders which contain the Fastq files (comma separated, d)"
	echo "  [-i | -index RefGenome Path]    - Path that contains the reference sequences (--transcriptome in cellranger command)"
	echo "  [-w | -white 10x whitelist]    - Path to 10x whitelist"
	echo "  [-u | -umi UMI length]    - UMI length in the fastq R1 file depending on the prep kit version "
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
			-w | -white) white=$2;;
			-u | -umi) umi=$2;;
			-o | -outFolder) outFolder=$2;;
			*) echo "ERROR: unknown argument $1" ; exit -1
	esac
	shift 2
	
done

i=0
#print raw commands to the log file
echo "#raw command" >> $outFolder"commands_STARsolo.txt"
echo $0 $@ >> $outFolder"commands_STARsolo.txt"

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
	echo "Run STARsolo for ${SAMPLENAME}"
	echo "	STAR --soloType Droplet \
		--soloCBwhitelist $white \
		--genomeDir $index \
		--readFilesIn <(gunzip -c $READ2) <(gunzip -c $READ1) \
		--outSAMtype BAM SortedByCoordinate \
		--outSAMattributes NH HI AS nM CR CY UR UY CB UB GX GN \
		--soloUMIlen $umi \
		--runThreadN 16 \
		--outFileNamePrefix=${outFolderSample} 2> ${outFolderSample}${SAMPLENAME}outLog.log ;" >> $outFolder"commands_STARsolo.txt"
	

	STAR --soloType Droplet \
		--soloCBwhitelist $white \
		--genomeDir $index \
		--readFilesIn <(gunzip -c $READ2) <(gunzip -c $READ1) \
		--outSAMtype BAM SortedByCoordinate \
		--outSAMattributes NH HI AS nM CR CY UR UY CB UB GX GN \
		--soloUMIlen $umi \
		--runThreadN 16 \
		--outFileNamePrefix=${outFolderSample} 2> ${outFolderSample}${SAMPLENAME}outLog.log ;
    
	let i++

done







