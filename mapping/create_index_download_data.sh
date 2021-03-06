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
	echo "  [-w | -whitelist]	- Path to the Cell Ranger whitelist directory that comes with the Cell Ranger software"
	echo "  [-t | -threads]  - Number of threads"
	exit -1
}

#proceed parameters
while test $# -gt 0
	do
		case $1 in
			-h | -help) usage;;
			-o | -ouput) main_outpath=$2;;
			-g | -github_path) github_path=$2;;
            -w | -whitelist) whitelist_dir=$2;;
            -t | -threads) threads=$2;;
			*) echo "ERROR: unknown argument $1" ; exit -1
	esac
	shift 2
	
done



# 1. unzip whitelist and add mapper to $PATH
gunzip ${whitelist_dir}3M-february-2018.txt.gz
app_dir=${main_outpath}software/
export PATH=${app_dir}cellranger/cellranger-6.0.2/:$PATH
export PATH=${app_dir}starsolo/STAR-2.7.3a/bin/Linux_x86_64_static/:$PATH
export PATH=${app_dir}alevin/salmon-1.5.1_linux_x86_64/bin/:$PATH
export PATH=${app_dir}kallisto/kallisto/:$PATH
export PATH=${app_dir}kallisto/bustools/:$PATH


# 2. Create reference genomes
    # 2.1 Download all ref files
        mkdir ${main_outpath}references/human/
        cd ${main_outpath}references/human/
        curl -o - ftp://ftp.ensembl.org/pub/release-97/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz | gunzip >Homo_sapiens.GRCh38.dna.primary_assembly.fa
        curl -o - ftp://ftp.ensembl.org/pub/release-97/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz | gunzip > Homo_sapiens.GRCh38.cdna.all.fa
        curl -o - ftp://ftp.ensembl.org/pub/release-97/fasta/homo_sapiens/ncrna/Homo_sapiens.GRCh38.ncrna.fa.gz | gunzip > Homo_sapiens.GRCh38.ncrna.fa
        curl -o - ftp://ftp.ensembl.org/pub/release-97/gtf/homo_sapiens/Homo_sapiens.GRCh38.97.gtf.gz | gunzip > Homo_sapiens.GRCh38.97.gtf

        #mkdir ${main_outpath}references/mouse/
        #cd ${main_outpath}references/mouse/
        #curl -o - ftp://ftp.ensembl.org/pub/release-97/fasta/mus_musculus/dna/Mus_musculus.GRCm38.dna.primary_assembly.fa.gz | gunzip > Mus_musculus.GRCm38.dna.primary_assembly.fa
        #curl -o - ftp://ftp.ensembl.org/pub/release-97/fasta/mus_musculus/cdna/Mus_musculus.GRCm38.cdna.all.fa.gz | gunzip > Mus_musculus.GRCm38.cdna.all.fa
        #curl -o - ftp://ftp.ensembl.org/pub/release-97/fasta/mus_musculus/ncrna/Mus_musculus.GRCm38.ncrna.fa.gz.gz | gunzip > Mus_musculus.GRCm38.ncrna.fa
        #curl -o - ftp://ftp.ensembl.org/pub/release-97/gtf/mus_musculus/Mus_musculus.GRCm38.97.gtf.gz.gz | gunzip > Mus_musculus.GRCm38.97.gtf


    # 2.2 Filter Genes and create Index
        # 2.2.2 Create Ref Genome for Cellranger
            mkdir ${main_outpath}references/human/cellranger/
            cd ${main_outpath}references/human/cellranger/
            bash ${github_path}references/create_reference_GRCh38_97.sh

            cellranger mkgtf ../Homo_sapiens.GRCh38.97.gtf ../Homo_sapiens.GRCh38.97_cellranger_filtered.gtf \
            --attribute=gene_biotype:protein_coding \
            --attribute=gene_biotype:lncRNA \
            --attribute=gene_biotype:IG_LV_gene \
            --attribute=gene_biotype:IG_V_gene \
            --attribute=gene_biotype:IG_V_pseudogene \
            --attribute=gene_biotype:IG_D_gene \
            --attribute=gene_biotype:IG_J_gene \
            --attribute=gene_biotype:IG_J_pseudogene \
            --attribute=gene_biotype:IG_C_gene \
            --attribute=gene_biotype:IG_C_pseudogene \
            --attribute=gene_biotype:TR_V_gene \
            --attribute=gene_biotype:TR_V_pseudogene \
            --attribute=gene_biotype:TR_D_gene \
            --attribute=gene_biotype:TR_J_gene \
            --attribute=gene_biotype:TR_J_pseudogene \
            --attribute=gene_biotype:TR_C_gene


            #mkdir ${main_outpath}references/mouse/cellranger/
            #cd ${main_outpath}references/mouse/cellranger/
            #bash ${github_path}references/create_ref_mouse.sh
#
            #cellranger mkgtf ../Mus_musculus.GRCm38.97.gtf ../Mus_musculus.GRCm38.97_cellranger_filtered.gtf \
            #--attribute=gene_biotype:protein_coding \
            #--attribute=gene_biotype:lncRNA \
            #--attribute=gene_biotype:IG_LV_gene \
            #--attribute=gene_biotype:IG_V_gene \
            #--attribute=gene_biotype:IG_V_pseudogene \
            #--attribute=gene_biotype:IG_D_gene \
            #--attribute=gene_biotype:IG_J_gene \
            #--attribute=gene_biotype:IG_J_pseudogene \
            #--attribute=gene_biotype:IG_C_gene \
            #--attribute=gene_biotype:IG_C_pseudogene \
            #--attribute=gene_biotype:TR_V_gene \
            #--attribute=gene_biotype:TR_V_pseudogene \
            #--attribute=gene_biotype:TR_D_gene \
            #--attribute=gene_biotype:TR_J_gene \
            #--attribute=gene_biotype:TR_J_pseudogene \
            #--attribute=gene_biotype:TR_C_gene


		# 2.2.3 Create Index for STARsolo
			mkdir ${main_outpath}references/human/starsolo/ ${main_outpath}references/human/starsolo/index_filtered
            cd ${main_outpath}references/human/starsolo/

			STAR --runMode genomeGenerate \
			--runThreadN $threads \
			--genomeDir ${main_outpath}references/human/starsolo/index_filtered \
			--sjdbGTFfile ../Homo_sapiens.GRCh38.97_cellranger_filtered.gtf \
			--genomeFastaFiles ../Homo_sapiens.GRCh38.dna.primary_assembly.fa

			#mkdir ${main_outpath}references/mouse/starsolo/ ${main_outpath}references/mouse/starsolo/index_filtered
            #cd ${main_outpath}references/mouse/starsolo/
#
			#STAR --runMode genomeGenerate \
			#--runThreadN $threads \
			#--genomeDir ${main_outpath}references/mouse/starsolo/index_filtered \
			#--sjdbGTFfile ../Mus_musculus.GRCm38.97_cellranger_filtered.gtf \
			#--genomeFastaFiles ../Mus_musculus.GRCm38.dna.primary_assembly.fa


	    #2.2.4 Create Index for Salmon
			mkdir ${main_outpath}references/human/alevin/
            cd ${main_outpath}references/human/alevin/
			#create filtered fasta transcriptome file
			cat ../Homo_sapiens.GRCh38.cdna.all.fa ../Homo_sapiens.GRCh38.ncrna.fa > ../Homo_sapiens.GRCh38.cdna_ncrna.fa

			awk '{if ($3=="transcript") print substr($14,2,length($14)-3) "." substr($16,2,length($16)-3)}' ../Homo_sapiens.GRCh38.97_cellranger_filtered.gtf | sort > transcript_names_gtf_filtered.txt
			Rscript --vanilla ${github_path}mapping/alevin_index/filter_fasta_alevin.R "human"

			# get genome targets
			# After https://combine-lab.github.io/alevin-tutorial/2019/selective-alignment/
			grep "^>" ../Homo_sapiens.GRCh38.dna.primary_assembly.fa | cut -d " " -f 1 > decoys.txt
			sed -i.bak -e 's/>//g' decoys.txt
			#combine transcript and genome (Transcript targets before Genome targets)
			cat ../Homo_sapiens.GRCh38.cdna_ncrna_filtered.fa ../Homo_sapiens.GRCh38.dna.primary_assembly.fa > gentrome.fa
			#create index
			salmon index -t gentrome.fa -d decoys.txt -p 16 -i salmon_index_filtered

			#create transcript to gene file (txp)
			awk '{if ($3=="transcript") print substr($14,2,length($14)-3) "." substr($16,2,length($16)-3) "\t" \
			substr($10,2,length($10)-3) "." substr($12,2,length($12)-3)}' \
			../Homo_sapiens.GRCh38.97_cellranger_filtered.gtf > txp2gene.tsv



            ##mouse
			#mkdir ${main_outpath}references/mouse/alevin/
            #cd ${main_outpath}references/mouse/alevin/
			##create filtered fasta transcriptome file
			#cat ../Mus_musculus.GRCm38.cdna.all.fa ../Mus_musculus.GRCm38.ncrna.fa > ../ Mus_musculus.GRCm38.cdna_ncrna.fa
#
			#awk '{if ($3=="transcript") print substr($14,2,length($14)-3) "." substr($16,2,length($16)-3)}' ../Mus_musculus.GRCm38.97_cellranger_filtered.gtf | sort > transcript_names_gtf_filtered.txt
			#Rscript --vanilla ${github_path}mapping/alevin_index/filter_fasta_alevin.R "mouse"
#
			## get genome targets
			## After https://combine-lab.github.io/alevin-tutorial/2019/selective-alignment/
			#grep "^>" ../Mus_musculus.GRCm38.dna.primary_assembly.fa | cut -d " " -f 1 > decoys.txt
			#sed -i.bak -e 's/>//g' decoys.txt
			##combine transcript and genome (Transcript targets before Genome targets)
			#cat ../Mus_musculus.GRCm38.cdna_ncrna.fa ../Mus_musculus.GRCm38.dna.primary_assembly.fa > gentrome.fa
			##create index
			#salmon index -t gentrome.fa -d decoys.txt -p 16 -i salmon_index_filtered
#
			##create transcript to gene file (txp)
			#awk '{if ($3=="transcript") print substr($14,2,length($14)-3) "." substr($16,2,length($16)-3) "\t" \
			#substr($10,2,length($10)-3) "." substr($12,2,length($12)-3)}' \
			#../Mus_musculus.GRCm38.97.gtf > txp2gene.tsv

	    #2.2.5 Create Index for Alevin-fry
	        mkdir ${main_outpath}references/human/alevin-fry/
	        mkdir ${main_outpath}references/human/alevin-fry/filtered/
            cd ${main_outpath}references/human/alevin-fry/
            # Scripts from https://github.com/COMBINE-lab/usefulaf
			Rscript --vanilla ${github_path}mapping/alevin_index/build_splici_ref.R \
                ${main_outpath}references/human/cellranger/GRCh38_97/fasta/genome.fa \
                ${main_outpath}references/human/cellranger/GRCh38_97/genes/genes.gtf.gz \
                91 \
                ${main_outpath}references/human/alevin-fry/filtered/

            salmon index \
                -t ${main_outpath}references/human/alevin-fry/filtered/transcriptome_splici_fl86.fa \
                -i ${main_outpath}references/human/alevin-fry/filtered/grch38_97_bench_splici_idx \
                -p $threads

            #mkdir ${main_outpath}references/mouse/alevin-fry/

        #2.2.6 Create Index for Kallisto
            mkdir ${main_outpath}references/human/kallisto/
            cd ${main_outpath}references/human/kallisto/
			#create transcript to gene list for kallisto
			awk '{if ($3=="transcript") print substr($14,2,length($14)-3) "." substr($16,2,length($16)-3) "\t" \
			 substr($10,2,length($10)-3)  "." substr($12,2,length($12)-3) "\t" substr($18,2,length($18)-3)}' \
			 ../Homo_sapiens.GRCh38.97_cellranger_filtered.gtf > txp_kallisto.txt
			#Run indexing
			kallisto index -i kallisto_index ../Homo_sapiens.GRCh38.cdna_ncrna_filtered.fa

			#mkdir ${main_outpath}references/mouse/kallisto/
            #cd ${main_outpath}references/mouse/kallisto/
			##create transcript to gene list for kallisto
			#awk '{if ($3=="transcript") print substr($14,2,length($14)-3) "." substr($16,2,length($16)-3) "\t" \
			# substr($10,2,length($10)-3)  "." substr($12,2,length($12)-3) "\t" substr($18,2,length($18)-3)}' \
			# ../Mus_musculus.GRCm38.97.gtf > txp_kallisto.txt
			##Run indexing
			#kallisto index -i kallisto_index ../ Mus_musculus.GRCm38.cdna_ncrna_filtered.fa


# 3. Download sequencing data
    cd ${main_outpath}fastqs/pbmc_10x
    curl -O https://s3-us-west-2.amazonaws.com/10x.files/samples/cell-exp/3.0.2/5k_pbmc_v3/5k_pbmc_v3_fastqs.tar
    tar -xf 5k_pbmc_v3_fastqs.tar
    mkdir 5k_pbmc_v3_fastqs/sample1 5k_pbmc_v3_fastqs/sample2 5k_pbmc_v3_fastqs/sample3 5k_pbmc_v3_fastqs/sample4
    mv 5k_pbmc_v3_fastqs/*L001_R*_001.fastq.gz 5k_pbmc_v3_fastqs/sample1/
    mv 5k_pbmc_v3_fastqs/*L002_R*_001.fastq.gz 5k_pbmc_v3_fastqs/sample2/
    mv 5k_pbmc_v3_fastqs/*L003_R*_001.fastq.gz 5k_pbmc_v3_fastqs/sample3/
    mv 5k_pbmc_v3_fastqs/*L004_R*_001.fastq.gz 5k_pbmc_v3_fastqs/sample4/
