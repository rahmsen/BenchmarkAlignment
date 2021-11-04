#!/usr/bin/R

# This R script filter the raw data from STARsolo and Kallisto and write it to disk for downstream analysis

# Usage: <input_path> <output_path> <mapper> <filter>
# * input_path: where the raw data is located 
# * output_path: where you want to save the data. subfolder will be created that contain the data
# * mapper: either cellranger, starsolo, alevin or kallisto
# * filter: either emptyDrops or knee

args <- commandArgs(trailingOnly=TRUE)

if (length(args)==0){
  stop("Please provide a path to the directory of the output data.")
}

sample_dir_path <- args[1]
out_path <- args[2]
tool <- args[3]
method <- args[4]
threads <- args[5]

# Check if files are present in starsolo output
if (tool %in% c("star_solo", "starsolo")) {
  if (!("genes.tsv" %in% dir(sample_dir_path))){
    file_found <- c("barcodes.tsv.gz","features.tsv.gz", "matrix.mtx.gz") %in% dir(sample_dir_path)
    #print(file_found)
    if (!all(file_found)){
      stop("Could not find compressed files. Please use gzip for compressing data\n")
    }
  }
}

cat("Loading libraries.\n")
suppressPackageStartupMessages(library(DropletUtils))
if (tool == "kallisto"){
  suppressPackageStartupMessages(library(BUSpaRse))
  }else if (tool == "alevin-fry"){
    suppressPackageStartupMessages(library(SingleCellExperiment))
}else{
  suppressPackageStartupMessages(library(Seurat))
}

if (method=="knee"){
  suppressPackageStartupMessages(library(Matrix))
}else{
  suppressPackageStartupMessages(library(BiocParallel))
}

#modify output path
if(tool == "cellranger"){
  out_path <- paste0(out_path,method,"_feature_bc_matrix/")
} else{
  out_path <- paste0(out_path,"filtered_matrix_",method,"/")
}
print(out_path)


## Set up functions ##

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
  
  o@Dimnames <- list(afc$barcodes, afg$gene_ids)
  
  return(o)

}

knee_filter <- function(m_data){
  tot_counts <- Matrix::colSums(m_data)
  bc_rank <- barcodeRanks(m_data)
  data_filtered <- m_data[, tot_counts > metadata(bc_rank)$inflection]
  return(data_filtered)
}

emptydrop_filter <- function(x) {
  set.seed(185463)
  cell_count <- emptyDrops(x[grep("^MT-|^mt-", 
                                  row.names(x), 
                                  invert = T, 
                                  ignore.case = T),], 
                           test.ambient = F, 
                           BPPARAM = MulticoreParam(threads), 
                           niters = 50000)
  
  is.cell <- cell_count$FDR <= 0.01
  is.cell[is.na(is.cell)] <-FALSE
  data_filtered <- x[,is.cell]
  
  table <- table(Sig = is.cell, Limited = cell_count@listData$Limited)
  print(data.frame(table))
  
  return(list(data_filtered, cell_count, table))
}

filter_data <- function(m_data, m_method, m_tool, m_out_path){
  # Filter the data set with the "Knee" method from the DropletUtils package
  if (m_method == "knee"){
    data_filtered <- knee_filter(m_data)
  }
  # Filter the data set with emptyDrops from the DropletUtils package
  if (m_method == "emptyDrops"){

    list_data <- emptydrop_filter(m_data)
    data_filtered <- list_data[[1]]
    cell_count <- list_data[[2]]
    table <- list_data[[3]]  
  }

  cat("Writing filtered data to disk.\n")

  write10xCounts(m_out_path,data_filtered, version = "3")
  

  if (m_method == "emptyDrops"){
    write.table(data.frame(table),paste0(m_out_path,"Result_emptyDrops_table.tsv"),
      sep = "\t",
      quote = F,
      col.names = T)

    write.table(data.frame(knee_point=cell_count@metadata$retain),
      paste0(m_out_path,"Result_emptyDrops_table.tsv"),
      sep = "\t",
      quote = F,
      col.names = T,
      append = T)

    # plot p-values for quality control. Should be uniformly distributed
    pdf(paste0(m_out_path,"hist_pvalues_emptydrop.pdf"))
      hist(cell_count@listData$PValue, 
        breaks = 100, xlab="", 
        main=paste("Distribution of p-values for",m_tool, m_method,"filtering",sep=" "))
    dev.off()
    
    pdf(paste0(m_out_path,"hist_genes_per_cell_emptydrop.pdf"))
      hist(log10(Matrix::colSums(data_filtered)), breaks = 75)
    dev.off()
  }
  cat("Done.\n")
}

## Actual execution ##
cat("Reading data.\n")
if (tool == "kallisto"){
  data <- read_count_output(sample_dir_path, name = "gcm", tcc = F)

}else if(tool %in% c("cellranger", "starsolo", "star_solo")) {
  #print(sample_dir_path)
  data <- Read10X(data.dir = sample_dir_path)

}else if (tool == "alevin-fry") {
  data <- load_fry(sample_dir_path)
  
  }else{
  stop("Could not read data. Please state tool description\n")
}

cat("Filter data.\n")
filter_data(data, method, tool, out_path)

