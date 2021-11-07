This respoistory contains scripts for the mapping

A short description of the scripts:

### R language 

* `commands_mapping_AllDataset.txt` — A script with all commands that were used to map all datasets.
* `commands_mapping_PBMC.txt` — The script with only the commands to map the PBMC dataset.
* `create_index_download_data.sh` — A bash script to create the indices for all mapper and download the PBMC dataset. See BenchmarkAlignment/README.md for the correct usage.
* `downloadSoftware.sh` — A bash script that set up the file structure and download and install all necessary mapper. See BenchmarkAlignment/README.md for the correct usage.
* `mapping.sh` — A bash script that does the actual mapping. See BenchmarkAlignment/README.md for the correct usage.

### Tool scripts 
* `MapAlevin-fry.sh`, `MapAlevin.sh`, `MapCellranger6.sh`, `MapKallisto.sh`, `MapSTARsolo.sh` are scripts that are used in `mapping.sh` to execute the mapper

### Alevin index
* `create_splici_index.R`, `make_splici_reference.R` are needed to create the index for Alevin-fry. From [`Alevin-fry usefulaf`](https://github.com/COMBINE-lab/usefulaf)
* `filter_fasta_alevin.R` will be used in `create_index_download_data.sh` to create the Alevin index. It will filter out genes that are not in the gtf annotation file. Otherwise Alevin throws an error of mismatches between the gtf and the fasta file.

### Post mapping
* `Adjust_gene_names_both_organism.R`, `adjust_geneNames.sh` write the gene ID in the barcodes files asocciated with the count matrices.
* `all_genes_mouse.tsv`, `all_genes_human.tsv` contain the gene symbol to gene ID maping to include the gene ID in `Adjust_gene_names_both_organism.R`
* `filter_raw_emptyDrops.R` Will execute the emptyDrops cell filtering for a mapper. For Alevin-fry it will filter for the spliced and ambigouse read counts and write out as mtx-files to be loaded into R in the script `make_figures.rmd`.
