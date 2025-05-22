# Fig2: Taxonomic Composition Bubble Plot (Family Level)
This directory contains all scripts and data files used to generate Figure 2 in the manuscript:
"Microbial metagenomes from Lake Soyang, the largest freshwater reservoir in South Korea" (under review at Scientific Data)

## Overview
The figure illustrates the family-level taxonomic composition of metagenomic reads from 28 samples using a bubble plot.
The plot was generated from Kraken2 classification outputs through the following workflow:
- Extraction and filtering of family-level taxa
- Construction of lineage-resolved abundance tables
- Selection of the top 30 most abundant families
- Visualization in R

## Directory Contents
- Files for Figure Generation
| File name               | Description                                           |
|-------------------------|-------------------------------------------------------|
| `Kraken2_bubble.R`        | R script to generate the bubble plot (Figure 2)           |
| `rankF_percent_top30.tsv` | Input abundance table by the R script; contains relative abundance data of top 30 families   |
| `taxonomy_bubble.pdf`     | Final output plot in PDF format                 |

- Processing Scripts and Intermediate Data
| File                          | Description                                                                                                                                                      |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `report_to_combined_rankF.sh` | Bash script to extract entries with Rank = F (Family) from Kraken2 `.report` files and merge them into a single file                   |
| `combined_rankF.tsv`          | Merged table of family-level abundance from all Kraken2 report files (output of `report_to_combined_rankF.sh`)                                                   |
| `rankF_table.py`              | Python script to construct lineage tables and generate abundance matrices                                                           |
| `rankF_percent_sorting.py`    | Python script to sort and filter the top 30 families by average abundance  |
| `report_to_combined.sh`       | (Optional) Script that merges Kraken2 reports without filtering by rank; includes all taxonomic levels  |


## Workflow: From Kraken2 reports to `family_top30_selected.tsv`
The input file for the R script (`rankF_percent_top30.tsv`) was generated through the following bioinformatics steps, starting from 28 individual Kraken2 `.report` files (one per sample)

### 1. Merge Kraken2 reports (family-level and higher ranks)
Merged 28 Kraken2 `.report` files into a single table, extracting at the family-level and all higher taxonomic ranks.
```bash
report_to_combined_rankF.sh
```
Key steps:
- Exclude Genus (G), Species (S), and Strain (S1) ranks
- Extract sample names from filenames
- Format output with: Sample, Taxon, Percent, Reads, Rank, TaxID
Input: `*.Kraken2.Paired.report`
Output: `combined_rankF.tsv`

### 2. Generate percent and read count tables
Constructed lineage information by parsing taxonomic ranks for each TaxID, and generated abundance tables for each sample.
```python
rankF_table.py
```
Key steps:
- Track lineage levels from higher (e.g., Domain) to lower (Family) using defined rank order (U → R → D → P → C → O → F)
- Construct hierarchical taxonomic assignments
- Generate per-sample relative abundance and read count tables
Input: `combined_rankF.tsv`
Output: `rankF_percent.tsv`, `rankF_read.tsv`

### 3. Filter and sort top 30 abundant families
Filtered entries to include only those with Rank = F (Family), calculated the average relative abundance across samples, and selected the top 30 most abundant families.
```python
rankF_percent_sorting.py
```
Key steps:
- Filter input to include only family-level (`Rank = F`) taxa
- Calculate average relative abundance across all samples
- Select top 30 families based on mean abundance
- Sort results by taxonomic hierarchy: Phylum → Class → Order → Family
Input: `rankF_percent.tsv`
Output: `rankF_percent_top30.tsv`
