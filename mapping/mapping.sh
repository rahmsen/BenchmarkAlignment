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
	echo "  [-g | -github_path]	- Path to the github repository BenchmarkAlignment"
	echo "  [-w | -whitelist]	- Path to the Cell Ranger whitelist directory"
	exit -1
}

#proceed parameters
while test $# -gt 0
	do
		case $1 in
			-h | -help) usage;;
			-i | -ouput) main_outpath=$2;;
			-g | -github_path) outFolder=$2;;
            -w | -whitelist) whitelist_dir=$2;;
			*) echo "ERROR: unknown argument $1" ; exit -1
	esac
	shift 2
	
done



# 3. Run Mapping
sample_paths=$(ls -d ${main_outpath}fastqs/pbmc_10x/5k_pbmc_v3_fastqs/sample*/ | sed -z 's/\n/,/g;s/,$//')
#	3.1 Run Mapping with Cell Ranger 6
#	3.1.3 PBMC (Human)
        mkdir ${main_outpath}MappedReads/pbmc_10x/cellranger6/results_filtered_anno/
        cd ${main_outpath}MappedReads/pbmc_10x/cellranger6/results_filtered_anno/

		bash ${github_path}mapping/tool_scripts/MapCellranger6.sh -s sample1,sample2,sample3,sample4 \
		-d $sample_paths \
		-i ${main_outpath}references/human/cellranger/GRCh38_97/ -t 16


# 3.2 Run Mapping with STARsolo
        mkdir ${main_outpath}MappedReads/pbmc_10x/starsolo/results_filtered_anno/
        cd ${main_outpath}MappedReads/pbmc_10x/starsolo/results_filtered_anno/

		bash ${github_path}mapping/tool_scripts/MapSTARsolo.sh -s sample1,sample2,sample3,sample4 \
		-d $sample_paths \
		-i ${main_outpath}references/human/starsolo/index_filtered/ \
		-w ${whitelist_dir}3M-february-2018.txt \
		-u 12 -o ${main_outpath}MappedReads/pbmc_10x/starsolo/results_filtered_anno/


#3.3. Run Mapping with Alevin
        mkdir ${main_outpath}MappedReads/pbmc_10x/alevin/results_filtered_anno/
        cd ${main_outpath}MappedReads/pbmc_10x/alevin/results_filtered_anno/

		bash ${github_path}mapping/tool_scripts/MapAlevin.sh -s sample1,sample2,sample3,sample4 \
        -d $sample_paths \
		-i ${main_outpath}references/human/alevin/salmon_index_filtered/ \
		-o ${main_outpath}MappedReads/pbmc_10x/alevin/results_filtered_anno/ \
		-t --chromiumV3 -x ${main_outpath}references/human/alevin/txp2gene.tsv



    #3.4 Alevin-fry
    mkdir ${main_outpath}MappedReads/Cardiac/alevin-fry/
        mkdir ${main_outpath}MappedReads/pbmc_10x/alevin-fry/results_filtered_anno/
        cd ${main_outpath}MappedReads/pbmc_10x/alevin-fry/results_filtered_anno/

        bash ${github_path}/mapping/tool_scripts/MapAlevin-fry.sh \
        -s sample1,sample2,sample3,sample4 \
        -d $sample_paths \
        -i ${main_outpath}references/human/alevin_fry/ \
        -o ${main_outpath}MappedReads/pbmc_10x/alevin-fry/results_filtered_anno/ \
        -t --chromiumV3 -x 16


# 3.4. Run Kallisto
cd $main_outpath

	#3.4.3 PBMC (Human)
	    mkdir ${main_outpath}MappedReads/pbmc_10x/kallisto/results_filtered_anno/
        cd ${main_outpath}MappedReads/pbmc_10x/kallisto/results_filtered_anno/

		bash ${github_path}mapping/tool_scripts/MapKallisto.sh -s sample1,sample2,sample3,sample4 \
		-d $sample_paths \
		-i ${main_outpath}references/human/kallisto/kallisto_index \
		-o ${main_outpath}MappedReads/pbmc_10x/kallisto/results_filtered_anno/ \
		-c 10xv3 -t 16 \
		-w ${whitelist_dir}3M-february-2018.txt \
		-x ${main_outpath}/references/human/kallisto/txp_kallisto.txt



#4.2.3. Filter by Empty Drops Method
#PBMC
# Cell Ranger 6
for i in `ls -1d ${main_outpath}MappedReads/pbmc_10x/cellranger6/results_filtered_anno/*/outs/`; do
    { time Rscript --vanilla ${github_path}mapping/post_mapping/filter_raw_emptyDrops.R ${i}raw_feature_bc_matrix/ ${i} "cellranger" "emptyDrops" $threads ; } 2> ${i}runtime_empty_drops.txt &&\
    mv ${i}filtered_matrix_emptyDrops/features.tsv.gz ${i}filtered_matrix_emptyDrops/features_backup.tsv.gz &&\
    cp ${i}raw/features.tsv.gz ${i}filtered_matrix_emptyDrops/features.tsv.gz
done


# STARsolo
for i in `ls -1d ${main_outpath}MappedReads/pbmc_10x/starsolo/results_filtered_anno/sample4/Solo.out/Gene/`; do
    gzip ${i}raw/barcodes.tsv ${i}raw/features.tsv ${i}raw/matrix.mtx &&\
	{ time Rscript --vanilla ${github_path}mapping/post_mapping/filter_raw_emptyDrops.R ${i}raw/ $i "starsolo" "emptyDrops" $threads ; } 2> ${i}runtime_empty_drops.txt &&\
	mv ${i}filtered_matrix_emptyDrops/features.tsv.gz ${i}filtered_matrix_emptyDrops/features_backup.tsv.gz &&\
	cp ${i}raw/features.tsv.gz ${i}filtered_matrix_emptyDrops/features.tsv.gz
done

# Kallisto
for i in `ls -1d ${main_outpath}MappedReads/pbmc_10x/kallisto/results_filtered_anno/*/counting/`; do 
	{ time Rscript --vanilla ${github_path}mapping/post_mapping/filter_raw_emptyDrops.R $i $i "kallisto" "emptyDrops" $threads ; } 2> ${i}runtime_empty_drops.txt
done 

