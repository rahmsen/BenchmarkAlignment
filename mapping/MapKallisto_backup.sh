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
echo "#raw command" >> $outFolder"commands_kallisto.txt"
echo $0 $@ >> $outFolder"commands_kallisto.txt"

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
	echo "Pseudoalignment"
	echo "kallisto bus --index=$index --output-dir=${outFolderSample}${SAMPLENAME} --threads=16 --technology=$technology $READ1 $READ2 2> ${outFolderSample}${SAMPLENAME}_output_log.txt" >>  $outFolder"commands_kallisto.txt"
	

	/opt/kallisto/kallisto bus --index=$index --output-dir=${outFolderSample} --threads=16 --technology=$technology $READ1 $READ2 2>> ${outFolderSample}${SAMPLENAME}_output_log.txt

	#Barcode Correction
	echo "Barcode correction"
	if [[ $technology == "10xv3" ]]; then
		echo "bustools correct -w /opt/cellranger-3.0.2/cellranger-cs/3.0.2/lib/python/cellranger/barcodes/3M-february-2018.txt -o ${outFolderSample}output.correct.bus ${outFolderSample}output.bus 2 >> ${outFolderSample}${SAMPLENAME}_output_correct_log.txt" >>  $outFolder"commands_kallisto.txt"
	bustools correct -w /opt/cellranger-3.0.2/cellranger-cs/3.0.2/lib/python/cellranger/barcodes/3M-february-2018.txt -o ${outFolderSample}output.correct.bus ${outFolderSample}output.bus 2> ${outFolderSample}${SAMPLENAME}_output_correct_log.txt
	elif [[ $technology == "10xv2" ]]; then
		echo "bustools correct -w /opt/cellranger-3.0.2/cellranger-cs/3.0.2/lib/python/cellranger/barcodes/737K-august-2016.txt -o ${outFolderSample}output.correct.bus ${outFolderSample}output.bus 2 >> ${outFolderSample}${SAMPLENAME}_output_correct_log.txt" >>  $outFolder"commands_kallisto.txt"
		bustools correct -w /opt/cellranger-3.0.2/cellranger-cs/3.0.2/lib/python/cellranger/barcodes/737K-august-2016.txt -o ${outFolderSample}output.correct.bus ${outFolderSample}output.bus 2> ${outFolderSample}${SAMPLENAME}_output_correct_log.txt
	elif [[ $technology == "0,0,16:0,16,25:1,0,0" ]]; then
		echo "bustools correct -w /opt/cellranger-3.0.2/cellranger-cs/3.0.2/lib/python/cellranger/barcodes/737K-august-2016.txt -o ${outFolderSample}output.correct.bus ${outFolderSample}output.bus 2 >> ${outFolderSample}${SAMPLENAME}_output_correct_log.txt" >>  $outFolder"commands_kallisto.txt"
		bustools correct -w /opt/cellranger-3.0.2/cellranger-cs/3.0.2/lib/python/cellranger/barcodes/737K-august-2016.txt -o ${outFolderSample}output.correct.bus ${outFolderSample}output.bus 2> ${outFolderSample}${SAMPLENAME}_output_correct_log.txt
	else 
		echo "unknown technology"
		exit -1
	fi
	
	
	

	#barcode sorting 
	echo "Barcode sorting"
	echo "bustools sort -t 8 -o ${outFolderSample}output.corrected.sorted.bus ${outFolderSample}output.correct.bus" >>  $outFolder"commands_kallisto.txt"
	bustools sort -t 8 -o ${outFolderSample}output.corrected.sorted.bus ${outFolderSample}output.correct.bus

	mkdir ${outFolderSample}/counting
	# Create a Gene Count Matrix for downstream analysis
	echo "Creating Gene Count Matrix"
	echo "bustools count -o  ${outFolderSample}counting/gcm -g $txp -e ${outFolderSample}matrix.ec -t  ${outFolderSample}transcripts.txt --genecounts ${outFolderSample}output.corrected.sorted.bus
" >>  $outFolder"commands_kallisto.txt"
	bustools count -o  ${outFolderSample}counting/gcm -g $txp -e ${outFolderSample}matrix.ec -t  ${outFolderSample}transcripts.txt --genecounts ${outFolderSample}output.corrected.sorted.bus


	let i++

done











