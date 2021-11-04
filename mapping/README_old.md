# 1. Create reference genomes
#	1.1 Download all files
#		1.1.1. Human	
			#Ensembl
	 		cd /media/ATLAS_Genomes_Annotations/human/GRCh38.97/
			wget ftp://ftp.ensembl.org/pub/release-97/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
			wget ftp://ftp.ensembl.org/pub/release-97/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz
			wget ftp://ftp.ensembl.org/pub/release-97/fasta/homo_sapiens/ncrna/Homo_sapiens.GRCh38.ncrna.fa.gz
			wget ftp://ftp.ensembl.org/pub/release-97/gtf/homo_sapiens/Homo_sapiens.GRCh38.97.gtf.gz

			#Cellranger
			wget -O cellrangerRefGenome/refdata-cellranger-GRCh38-3.0.0.tar.gz https://cf.10xgenomics.com/supp/cell-exp/refdata-cellranger-GRCh38-3.0.0.tar.gz
			tar -xvzf cellrangerRefGenome/refdata-cellranger-GRCh38-3.0.0.tar.gz -C cellrangerRefGenome/
#		1.1.2 Mouse
			#Ensembl
			cd /media/ATLAS_Genomes_Annotations/mouse/GRCm38.97/
			wget ftp://ftp.ensembl.org/pub/release-97/fasta/mus_musculus/dna/Mus_musculus.GRCm38.dna.primary_assembly.fa.gz
			wget ftp://ftp.ensembl.org/pub/release-97/fasta/mus_musculus/cdna/Mus_musculus.GRCm38.cdna.all.fa.gz
			wget ftp://ftp.ensembl.org/pub/release-97/fasta/mus_musculus/ncrna/Mus_musculus.GRCm38.ncrna.fa.gz
			wget ftp://ftp.ensembl.org/pub/release-97/gtf/mus_musculus/Mus_musculus.GRCm38.97.gtf.gz

#	1.2 Filter Genes and create Index
#		1.2.1 Filter Genes
			#Human
			/opt/cellranger-3.0.2/cellranger mkgtf /media/ATLAS_Genomes_Annotations/human/GRCh38.97/Homo_sapiens.GRCh38.97.gtf /media/ATLAS_Genomes_Annotations/human/GRCh38.97/Homo_sapiens.GRCh38.97.cellranger_filtered.gtf     --attribute=gene_biotype:protein_coding     --attribute=gene_biotype:lncRNA     --attribute=gene_biotype:IG_LV_gene     --attribute=gene_biotype:IG_V_gene     --attribute=gene_biotype:IG_V_pseudogene     --attribute=gene_biotype:IG_D_gene     --attribute=gene_biotype:IG_J_gene     --attribute=gene_biotype:IG_J_pseudogene     --attribute=gene_biotype:IG_C_gene     --attribute=gene_biotype:IG_C_pseudogene     --attribute=gene_biotype:TR_V_gene     --attribute=gene_biotype:TR_V_pseudogene     --attribute=gene_biotype:TR_D_gene     --attribute=gene_biotype:TR_J_gene     --attribute=gene_biotype:TR_J_pseudogene     --attribute=gene_biotype:TR_C_gene

			#Mouse
			/opt/cellranger-3.0.2/cellranger mkgtf /media/ATLAS_Genomes_Annotations/mouse/GRCm38.97/Mus_musculus.GRCm38.97.gtf /media/ATLAS_Genomes_Annotations/mouse/GRCm38.97/Mus_musculus.GRCm38.97.cellranger_filtered.gtf     --attribute=gene_biotype:protein_coding     --attribute=gene_biotype:lncRNA     --attribute=gene_biotype:IG_LV_gene     --attribute=gene_biotype:IG_V_gene     --attribute=gene_biotype:IG_V_pseudogene     --attribute=gene_biotype:IG_D_gene     --attribute=gene_biotype:IG_J_gene     --attribute=gene_biotype:IG_J_pseudogene     --attribute=gene_biotype:IG_C_gene     --attribute=gene_biotype:IG_C_pseudogene     --attribute=gene_biotype:TR_V_gene     --attribute=gene_biotype:TR_V_pseudogene     --attribute=gene_biotype:TR_D_gene     --attribute=gene_biotype:TR_J_gene     --attribute=gene_biotype:TR_J_pseudogene     --attribute=gene_biotype:TR_C_gene

#		1.2.2 Create Ref Genome Cellranger
			#Human
			/opt/cellranger-3.0.2/cellranger mkref --memgb=100 --nthreads=16 --genome=Homo_sapiens.GRCh38.97.dna.primary_assembly.cellranger_filtered \
			--fasta=/media/ATLAS_Genomes_Annotations/human/GRCh38.97/Homo_sapiens.GRCh38.dna.primary_assembly.fa \
			    --genes=/media/ATLAS_Genomes_Annotations/human/GRCh38.97/Homo_sapiens.GRCh38.97.cellranger_filtered.gtf
			#Mouse
			/opt/cellranger-3.0.2/cellranger mkref --memgb=100 --nthreads=16 --genome=Mus_musculus.GRCm38.97.dna.primary_assembly.cellranger_filtered \
			--fasta=/media/ATLAS_Genomes_Annotations/mouse/GRCm38.97/Mus_musculus.GRCm38.dna.primary_assembly.fa \
			    --genes=/media/ATLAS_Genomes_Annotations/mouse/GRCm38.97/Mus_musculus.GRCm38.97.cellranger_filtered.gtf
            1.2.2.1 Create Ref Genome for Cellranger 4 and 5
            #v4
            #human
              references/create_reference_GRCh38_97.sh
            #mouse
              references/create_ref_mouse_v4.sh
            #v5
            #human
              references/create_reference_GRCh38_97.sh
            #mouse
              references/create_ref_mouse_v5.sh
		1.2.3 Create Index for STARsolo
			# Human
				STAR --runMode genomeGenerate \
				--runThreadN 16 \
				--genomeDir /media/Storage/additional_datasets/pbmc_10x/starsolo_remap/reference/index_filtered \
				--sjdbGTFfile /media/Storage/additional_datasets/human_embryo/references/Homo_sapiens.GRCh38.97.cellranger_filtered.gtf \
				--genomeFastaFiles /media/Storage/additional_datasets/human_embryo/references/Homo_sapiens.GRCh38.dna.primary_assembly.fa \
				--limitGenomeGenerateRAM 100000000000
			# Mouse
			    STAR --runMode genomeGenerate \
				--runThreadN 16 \
				--genomeDir /media/Helios_scStorage/Ralf/MouseHom_AMI/Results/Star_solo/index \
				--sjdbGTFfile /media/ATLAS_Genomes_Annotations/mouse/GRCm38/GRCm38.97/Mus_musculus.GRCm38.97.cellranger_filtered.gtf \
				--genomeFastaFiles /media/ATLAS_Genomes_Annotations/mouse/GRCm38/GRCm38.97/Mus_musculus.GRCm38.dna.primary_assembly.fa \
				--limitGenomeGenerateRAM 100000000000

	#		1.2.4 Create Index for Salmon
#			1.2.4.1 Human	
				cd /media/ATLAS_Genomes_Annotations/human/GRCh38.97/		
				#create filtered fasta transcriptome file
				cat Homo_sapiens.GRCh38.cdna.all.fa Homo_sapiens.GRCh38.ncrna.fa > Homo_sapiens.GRCh38.cdna_ncrna.fa
				awk '{if ($3=="transcript") print substr($14,2,length($14)-3) "." substr($16,2,length($16)-3)}' Homo_sapiens.GRCh38.97.cellranger_filtered.gtf | sort > transcript_names_gtf_filtered.txt

				#Following commands r run within R
				    library(seqinr)
					transcriptome.fa <- read.fasta("Homo_sapiens.GRCh38.97.cdna_ncrna.fa",seqtype = "DNA")
					transcript.names <- read.table("transcript_names_gtf_filtered.txt",stringsAsFactors = F)
					filtered_transcriptome <- transcriptome.fa[names(transcriptome.fa) %in% transcript.names$V1]
					write.fasta(filtered_transcriptome,names = names(filtered_transcriptome), "Homo_sapiens.GRCh38.97.cdna_ncrna.filtered.fa")			


				#get genome targets
				grep "^>" Homo_sapiens.GRCh38.dna.primary_assembly.fa | cut -d " " -f 1 > Homo_sapiens.GRCh38.dna.primary_assembly.genomeNames
				sed -i.bak -e 's/>//g' Homo_sapiens.GRCh38.dna.primary_assembly.genomeNames
				#combine transcript and genome (Transcript targets before Genome targets)
				cat Homo_sapiens.GRCh38.97.cdna_ncrna.filtered.fa Homo_sapiens.GRCh38.dna.primary_assembly.fa > Homo_sapiens.GRCh38.cdna_ncrna_filtered.dna_primaryassembly.combined.fa
				#create index
				/opt/salmon-latest_linux_x86_64/bin/salmon index -t Homo_sapiens.GRCh38.cdna_ncrna_filtered.dna_primaryassembly.combined.fa -d Homo_sapiens.GRCh38.dna.primary_assembly.genomeNames -p 22 -i salmon_index_filtered
				#create transcript to gene file (txp)
				awk '{if ($3=="transcript") print substr($14,2,length($14)-3) "." substr($16,2,length($16)-3) "\t" substr($10,2,length($10)-3) "." substr($12,2,length($12)-3)}' \
  Homo_sapiens.GRCh38.97.cellranger_filtered.gtf > txp2gene.tsv

#			1.2.4.2Mouse
				cd /media/ATLAS_Genomes_Annotations/mouse/GRCm38.97/
				#create filtered fasta transcriptome file
				cat Mus_musculus.GRCm38.cdna.all.fa Mus_musculus.GRCm38.ncrna.fa > Mus_musculus.GRCm38.cdna_ncrna.fa
				awk '{if ($3=="transcript") print substr($14,2,length($14)-3) "." substr($16,2,length($16)-3)}' Mus_musculus.GRCm38.97.cellranger_filtered.gtf | sort > transcript_names_gtf_filtered.txt

				#Following commands r run within R
					library(seqinr)
					transcriptome.fa <- read.fasta("Mus_musculus.GRCm38.cdna_ncrna.fa",seqtype = "DNA")
					transcript.names <- read.table("transcript_names_gtf_filtered.txt",stringsAsFactors = F)
					filtered_transcriptome <- transcriptome.fa[names(transcriptome.fa) %in% transcript.names$V1]
					write.fasta(filtered_transcriptome,names = names(filtered_transcriptome), "Mus_musculus.GRCm38.cdna_ncrna.filtered.fa")

				#get genome targets
				grep "^>" Mus_musculus.GRCm38.dna.primary_assembly.fa | cut -d " " -f 1 > Mus_musculus.GRCm38.dna.primary_assembly.genomeNames
				sed -i.bak -e 's/>//g' Mus_musculus.GRCm38.dna.primary_assembly.genomeNames
				#combine transcript and genome (Transcript targets before Genome targets)
				cat Mus_musculus.GRCm38.cdna_ncrna.filtered.fa Mus_musculus.GRCm38.dna.primary_assembly.fa > Mus_musculus.GRCm38.cdna_ncrna_filtered.dna_primaryassembly.combined.fa
				#create index
				/opt/salmon-latest_linux_x86_64/bin/salmon index -t Mus_musculus.GRCm38.cdna_ncrna_filtered.dna_primaryassembly.combined.fa -d Mus_musculus.GRCm38.dna.primary_assembly.genomeNames -p 22 -i salmon_index_filtered

				#create transcript to gene file (txp)
				awk '{if ($3=="transcript") print substr($14,2,length($14)-3) "." substr($16,2,length($16)-3) "\t" substr($10,2,length($10)-3) "." substr($12,2,length($12)-3)}' \
  Mus_musculus.GRCm38.97.cellranger_filtered.gtf > txp2gene.tsv

				
#		1.2.5 Create Index for Kalisto
#			1.2.5.1 Human
				#create transcript to gene list for kallisto
				awk '{if ($3=="transcript") print substr($14,2,length($14)-3) "." substr($16,2,length($16)-3) "\t" substr($10,2,length($10)-3)  "." substr($12,2,length($12)-3) "\t" substr($18,2,length($18)-3)}' Homo_sapiens.GRCh38.97.cellranger_filtered.gtf > transcripts_to_genes_kallisto_filtered.txt
				#Run indexing
				/opt/kallisto/kallisto index -i Homo_sapiens.GRCh38.97.cdna_ncrna.kallisto_index_filtered Homo_sapiens.GRCh38.97.cdna_ncrna.filtered.fa
			
			1.2.5.2 Mouse
				#create transcript to gene list for kallisto
				awk '{if ($3=="transcript") print substr($14,2,length($14)-3) "." substr($16,2,length($16)-3) "\t" substr($10,2,length($10)-3)  "." substr($12,2,length($12)-3) "\t" substr($18,2,length($18)-3)}' Mus_musculus.GRCm38.97.cellranger_filtered.gtf > transcripts_to_genes_kallisto_filtered.txt
				#Run indexing
				/opt/kallisto/kallisto index -i Mus_musculus.GRCm38.97.cdna_ncrna.kallisto_index_filtered Mus_musculus.GRCm38.cdna_ncrna.filtered.fa



# 2 Download & install Software
#	2.1 Cellranger
		sudo wget -O /opt/cellranger-3.0.2.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-3.0.2.tar.gz?Expires=1605828160&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jZi4xMHhnZW5vbWljcy5jb20vcmVsZWFzZXMvY2VsbC1leHAvY2VsbHJhbmdlci0zLjAuMi50YXIuZ3oiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2MDU4MjgxNjB9fX1dfQ__&Signature=l4uFpI~mWRQPm4~99Hd5bfL7xCAkBXtK-OmnmLmqSfy2r7znd4DBEtTkdH~Na9~LBI7C2ponjmUddLeROKzGqPm5YlcAUD1docXYWkfWzWNo4Larz~wDYhlSA4Z3Ybd7QTyDFamhxNFh2yce7I7YDZ9Aecx5APXiQAu4Ih0yd7oAR25-CXrfX0V2IscCZWsDEXenlipbHGkXeXWG9foKYoyxFjD7Hn7Y4HVR6fcNBEL7l27HIcVsgu1CnrdF-0Sn8LVqVj7~NkfLNyqhv259HYahg5JFzgt7oODimHwk2jO1ejgOgWnl4-C2D6OQ0IQF85VPCnJVL-zD2l5FxUD3TQ__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA" --2020-11-19 12:30:18--  https://cf.10xgenomics.com/releases/cell-exp/cellranger-3.0.2.tar.gz?Expires=1605828160&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jZi4xMHhnZW5vbWljcy5jb20vcmVsZWFzZXMvY2VsbC1leHAvY2VsbHJhbmdlci0zLjAuMi50YXIuZ3oiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2MDU4MjgxNjB9fX1dfQ__&Signature=l4uFpI~mWRQPm4~99Hd5bfL7xCAkBXtK-OmnmLmqSfy2r7znd4DBEtTkdH~Na9~LBI7C2ponjmUddLeROKzGqPm5YlcAUD1docXYWkfWzWNo4Larz~wDYhlSA4Z3Ybd7QTyDFamhxNFh2yce7I7YDZ9Aecx5APXiQAu4Ih0yd7oAR25-CXrfX0V2IscCZWsDEXenlipbHGkXeXWG9foKYoyxFjD7Hn7Y4HVR6fcNBEL7l27HIcVsgu1CnrdF-0Sn8LVqVj7~NkfLNyqhv259HYahg5JFzgt7oODimHwk2jO1ejgOgWnl4-C2D6OQ0IQF85VPCnJVL-zD2l5FxUD3TQ__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA
		sudo tar -xvzf /opt/cellranger-3.0.2.tar.gz
		sudo mv cellranger-3.0.2/ /opt/

	2.2 STARsolo
		wget https://github.com/alexdobin/STAR/archive/2.7.3a.tar.gz
		tar -xzf 2.7.3a.tar.gz

	2.3 Alevin / Salmon
		wget -O salmon-1.1.0_linux_x86_64.tar.gz /opt/ https://github.com/COMBINE-lab/salmon/releases/download/v1.1.0/salmon-1.1.0_linux_x86_64.tar.gz
		sudo mv salmon-1.1.0_linux_x86_64.tar.gz /opt/

	2.4 Kalisto
		wget https://github.com/pachterlab/kallisto/releases/download/v0.46.1/kallisto_linux-v0.46.1.tar.gz
		tar -vxzf kallisto_linux-v0.46.1.tar.gz 

# 3. Run Mapping
#	3.1 Run Mapping with Cell Ranger
#	3.1.1 Cardiac (Mouse)
		bash /media/Helios_scStorage/Ralf/Benchmark/DavidRuns/MapCellranger.sh -s MF17010,MF17013,MF17014,MF17015,MF17016,MF17017,MF17018 -d /media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17010/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17013/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17014/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17015/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17016/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17017/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17018/ -i /media/ATLAS_Genomes_Annotations/mouse/GRCm38.97/ref_cdna_cellranger_3.0.2_GRCm38.97
#	3.1.2 Endothelial (Mouse)
		bash /media/Helios_scStorage/Ralf/Benchmark/DavidRuns/MapCellranger.sh -s Brain,Colon,Heart,Kidney,Liver,Lung,muscle_EDL,muscle_Soleus,Small_Intestine,Spleen,Testis -d /media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Brain/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Colon/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Heart/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Kidney/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Liver/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Lung/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/muscle_EDL/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/muscle_Soleus/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Small_Intestine/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Spleen/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Testis/ -i /media/ATLAS_Genomes_Annotations/mouse/GRCm38.97/ref_cdna_cellranger_3.0.2_GRCm38.97
#	3.1.3 PBMC (Human)
		bash /media/Helios_scStorage/Ralf/Benchmark/DavidRuns/MapCellranger.sh -s sample1,sample2,sample3,sample4 -d /media/Helios_scStorage/Ralf/Benchmark/fastqs/PBMC/5k_pbmc_v3_fastqs/sample1/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/PBMC/5k_pbmc_v3_fastqs/sample2/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/PBMC/5k_pbmc_v3_fastqs/sample3/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/PBMC/5k_pbmc_v3_fastqs/sample4/ -i /media/ATLAS_Genomes_Annotations/human/GRCh38.97/cellrangerRefGenome/ref_cdna_cellranger_3.0.2_GRCm38.97

# 3.2 Run Mapping with STARsolo
#	3.2.1 Cardiac (Mouse)
		bash /media/Helios_scStorage/Ralf/Benchmark/DavidRuns/MapSTARsolo.sh -s MF17010,MF17013,MF17014,MF17015,MF17016,MF17017,MF17018 -d /media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17010/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17013/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17014/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17015/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17016/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17017/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17018/ -i /media/ATLAS_Genomes_Annotations/mouse/GRCm38.97/index_starsolo -w /opt/cellranger-3.0.2/cellranger-cs/3.0.2/lib/python/cellranger/barcodes/737K-august-2016.txt -u 10 -o /media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/starsolo/Cardiac/
#	3.2.2 Endothelial (Mouse)
		bash /media/Helios_scStorage/Ralf/Benchmark/DavidRuns/MapSTARsolo.sh -s Brain,Colon,Heart,Kidney,Liver,Lung,muscle_EDL,muscle_Soleus,Small_Intestine,Spleen,Testis -d /media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Brain/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Colon/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Heart/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Kidney/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Liver/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Lung/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/muscle_EDL/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/muscle_Soleus/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Small_Intestine/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Spleen/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Testis/ -i /media/ATLAS_Genomes_Annotations/mouse/GRCm38.97/index_starsolo -w /opt/cellranger-3.0.2/cellranger-cs/3.0.2/lib/python/cellranger/barcodes/737K-august-2016.txt -u 9 -o /media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/starsolo/Endothelial/
#	3.2.3 PBMC (Human)
		bash /media/Helios_scStorage/Ralf/Benchmark/DavidRuns/MapSTARsolo.sh -s Brain,Colon,Heart,Kidney,Liver,Lung,muscle_EDL,muscle_Soleus,Small_Intestine,Spleen,Testis -d /media/Helios_scStorage/Ralf/Benchmark/fastqs/PBMC/5k_pbmc_v3_fastqs/sample1/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/PBMC/5k_pbmc_v3_fastqs/sample2/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/PBMC/5k_pbmc_v3_fastqs/sample3/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/PBMC/5k_pbmc_v3_fastqs/sample4/ -i /media/ATLAS_Genomes_Annotations/human/GRCh38.97/index_filtered_star_solo -w /opt/cellranger-3.0.2/cellranger-cs/3.0.2/lib/python/cellranger/barcodes/3M-february-2018.txt -u 12 -o /media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/starsolo/pbmc/

#	3.3. Run Mapping with Alevin
#		3.3.1 Cardiac (Mouse)
			bash MapAlevin.sh -s MF17010,MF17013,MF17014,MF17015,MF17016,MF17017,MF17018 -d /media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17010/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17013/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17014/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17015/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17016/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17017/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17018/ -i /media/ATLAS_Genomes_Annotations/mouse/GRCm38.97/salmon_index_filtered -o /media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/Cardiac/ -t --chromium -x /media/ATLAS_Genomes_Annotations/mouse/GRCm38.97/txp2gene.tsv
#		3.3.2 Endothelial (Mouse)
			bash MapAlevin.sh -s Brain,Colon,Heart,Kidney,Liver,Lung,muscle_EDL,muscle_Soleus,Small_Intestine,Spleen,Testis -d /media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Brain/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Colon/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Heart/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Kidney/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Liver/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Lung/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/muscle_EDL/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/muscle_Soleus/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Small_Intestine/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Spleen/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/Testis/ -i  /media/ATLAS_Genomes_Annotations/mouse/GRCm38.97/salmon_index_filtered -o /media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/Endothelial/ -t --end\ 5\ --umiLength\ 9\ --barcodeLength\ 16 -x /media/ATLAS_Genomes_Annotations/mouse/GRCm38.97/txp2gene.tsv

#		3.3.3 PBMC (Human)
			bash MapAlevin.sh -s sample1,sample2,sample3,sample4 -d /media/Helios_scStorage/Ralf/Benchmark/fastqs/PBMC/5k_pbmc_v3_fastqs/sample1/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/PBMC/5k_pbmc_v3_fastqs/sample2/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/PBMC/5k_pbmc_v3_fastqs/sample3/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/PBMC/5k_pbmc_v3_fastqs/sample4/ -i /media/ATLAS_Genomes_Annotations/human/GRCh38.97/salmon_index_filtered/ -o /media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/pbmc/ -t --chromiumV3 -x /media/ATLAS_Genomes_Annotations/human/GRCh38.97/txp2gene.tsv


#	3.3.4 create Backup of files before changing them
		sed -i.bak '' DavidRuns/Mapping/Alevin/*/*/alevin/quants_mat_cols.txt
#	3.3.5 Adjust Gene Names
		#Cardiac
		bash adjust_geneNames.sh -d /media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/Cardiac/MF17010/alevin/quants_mat_cols.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/Cardiac/MF17013/alevin/quants_mat_cols.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/Cardiac/MF17014/alevin/quants_mat_cols.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/Cardiac/MF17015/alevin/quants_mat_cols.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/Cardiac/MF17016/alevin/quants_mat_cols.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/Cardiac/MF17017/alevin/quants_mat_cols.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/Cardiac/MF17018/alevin/quants_mat_cols.txt.bak -m alevin -o mouse
		
		#Endothelial
		bash adjust_geneNames.sh -d /media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/Endothelial/Brain/alevin/quants_mat_cols.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/Endothelial/Colon/alevin/quants_mat_cols.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/Endothelial/Heart/alevin/quants_mat_cols.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/Endothelial/Kidney/alevin/quants_mat_cols.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/Endothelial/Liver/alevin/quants_mat_cols.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/Endothelial/Lung/alevin/quants_mat_cols.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/Endothelial/muscle_EDL/alevin/quants_mat_cols.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/Endothelial/muscle_Soleus/alevin/quants_mat_cols.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/Endothelial/Small_Intestine/alevin/quants_mat_cols.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/Endothelial/Spleen/alevin/quants_mat_cols.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/Endothelial/Testis/alevin/quants_mat_cols.txt.bak -m alevin -o mouse
		
		#PBMC
		 bash adjust_geneNames.sh -d /media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/pbmc/sample1/alevin/quants_mat_cols.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/pbmc/sample2/alevin/quants_mat_cols.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/pbmc/sample3/alevin/quants_mat_cols.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Alevin/pbmc/sample4/alevin/quants_mat_cols.txt.bak -m alevin -o human







# 3.4. Run Kallisto
	#3.4.1 Cardiac (Mouse)
		bash MapKallisto.sh -s MF17010,MF17013,MF17014,MF17015,MF17016,MF17017,MF17018 -d /media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17010/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17013/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17014/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17015/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17016/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17017/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Cardiac/MF17018/ -i /media/ATLAS_Genomes_Annotations/mouse/GRCm38.97/Mus_musculus.GRCm38.97.cdna_ncrna.kallisto_index_filtered -o /media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/Cardiac/ -t 10xv2 -x /media/ATLAS_Genomes_Annotations/mouse/GRCm38.97/transcripts_to_genes_kallisto_filtered.txt

	#3.4.2 Endothelial (Mouse)
		#combine Fastq Files prior to Mapping
		bash /media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/combineFastqs.sh
	
		bash MapKallisto.sh -s Brain,Colon,Heart,Kidney,Liver,Lung,muscle_EDL,muscle_Soleus,Small_Intestine,Spleen,Testis -d /media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/combinedFastqs/Brain,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/combinedFastqs/Colon,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/combinedFastqs/Heart,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/combinedFastqs/Kidney,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/combinedFastqs/Liver,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/combinedFastqs/Lung,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/combinedFastqs/muscle_EDL,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/combinedFastqs/muscle_Soleus,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/combinedFastqs/Small_Intestine,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/combinedFastqs/Spleen,/media/Helios_scStorage/Ralf/Benchmark/fastqs/Endothelial/combinedFastqs/Testis -i  /media/ATLAS_Genomes_Annotations/mouse/GRCm38.97/Mus_musculus.GRCm38.97.cdna_ncrna.kallisto_index_filtered -o /media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/Endothelial/ -t 0,0,16:0,16,25:1,0,0 -x /media/ATLAS_Genomes_Annotations/mouse/GRCm38.97/transcripts_to_genes_kallisto_filtered.txt

	#3.4.3 PBMC (Human)
		bash MapKallisto.sh -s sample1,sample2,sample3,sample4 -d /media/Helios_scStorage/Ralf/Benchmark/fastqs/PBMC/5k_pbmc_v3_fastqs/sample1/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/PBMC/5k_pbmc_v3_fastqs/sample2/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/PBMC/5k_pbmc_v3_fastqs/sample3/,/media/Helios_scStorage/Ralf/Benchmark/fastqs/PBMC/5k_pbmc_v3_fastqs/sample4/ -i /media/ATLAS_Genomes_Annotations/human/GRCh38.97/Mus_musculus.GRCm38.97.cdna_ncrna.kallisto_index_filtered -o /media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/pbmc/ -t 10xv3 -x /media/ATLAS_Genomes_Annotations/human/GRCh38.97/transcripts_to_genes_kallisto_filtered.txt

3.4.4 Generate Backup files before changing them
		sed -i.bak '' Mapping/Kallisto/*/*/counting/gcm.genes.txt 

3.4.5 Adjust Gene Names
		#Cardiac
		bash adjust_geneNames.sh -d /media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/Cardiac/MF17010/counting/gcm.genes.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/Cardiac/MF17013/counting/gcm.genes.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/Cardiac/MF17014/counting/gcm.genes.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/Cardiac/MF17015/counting/gcm.genes.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/Cardiac/MF17016/counting/gcm.genes.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/Cardiac/MF17017/counting/gcm.genes.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/Cardiac/MF17018/counting/gcm.genes.txt.bak -m kalisto -o mouse 
		
		#Endothelial
		bash adjust_geneNames.sh -d /media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/Endothelial/Brain/counting/gcm.genes.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/Endothelial/Colon/counting/gcm.genes.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/Endothelial/Heart/counting/gcm.genes.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/Endothelial/Kidney/counting/gcm.genes.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/Endothelial/Liver/counting/gcm.genes.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/Endothelial/Lung/counting/gcm.genes.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/Endothelial/muscle_EDL/counting/gcm.genes.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/Endothelial/muscle_Soleus/counting/gcm.genes.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/Endothelial/Small_Intestine/counting/gcm.genes.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/Endothelial/Spleen/counting/gcm.genes.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/Endothelial/Testis/counting/gcm.genes.txt.bak -m kalisto -o mouse
		
		#PBMC
		 bash adjust_geneNames.sh -d /media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/pbmc/sample1/counting/gcm.genes.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/pbmc/sample2/counting/gcm.genes.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/pbmc/sample3/counting/gcm.genes.txt.bak,/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/Mapping/Kallisto/pbmc/sample4/counting/gcm.genes.txt.bak -m kalisto -o human


#4.2.3. Filter by Empty Drops Method
#Cardiac

# Cell Ranger
for i in `ls -1d MappedReads/Cardiac/Cellranger/*/outs/` ; do Rscript --vanilla /media/Helios_scStorage/Ralf/MouseHom_AMI/Results/Star_solo/filter_raw_emptyDrops.R$ {i}raw_feature_bc_matrix/ $i "cellranger" "emptyDrops"; mv ${i}emptyDrops_feature_bc_matrix/genes.tsv ${i}emptyDrops_feature_bc_matrix/genes_backup.tsv ; zcat ${i}raw_feature_bc_matrix/features.tsv.gz > ${i}emptyDrops_feature_bc_matrix/genes.tsv ; done

# STARsolo
for i in `ls -1d MappedReads/Cardiac/Star_solo/*/Solo.out/Gene/` ; do Rscript --vanilla /media/Helios_scStorage/Ralf/MouseHom_AMI/Results/Star_solo/filter_raw_emptyDrops.R ${i}raw/ $i "star_solo" "emptyDrops" ; mv ${i}filtered_matrix_emptyDrops/genes.tsv ${i}filtered_matrix_emptyDrops/genes_backup.tsv ; cp ${i}raw/genes.tsv ${i}filtered_matrix_emptyDrops/genes.tsv
    

# Kallisto
for i in `ls -1d Mapping/Kallisto/Cardiac/*/counting/`; do Rscript --vanilla /media/Helios_scStorage/Ralf/MouseHom_AMI/Results/Star_solo/filter_raw_emptyDrops.R $i $i "kallisto" "emptyDrops" $i; done 
sed -i.bak '' Mapping/Kallisto/Cardiac/MF*/counting/filtered_matrix_emptyDrops/genes.tsv

for i in `ls -1d Mapping/Kallisto/Cardiac/MF*/counting/filtered_matrix_emptyDrops/genes.tsv`; do awk '{print $1 "\t" $2}' $i.bak > $i; done 



#Endothelial
# Cell Ranger
for i in `ls -1d MappedReads/Endothelial/Cellranger/*/outs/` ; do Rscript --vanilla /media/Helios_scStorage/Ralf/MouseHom_AMI/Results/Star_solo/filter_raw_emptyDrops.R$ {i}raw_feature_bc_matrix/ $i "cellranger" "emptyDrops"; mv ${i}emptyDrops_feature_bc_matrix/genes.tsv ${i}emptyDrops_feature_bc_matrix/genes_backup.tsv ; zcat ${i}raw_feature_bc_matrix/features.tsv.gz > ${i}emptyDrops_feature_bc_matrix/genes.tsv ; done

# STARsolo
for i in `ls -1d MappedReads/Endothelial/Star_solo/*/Solo.out/Gene/` ; do Rscript --vanilla /media/Helios_scStorage/Ralf/MouseHom_AMI/Results/Star_solo/filter_raw_emptyDrops.R ${i}raw/ $i "star_solo" "emptyDrops"; mv ${i}filtered_matrix_emptyDrops/genes.tsv ${i}filtered_matrix_emptyDrops/genes_backup.tsv ; cp ${i}raw/genes.tsv ${i}filtered_matrix_emptyDrops/genes.tsv

# Kallisto
for i in `ls -1d Mapping/Kallisto/Endothelial/*/counting/`; do Rscript --vanilla /media/Helios_scStorage/Ralf/MouseHom_AMI/Results/Star_solo/filter_raw_emptyDrops.R $i $i "kallisto" "emptyDrops" $i; done 

sed -i.bak '' Mapping/Kallisto/Endothelial/*/counting/filtered_matrix_emptyDrops/genes.tsv

for i in `ls -1d Mapping/Kallisto/Endothelial/*/counting/filtered_matrix_emptyDrops/genes.tsv`; do awk '{print $1 "\t" $2}' $i.bak > $i; done 


#PBMC
# Cell Ranger
for i in `ls -1d MappedReads/pbmc_10x/Cellranger/*/outs/` ; do Rscript --vanilla /media/Helios_scStorage/Ralf/MouseHom_AMI/Results/Star_solo/filter_raw_emptyDrops.R$ {i}raw_feature_bc_matrix/ $i "cellranger" "emptyDrops"; mv ${i}emptyDrops_feature_bc_matrix/genes.tsv ${i}emptyDrops_feature_bc_matrix/genes_backup.tsv ; zcat ${i}raw_feature_bc_matrix/features.tsv.gz > ${i}emptyDrops_feature_bc_matrix/genes.tsv ; done

# STARsolo
for i in `ls -1d MappedReads/pbmc_10x/Star_solo/*/Solo.out/Gene/` ; do Rscript --vanilla /media/Helios_scStorage/Ralf/MouseHom_AMI/Results/Star_solo/filter_raw_emptyDrops.R ${i}raw/ $i "star_solo" "emptyDrops"; mv ${i}filtered_matrix_emptyDrops/genes.tsv ${i}filtered_matrix_emptyDrops/genes_backup.tsv ; cp ${i}raw/genes.tsv ${i}filtered_matrix_emptyDrops/genes.tsv

# Kallisto
for i in `ls -1d Mapping/Kallisto/pbmc/*/counting/`; do Rscript --vanilla /media/Helios_scStorage/Ralf/MouseHom_AMI/Results/Star_solo/filter_raw_emptyDrops.R $i $i "kallisto" "emptyDrops" $i; done 

#4.2.4 filter columns of the genes.tsv for human, otherwise the data is handled as multiple experiments from the Read10X function
sed -i.bak '' Mapping/Kallisto/pbmc/sample*/counting/filtered_matrix_emptyDrops/genes.tsv

for i in `ls -1d Mapping/Kallisto/pbmc/sample*/counting/filtered_matrix_emptyDrops/genes.tsv`; do awk '{print $1 "\t" $2}' $i.bak > $i; done 





#5. import to Seurat
termin