#!/bin/bash

function usage() #shows how to use this script
{
	echo 
	echo "Run Alevin-fry sequentially"
	
	echo
	echo "Usage: $0 [-n name of the samples (comma separated)] [-f fastq file paths (comma separated)]"
	echo
	echo "OPTIONS:"
	echo "  [-s | -samples SampleName1,SampleName2,SampleName3] - Sample Names (comma separated, --sample in cellranger command)"
	echo "  [-d | -sampleDirs Path1,Path2,Path3]    - Paths to samplefolders which contain the Fastq files (comma separated, d)"
	echo "  [-i | -index RefGenome Path]    - Path that contains the reference sequences (--transcriptome in cellranger command)"
	echo "  [-t | -tech Seq Kit used]    - Used sequencing Kit (either 'chromium' or 'chromiumV3'  )"
	echo "  [-x | -threads]  - Threads to use "
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
			-x | -thread) thread=$2;;
			-t | -tech) technology=$2;;
			-o | -outFolder) outFolder=$2;;
			*) echo "ERROR: unknown argument $1" ; exit -1
	esac
	shift 2
	
done

i=0
#print raw commands to the log file
echo "#raw command" >> ${outFolderSample}${SAMPLENAME}"commands_Alevin-fry.txt"
echo $0 $@ >> ${outFolderSample}${SAMPLENAME}"commands_Alevin-fry.txt"

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
	echo "Run Alevin-fry for ${SAMPLENAME}"
	echo "salmon alevin -i ${index}grch38_97_bench_splici_idx/ \
    -p $thread \
    -l IU $technology \
    --rad \
    -1 $READ1 \
    -2 $READ2 \
    -o ${outFolderSample}_map >> ${outFolderSample}${SAMPLENAME}log.txt 

    #processing
    alevin-fry generate-permit-list -d fw -k \n
        -i ${outFolderSample}${SAMPLENAME}_map \n
        -o ${outFolderSample}${SAMPLENAME}_quant >> ${outFolderSample}${SAMPLENAME}log.txt 
    
    #collate the file
    alevin-fry collate -t $thread \n
        -i ${outFolderSample}${SAMPLENAME}_quant \n
        -r ${outFolderSample}${SAMPLENAME}_map >> ${outFolderSample}${SAMPLENAME}log.txt 
    
    alevin-fry quant -t $thread -i ${outFolderSample}${SAMPLENAME}_quant \n
        -o ${outFolderSample}${SAMPLENAME}_quant_res \n
        --tg-map ${index}transcriptome_splici_fl86/transcriptome_splici_fl86_t2g_3col.tsv \n
        --resolution cr-like \n
        --use-mtx >> ${outFolderSample}${SAMPLENAME}log.txt " >> ${outFolderSample}${SAMPLENAME}"commands_Alevin-fry.txt"
    
    SECONDS=0
    { time $( salmon alevin -i ${index}grch38_97_bench_splici_idx/ \
        -p $thread \
        -l IU $technology \
        --rad \
        -1 $READ1 \
        -2 $READ2 \
        -o ${outFolderSample}${SAMPLENAME}_map
    
    #processing
    alevin-fry generate-permit-list -d fw -k \
        -i ${outFolderSample}${SAMPLENAME}_map \
        -o ${outFolderSample}${SAMPLENAME}_quant
    
    #collate the file
    alevin-fry collate -t $thread \
        -i ${outFolderSample}${SAMPLENAME}_quant \
        -r ${outFolderSample}${SAMPLENAME}_map
    
    alevin-fry quant -t $thread -i ${outFolderSample}${SAMPLENAME}_quant \
        -o ${outFolderSample}${SAMPLENAME}_quant_res \
        --tg-map ${index}transcriptome_splici_fl86_t2g_3col.tsv \
        --resolution cr-like \
        --use-mtx ) > ${outFolderSample}${SAMPLENAME}log.txt ; } 2> ${outFolderSample}${SAMPLENAME}runtime.txt
    
    Rscript --vanilla /media/Helios_scStorage/Ralf/Benchmark/Gigascience/Skripte/filter_raw_emptyDrops.R \
        ${outFolderSample}${SAMPLENAME}_quant_res/ \
        ${outFolderSample}${SAMPLENAME}_quant_res/alevin/ \
        "alevin-fry" \
        "emptyDrops" $thread
    
    echo $SECONDS > ${outFolderSample}${SAMPLENAME}runtime_sec.txt
    
    let i++

done





	#/opt/salmon-latest_linux_x86_64/bin/salmon alevin \
	#	-l ISR \
	#	-1 $READ1 \
	#	-2 $READ2 \
	#	$technology \
	#	-p 16 \
	#	-i $index \
	#	-o ${outFolderSample} \
	#	--tgMap ${txp} 2> ${outFolderSample}${SAMPLENAME}outLog.log ;
