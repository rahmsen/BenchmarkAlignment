#!/usr/bin/R

# Gene names 

suppressPackageStartupMessages(library(dplyr))

args <- commandArgs(trailingOnly=TRUE)

file_path_in <- args[1]
file_path_out <- args[2]
tool_name <- args[3]
organism <- args[4]

cat("Adjusting gene names\n")
if (organism=="mouse"){
  gene_names <- read.delim("/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/gene_name_mouse.txt", header = F,colClasses = c(rep("character",2)))
} else if (organism=="human"){
  gene_names <- read.delim("/media/Helios_scStorage/Ralf/Benchmark/DavidRuns/all_genes_human.tsv", header = F,colClasses = c(rep("character",4)))
} else {stop("Please report organism: human or mouse")
  }
genes_kallisto <- read.delim(file_path_in, header = F, stringsAsFactors = F)
merged_kallisto <- inner_join(genes_kallisto[1], gene_names, by = c("V1"="V1"))
if (tool_name=="alevin"){
    write.table(merged_kallisto[3], file_path_out, quote = F, row.names =  F, col.names = F, sep="\t")
	}else{
   write.table(merged_kallisto, file_path_out, quote = F, row.names =  F, col.names = F, sep="\t")
	}

