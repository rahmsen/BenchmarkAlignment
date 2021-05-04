#!/bin/bash

function usage() #shows how to use this script
{
	echo 
	echo "Run Kallisto sequentially"
	
	echo
	echo "Usage: $0 [-n name of the samples (comma separated)] [-f fastq file paths (comma separated)]"
	echo
	echo "OPTIONS:"

	echo "  [-d | -sampleDirs Path1,Path2,Path3]    - Paths to samplefolders which contain the Fastq files (comma separated, d)"
	echo "  [-m | -method ]    - Method used [alevin or kalisto]"
	echo "  [-o | -organism ]    - Organism [human or mouse]"

	exit -1
}

#proceed parameters
while test $# -gt 0
	do
		case $1 in
			-h | -help) usage;;
			-d | -sampleDirs) IFS=',' read -r -a SAMPLEDIRS <<< $2;;
			-m | -method) method=$2;;
			-o | -organism) organism=$2;;
			*) echo "ERROR: unknown argument $1" ; exit -1
	esac
	shift 2
	
done

i=0
#print raw commands to the log file
for sampledir in ${SAMPLEDIRS[*]}; do
infile=${sampledir}
if [[ ${method} == "alevin" ]]; then
	echo "Method=${method} [ALEVIN]"
	outfile=$(dirname ${sampledir})"/quants_mat_cols.txt"
fi
if [[ ${method} == "kalisto" ]]; then
	echo "Method=${method} [KALISTO]"
	outfile=$(dirname ${sampledir})"/gcm.genes.txt"
fi
echo "InFile=${infile}"
echo "OutFile=${outfile}"

echo "organism=${organism}"
if [[ ${organism} == "human" ]]; then
echo "Human"
	Rscript --vanilla ./Adjust_gene_names_both_organism.R ${infile} ${outfile} ${method} ${organism}
	awk '{print $1 "\t" $3}' ${infile} > ${outfile}

fi
if [[ ${organism} == "mouse" ]]; then
	echo "Mouse"
	Rscript --vanilla ./Adjust_gene_names.R ${infile} ${outfile} ${method}
fi
	
	let i++
echo "Done"
done



