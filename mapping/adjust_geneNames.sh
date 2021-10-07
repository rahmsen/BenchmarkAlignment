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
	echo "  [-m | -method ]    - Method used [alevin, alevin-fry or kallisto]"
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
            -n | -name_file) name_file=$2;;
			*) echo "ERROR: unknown argument $1" ; exit -1
	esac
	shift 2
	
done

i=0
#print raw commands to the log file
for sampledir in ${SAMPLEDIRS[*]}; do
    infile=${sampledir}
    if [[ ${method} == "alevin-fry" ]]; then
    	cp -r $(dirname ${sampledir}) $(dirname ${sampledir})"_backup"
    fi
    
    if [[ ${method} == "alevin" || ${method} == "alevin-fry" ]]; then
    	echo "Method=${method} [ALEVIN]"
    	outfile=$(dirname ${sampledir})"/quants_mat_cols.txt"
    	#make backup
        cp ${infile} $(dirname ${sampledir})"/quants_mat_cols_id.txt"
    fi
    if [[ ${method} == "kallisto" ]]; then
    	echo "Method=${method} [KALLISTO]"
    	outfile=$(dirname ${sampledir})"/gcm.genes.txt"
        cp ${infile} $(dirname ${sampledir})"/gcm.genes_backup.txt"
    fi
    echo "InFile=${infile}"
    echo "OutFile=${outfile}"
    
    
    #echo "organism=${organism}"
    #if [[ ${organism} == "human" ]]; then
    #echo "Human"

	Rscript --vanilla ./Adjust_gene_names_both_organism.R ${infile} ${outfile} ${name_file} ${method} ${organism}

	#if [[ ${method} == "alevin-fry" ]]; then
	#    gzip $(dirname ${sampledir})*
    #fi
	#awk '{print $1 "\t" $3}' ${infile} > ${outfile}

    #fi
    #if [[ ${organism} == "mouse" ]]; then
    #	echo "Mouse"
    #	Rscript --vanilla ./Adjust_gene_names.R ${infile} ${outfile} ${method}
    #fi
	
	let i++
echo "Done"
done

