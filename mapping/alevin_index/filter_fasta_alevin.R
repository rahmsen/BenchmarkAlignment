
if (!require(seqinr)) {
  install.packages("seqinr", dependencies = TRUE)
  library(seqinr)
}

transcriptome.fa <- read.fasta("../Homo_sapiens.GRCh38.cdna_ncrna.fa",seqtype = "DNA")
transcript.names <- read.table("transcript_names_gtf_filtered.txt")
filtered_transcriptome <- transcriptome.fa[names(transcriptome.fa) %in% transcript.names$V1]
write.fasta(filtered_transcriptome, names = names(filtered_transcriptome), "../Homo_sapiens.GRCh38.cdna_ncrna_filtered.fa")