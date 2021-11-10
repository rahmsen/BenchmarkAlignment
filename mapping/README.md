# Analyze 10X PBMC's with Alevin, Star, Kalisto & Cellranger

###  Download and install all mapper

1. Run script `downloadSoftware.sh` to download and install each mapper.

 ```{bash}
downloadSoftware.sh -o path/to/main/output/
  ```
2. Download and unpack CellRanger 6 from the [10x website](https://support.10xgenomics.com/single-cell-gene-expression/software/downloads/6.0) to the directory **../software/cellranger** 

**Note**: We could not include Cellranger to the donwload script, as it requires a registration.


### Create index for each tool and download sequence data of PBMC

3. Run script create_index_download_data.sh

 ```{bash}
create_index_download_data.sh -o /path/to/main/output/ -g /path/to/github/dir/ -w /path/to/whitelist/ -t 16
  ```
  
#### Create the index for Alevin-fry

4.  In order to generate the alevin-fry index we ran the following commands in Rstudio.

**Note**: If we ran this commands within a script we got 'environment errors, therefore we decided to run this scripts separately withing RStudio. Here everything worked and we couldgenerate the alevin-fry index with the command under 4.1.

 ```{bash}
packages <- c("eisaR", "stringr", "Biostrings", "BSgenome", "GenomicFeatures", "dplyr")
lapply(packages, function(x) {
  if (!require(x, character.only = T)) install.packages(x)
    suppressPackageStartupMessages(library(x, character.only = T))
})

# Change path accordingly
main_outpath <- "/path/to/main/output/"
github_path <- "path/to/github/dir/"


ref <- paste0(main_outpath, "references/human/cellranger/GRCh38_97/")
out_path <- paste0(main_outpath, "references/human/alevin-fry/")
skript <- paste0(github_path, "mapping/alevin_index/")


source(paste0(skript, "make_splici_reference.R"))
setwd(ref)


gtf_path = file.path( "genes/genes.gtf.gz")
genome_path = file.path( "fasta/genome.fa")
read_length = 91
flank_trim_length = 5
output_dir = paste0(out_path, "transcriptome_splici_fl", read_length - flank_trim_length)

make_splici_txome(gtf_path=gtf_path, 
                  genome_path=genome_path, 
                  read_length=read_length, 
                  flank_trim_length=flank_trim_length, 
                  output_dir=output_dir)
```

4.1 Create the index in bash

 ```{bash}
 ${main_outpath}=/path/to/main/output/
 salmon index \
    -t ${main_outpath}references/alevin-fry/human/filtered/transcriptome_splici_fl86/transcriptome_splici_fl86.fa \
    -i ${main_outpath}references/alevin-fry/human/filtered/grch38_97_bench_splici_idx \
    -p 16
 ```
 
### Mapping

5. If all the tools are installed and the indices were succesfully generated the following command will run the PBMC dataset with all mappers mentioned in the paper.

 ```{bash}
 mapping.sh -o /path/to/main/output/ -g /path/to/github/dir/ -w /path/to/whitelist/ -t 16
 ```

___
___
___

#Description of Files



### R-scripts 

* `commands_mapping_AllDataset.txt` — A script with all commands that were used to map all datasets.
* `commands_mapping_PBMC.txt` — The script with only the commands to map the PBMC dataset.
* `create_index_download_data.sh` — A bash script to create the indices for all mapper and download the PBMC dataset. See BenchmarkAlignment/README.md for the correct usage.
* `downloadSoftware.sh` — A bash script that set up the file structure and download and install all necessary mapper. See BenchmarkAlignment/README.md for the correct usage.
* `mapping.sh` — A bash script that does the actual mapping. See BenchmarkAlignment/README.md for the correct usage.
* `create_splici_index.R`, `make_splici_reference.R` are needed to create the index for Alevin-fry. Received from [`https://github.com/COMBINE-lab/usefulaf`](https://github.com/COMBINE-lab/usefulaf)
* `filter_fasta_alevin.R` will be used in `create_index_download_data.sh` to create the Alevin index. It will filter out genes that are not in the gtf annotation file. Otherwise Alevin throws an error of mismatches between the gtf and the fasta file.

### bash-scripts 
* `MapAlevin-fry.sh`, `MapAlevin.sh`, `MapCellranger6.sh`, `MapKallisto.sh`, `MapSTARsolo.sh` are used within `mapping.sh`.


### Post mapping
* `Adjust_gene_names_both_organism.R`, `adjust_geneNames.sh` write the gene ID in the barcodes files asocciated with the count matrices.
* `all_genes_mouse.tsv`, `all_genes_human.tsv` contain the gene symbol to gene ID maping to include the gene ID in `Adjust_gene_names_both_organism.R`
* `filter_raw_emptyDrops.R` Will execute the emptyDrops cell filtering for a mapper. For Alevin-fry it will filter for the spliced and ambigouse read counts and write out as mtx-files to be loaded into R in the script `make_figures.rmd`.




