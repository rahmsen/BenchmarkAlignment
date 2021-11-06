# Read-Me Mapping PBMC

## Download and install mapper

1. Run script install_mapper.sh to download and install each mapper.

 ```{bash}
downloadSoftware.sh -o path/to/main/output/ -g path/to/github/dir/
  ```
2. Download Cell Ranger 6 from the [10x website](https://support.10xgenomics.com/single-cell-gene-expression/software/downloads/6.0) to ../software/cellranger and unpack

## Download reference genome and transcriptome

3. Run script create_index_download_data.sh

 ```{bash}
create_index_download_data.sh -o /path/to/main/output/ -g /path/to/github/dir/ -w /path/to/whitelist/
  ```

## Create index for each tool and download sequence data of PBMC

4. Run script mapping.sh

 ```{bash}
create_index_download_data.sh -o /path/to/main/output/ -g /path/to/github/dir/ -w /path/to/whitelist/
  ```

5. Run commands in R/Rstudio to create alevin-fry index:

 ```{bash}
 main_outpath=/path/to/main/folder/
 github_path=/path/to/github/repo/
 threads=16
 
# Scripts from https://github.com/COMBINE-lab/usefulaf
Rscript --vanilla ${github_path}mapping/create_splici_index.R \
    ${main_outpath}references/human/cellranger/GRCh38_97/ \
    ${main_outpath}references/human/alevin-fry/ \
    ${github_path}mapping/

salmon index \
    -t ${main_outpath}references/alevin-fry/human/filtered/transcriptome_splici_fl86/transcriptome_splici_fl86.fa \
    -i ${main_outpath}references/alevin-fry/human/filtered/grch38_97_bench_splici_idx \
    -p $threads
```
