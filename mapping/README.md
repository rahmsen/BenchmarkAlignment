# Read-Me Mapping PBMC

## Download and install mapper

1. Run script downloadSoftware.sh to download and install each mapper.

 ```{bash}
downloadSoftware.sh -o path/to/main/output/
  ```
2. Download Cell Ranger 6 from the [10x website](https://support.10xgenomics.com/single-cell-gene-expression/software/downloads/6.0) to ../software/cellranger and unpack


## Create index for each tool and download sequence data of PBMC

3. Run script create_index_download_data.sh

 ```{bash}
create_index_download_data.sh -o /path/to/main/output/ -g /path/to/github/dir/ -w /path/to/whitelist/ -t 16
  ```
## Create the index for Alevin-fry

4.  When we use a script does it will throw an error. Therefore the commands need to be run in Rstudio. Run commands in Rstudio to create alevin-fry index:

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
 
## Mapping

5. Run the script mapping.sh
 ```{bash}
 mapping.sh -o /path/to/main/output/ -g /path/to/github/dir/ -w /path/to/whitelist/ -t 16
 ```
