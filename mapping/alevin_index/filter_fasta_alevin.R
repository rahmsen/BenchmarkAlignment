
args <- commandArgs(trailingOnly=TRUE)

if (length(args)==0){
  stop("Please provide a path to the directory of the output data.")
}

organism <- args[1]


if (!require(seqinr)) {
  install.packages("seqinr", dependencies = TRUE)
  library(seqinr)
}

if (organism == "human"){
    transcriptome.fa <- read.fasta("../Homo_sapiens.GRCh38.cdna_ncrna.fa", seqtype = "DNA")
} else if (organism == "mouse"){
	transcriptome.fa <- read.fasta("../Mus_musculus.GRCm38.cdna_ncrna.fa", seqtype = "DNA")
}

transcript.names <- read.table("transcript_names_gtf_filtered.txt")
filtered_transcriptome <- transcriptome.fa[names(transcriptome.fa) %in% transcript.names$V1]

if (organism == "human"){
    write.fasta(filtered_transcriptome, names = names(filtered_transcriptome), "../Homo_sapiens.GRCh38.cdna_ncrna_filtered.fa")
} else if (organism == "mouse"){
	write.fasta(filtered_transcriptome, names = names(filtered_transcriptome), "../Mus_musculus.GRCm38.cdna_ncrna_filtered.fa")
}
