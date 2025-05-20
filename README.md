# Microbial metagenomes from Lake Soyang
R scripts and processed data for metagenomic analysis of Lake Soyang samples.

This repository contains R scripts and output files used in the preparation of the manuscript  
"Microbial metagenomes from Lake Soyang, the largest freshwater reservoir in South Korea", currently under review at _Scientific Data_.

## Taxonomic classification of metagenomic reads

This section describes the commands used for:

- Adapter and quality trimming  
- Removal of phiX contamination  
- Taxonomic classification using Kraken2

### 1. Adapter trimming and quality filtering with BBDuk

$ bbduk.sh in1=sample_1.fq.gz in2=sample_2.fq.gz \
out1=sample_trimmed_1.fq.gz out2=sample_trimmed_2.fq.gz \
ref=adapters.fa ktrim=r k=23 mink=11 hdist=1 tpe tbo \
qtrim=rl trimq=10 ftm=5 minlen=100

### 2. Removal of phiX reads

$ bbduk.sh in1=sample_trimmed_1.fq.gz in2=sample_trimmed_2.fq.gz \
out1=sample_clean_1.fq.gz out2=sample_clean_2.fq.gz \
ref=phix174_ill.ref.fa.gz k=31 hdist=1

### 3. Taxonomic classification with Kraken2 (using GTDB R207 via Struo2)

$ kraken2 --db /path/to/struo2_GTDBR207/ \
--paired --gzip-compressed \
--output sample.kraken --report sample.kraken.report \
sample_clean_1.fq.gz sample_clean_2.fq.gz

### 4. Visualization

The R script used to generate bubble plots of taxonomic composition (as shown in the manuscript) is provided in this repository under Fig2/.
All processed output files used for plotting are included in the same repository.
