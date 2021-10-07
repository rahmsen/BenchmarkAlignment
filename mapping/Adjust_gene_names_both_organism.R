#!/usr/bin/R

# Gene names 

suppressPackageStartupMessages(library(dplyr))
# for alevin-fry. load gene count matrix
# from https://combine-lab.github.io/alevin-fry-tutorials/2021/improving-txome-specificity/
load_fry <- function(frydir, which_counts = c('S','A'), verbose = FALSE) {
  suppressPackageStartupMessages(library(rjson))
  suppressPackageStartupMessages(library(Matrix))
  # read in metadata
  meta_info = fromJSON(file = file.path(frydir, "meta_info.json"))
  ng = meta_info$num_genes
  usa_mode = meta_info$usa_mode
  
  if(usa_mode) {
    if (length(which_counts) == 0){
      stop("Please at least provide one status in 'U' 'S' 'A' ")
    }
    if (verbose){
      message("processing input in USA mode, will return ", paste(which_counts, collapse = '+'))
    }
  } else if(verbose) {
    message("processing input in standard mode, will return spliced count")
  }
  
  # read in count matrix
  af_raw = readMM(file = file.path(frydir, "alevin", "quants_mat.mtx"))
  # if usa mode, each gene gets 3 rows, so ng/3
  if(usa_mode) {
    ng = as.integer(ng/3)
  }
  # read in gene name file and cell barcode file
  afg = read.csv(file.path(frydir, "alevin", "quants_mat_cols.txt"), strip.white = TRUE, header = FALSE, nrows = ng, col.names = c("gene_ids"))
  afc = read.csv(file.path(frydir, "alevin", "quants_mat_rows.txt"), strip.white = TRUE,header = FALSE,col.names = c("barcodes"))
  
  # if in usa_mode, sum up counts in different status according to which_counts
  if (usa_mode) {
    rd = list("S" = seq(1, ng), "U" =  seq(ng+1, 2*ng), "A" =  seq(2*ng+1, 3*ng))
    o = af_raw[, rd[[which_counts[1]]]]
    for (wc in which_counts[-1]) {
      o = o + af_raw[, rd[[wc]]]
    }
  } else {
    o = af_raw
  }
  #print(str(o))
  o@Dimnames <- list(afc$barcodes, afg$gene_ids)
  
  return(o)
  
}

args <- commandArgs(trailingOnly=TRUE)

file_path_in <- args[1]
file_path_out <- args[2]
name_file <- args[3]
tool_name <- args[4]
organism <- args[5]


cat("Adjusting gene names\n")

gene_names <- read.delim(name_file, header = T)

genes <- read.delim(file_path_in, header = F)

if (tool_name == "alevin-fry"){
  cat("Load fry data\n")
  suppressPackageStartupMessages(library(DropletUtils))
  
  fry_data <- load_fry(dirname(dirname(file_path_in)))
  
  write10xCounts(dirname(file_path_in), 
                 t(fry_data), 
                 overwrite = T,
                 version = "3")
  
  file_path_out <- paste0(dirname(file_path_in), "/features.tsv.gz")
  genes <- read.table(file_path_out, header = F, stringsAsFactors = F)
}

if (grepl("[.]", genes[1,1])){ # should be alevin and kallisto
  genes <- inner_join(genes[1], gene_names, by = c("V1" = "ID_type"))
}else { #should be only alevin-fry
  genes <- inner_join(genes[1], gene_names, by = c("V1" = "ID"))
}

#   if (grepl("alevin-fry", tool_name, ignore.case = T)){
#     
#   genes <- inner_join(genes[1], gene_names, by = c("V1" = "V2"))
#   }else if(grepl(c("kallisto", "alevin"), tool_name, ignore.case = T))
# }
# if (tool_name == "alevin-fry" & grepl("[.]", gene_names[1,1])){
#   gene_names$V3 <- do.call(rbind, strsplit(gene_names$V1, "[.]"))[,1]
# }
# genes <- inner_join(genes[1], gene_names, by = "V1")
if (tool_name == "alevin-fry"){
  write.table(genes[c("V1", "symbol")], gzfile(file_path_out), quote = F, row.names =  F, col.names = F, sep="\t")
}else if (tool_name == "alevin"){
  write.table(genes[c("symbol")], file_path_out, quote = F, row.names =  F, col.names = F, sep="\t")
}else{
  write.table(genes[c("V1", "symbol")], file_path_out, quote = F, row.names =  F, col.names = F, sep="\t")
}


