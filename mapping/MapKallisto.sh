#!/bin/bash

function usage() #shows how to use this script
{
	echo 
	echo "Run Kallisto sequentially"
	
	echo
	echo "Usage: $0 [-n name of the samples (comma separated)] [-f fastq file paths (comma separated)]"
	echo
	echo "OPTIONS:"
	echo "  [-s | -samples SampleName1,SampleName2,SampleName3] - Sample Names (comma separated, --sample in cellranger command)"
	echo "  [-d | -sampleDirs Path1,Path2,Path3]    - Paths to samplefolders which contain the Fastq files (comma separated, d)"
	echo "  [-i | -index RefGenome Path]    - Path that contains the reference sequences (--transcriptome in cellranger command)"
	echo "  [-x | -txp txp Path Path]    - Path to the Trancript to gene file "
	echo "  [-t | -threads number]     - number of threads to use"
	echo "  [-w | -whitelist Path]     - Path to whitelist"
	echo "  [-c | -chemistry number]     - chemistry of the samples"
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
            -t | -threads) threads=$2;;
            -w | -whitelist) whitelist=$2;;
			-c | -chem) chemistry=$2;;
			-o | -outFolder) outFolder=$2;;
			*) echo "ERROR: unknown argument $1" ; exit -1
	esac
	shift 2
	
done

i=0
#print raw commands to the log file
echo "#raw command" >> $outFolder"commands_kallisto.txt"
echo $0 $@ >> $outFolder"commands_kallisto.txt"

for sampledir in ${SAMPLEDIRS[*]}; do
	SAMPLENAME=${SAMPLENAMES[i]}
	outFolderSample=${outFolder}${SAMPLENAME}/
	echo "Start Analysis for " $SAMPLENAME
	READ1=$(find ${sampledir}/*_R[1-2]_001.fastq.gz -type f)
	#READ2=$sampledir"/*_R2_*.fastq.gz" 
	#find 103837-001-004*_R[1-2]_001.fastq.gz -type f

	echo Samplename: ${SAMPLENAME}
	echo outFolderSample: ${outFolderSample}

	mkdir ${outFolderSample}
	#write commands to commands.txt in output folder

	#run command
	#Alignement $READ2
	echo "Pseudoalignment"
	echo "./software/kallisto/kallisto bus --index=$index --output-dir=${outFolderSample}${SAMPLENAME} --threads=$threads --technology=$chemistry $READ1 2> ${outFolderSample}${SAMPLENAME}_output_log.txt" >>  $outFolder"commands_kallisto.txt"
	#$READ2 
    SECONDS=0
	./software/kallisto/kallisto bus --index=$index --output-dir=${outFolderSample} --threads=$threads --technology=$chemistry $READ1 2>> ${outFolderSample}${SAMPLENAME}_output_log.txt

	#Barcode Correction
	echo "Barcode correction"
	if [[ $chemistry == "10xv3" ]]; then
		echo "./software/bustools/bustools correct -w $whitelist -o ${outFolderSample}output.correct.bus ${outFolderSample}output.bus 2 >> ${outFolderSample}${SAMPLENAME}_output_correct_log.txt" >>  $outFolder"commands_kallisto.txt"
	./software/bustools/bustools correct -w $whitelist -o ${outFolderSample}output.correct.bus ${outFolderSample}output.bus 2> ${outFolderSample}${SAMPLENAME}_output_correct_log.txt
	elif [[ $chemistry == "10xv2" ]]; then
		echo "./software/bustools/bustools correct -w $whitelist -o ${outFolderSample}output.correct.bus ${outFolderSample}output.bus 2 >> ${outFolderSample}${SAMPLENAME}_output_correct_log.txt" >>  $outFolder"commands_kallisto.txt"
		./software/bustools/bustools correct -w $whitelist -o ${outFolderSample}output.correct.bus ${outFolderSample}output.bus 2> ${outFolderSample}${SAMPLENAME}_output_correct_log.txt
	elif [[ $chemistry == "0,0,16:0,16,25:1,0,0" ]]; then
		echo "./software/bustools/bustools correct -w $whitelist -o ${outFolderSample}output.correct.bus ${outFolderSample}output.bus 2 >> ${outFolderSample}${SAMPLENAME}_output_correct_log.txt" >>  $outFolder"commands_kallisto.txt"
		./software/bustools/bustools correct -w $whitelist -o ${outFolderSample}output.correct.bus ${outFolderSample}output.bus 2> ${outFolderSample}${SAMPLENAME}_output_correct_log.txt
	else 
		echo "unknown chemistry"
		exit -1
	fi
	
	
	#barcode sorting 
	echo "Barcode sorting"
	echo "./software/bustools/bustools sort -t $threads -o ${outFolderSample}output.corrected.sorted.bus ${outFolderSample}output.correct.bus" >>  $outFolder"commands_kallisto.txt"
	./software/bustools/bustools sort -t $threads -o ${outFolderSample}output.corrected.sorted.bus ${outFolderSample}output.correct.bus

	mkdir ${outFolderSample}/counting
	# Create a Gene Count Matrix for downstream analysis
	echo "Creating Gene Count Matrix"
	echo "./software/bustools/bustools count -o ${outFolderSample}counting/gcm -g $txp -e ${outFolderSample}matrix.ec -t ${outFolderSample}transcripts.txt --genecounts ${outFolderSample}output.corrected.sorted.bus
" >>  $outFolder"commands_kallisto.txt"
	./software/bustools/bustools count -o ${outFolderSample}counting/gcm -g $txp -e ${outFolderSample}matrix.ec -t ${outFolderSample}transcripts.txt --genecounts ${outFolderSample}output.corrected.sorted.bus
    
    echo $SECONDS > ${outFolderSample}${SAMPLENAME}runtime_sec.txt

	let i++

done











