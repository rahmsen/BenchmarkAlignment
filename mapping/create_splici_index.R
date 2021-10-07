suppressPackageStartupMessages({
  library(eisaR)
  library(Biostrings)
  library(BSgenome)
  library(stringr)
  library(dplyr)
  library(GenomicFeatures)
})

args <- commandArgs(trailingOnly=TRUE)

if (length(args)==0){
  stop("Please provide a path to the directory of the output data.")
}

ref <- args[1]
out_path <- args[2]
skript <- args[3]

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