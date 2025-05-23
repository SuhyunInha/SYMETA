# Fig2: Taxonomic Composition Bubble Plot
This directory contains all scripts and data files used to generate Figure 2 in the manuscript:
"Microbial metagenomes from Lake Soyang, the largest freshwater reservoir in South Korea" (under review at Scientific Data)

## Overview
The figure illustrates the family-level taxonomic composition of metagenomic reads from 28 samples using a bubble plot.
The plot was generated from Kraken2 classification outputs through the following workflow:
- Filtering of Kraken2 classifications to retain taxa at the family level or above
- Construction of lineage-resolved abundance tables
- Selection of the top 30 most abundant families
- Visualization in R

## Directory Contents
- Files for Figure Generation

| File name               | Description                                           |
|-------------------------|-------------------------------------------------------|
| `Kraken2_bubble.R`        | R script to generate the bubble plot (Figure 2)     |
| `rankF_percent_top30.tsv` | Input abundance table by the R script   |
| `taxonomy_bubble.pdf`     | Output plot by the R script                 |

- Processing Scripts and Intermediate Data
  
| File                          | Description                                     |
|-------------------------------|-------------------------------------------------|
| `report_to_combined_rankF.sh` | Extracts entries from Kraken2 report files and merges into a single file     |
| `combined_rankF.tsv`          | Output of `report_to_combined_rankF.sh`             |
| `rankF_table.py`              | Generates abundance matrices                         |
| `rankF_percent_sorting.py`    | Sorts and filters the top 30 abundant families   |


## Workflow: From Kraken2 reports to `rankF_percent_top30.tsv`
The input file for the R script was generated through the following bioinformatics steps, starting from 28 individual Kraken2 `.report` files

### 1. Merge Kraken2 reports (family-level and higher ranks)
Merged 28 Kraken2 `.report` files into a single table, extracting at the family-level and all higher taxonomic ranks.
```bash
report_to_combined_rankF.sh
```
#### Key steps:
- Merge all Kraken2 `.report` files into one combined table
- Extract sample names from filenames
- Format output with: `Sample`, `Taxon`, `Percent`, `Reads`, `Rank`, `TaxID`
- Exclude lower taxonomic ranks (in `Rank`): Genus (`G`), Species (`S`), and Strain (`S1`)

Input: `*.Kraken2.Paired.report`
Output: `combined_rankF.tsv` (included in this directory)

### 2. Generate percent and read count tables
Constructed lineage information by parsing taxonomic ranks for each `TaxID`, and generated abundance tables for each sample.
```python
rankF_table.py
```
#### Key steps:
(The input data is vertically structured by taxonomic hierarchy, i.e., one Rank per row)
- Built a lineage table with one row per `TaxID`, filling in values from `Taxon` into columns added according to the hierarchy order
  - Determined lineage structure by evaluating the `Rank` column in top-down order: U → R → D → P → C → O → F
  - Handled rank discontinuity and repeated ranks by reusing the most recent valid lineage where appropriate
- Once built, sample IDs were appended as columns and each `TaxID`–`Sample` cell was filled with read count (`Reads`) or relative abundance (`Percent`)

Input: `combined_rankF.tsv`
Output: `rankF_percent.tsv`, `rankF_read.tsv`

### 3. Filter and sort top 30 abundant families
Filtered entries to include only those with `Rank = F` (Family), calculated the average relative abundance across samples, and selected the top 30 most abundant families.
```python
rankF_percent_sorting.py
```
#### Key steps:
- Filter for family-level entries (`Rank = F`)
- Calculate the average relative abundance of each family across all samples
- Select top 30 families based on mean abundance
- Remove all other data columns except taxonomy and sample-specific abundance values
- Sort results by taxonomic hierarchy: Phylum → Class → Order → Family

Input: `rankF_percent.tsv`
Output: `rankF_percent_top30.tsv` (included in this directory)
