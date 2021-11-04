#!/usr/bin/R

# Gene names 

suppressPackageStartupMessages(library(dplyr))

args <- commandArgs(trailingOnly=TRUE)

file_path_in <- args[1]
file_path_out <- args[2]
tool_name <- args[3]

cat("Infile ", file_path_in,"\n")
cat("Outfile ", file_path_out,"\n")
cat("toolName ", tool_name,"\n")
cat("Adjusting gene names\n")
gene_names <- read.delim("/media/ATLAS_NGS_storage/RalfSB/Results/Kallisto/gene_name.txt",header = F,colClasses = c(rep("character",2)))



genes_kallisto <- read.delim(file_path_in, header = F,stringsAsFactors = F)
merged_kallisto <- inner_join(genes_kallisto[1],gene_names,by=c("V1"="V1"))

if (tool_name=="alevin"){
    write.table(merged_kallisto[2], file_path_out, quote = F, row.names =  F, col.names = F, sep="\t")
	}else{
   write.table(merged_kallisto, file_path_out, quote = F, row.names =  F, col.names = F, sep="\t")
}
