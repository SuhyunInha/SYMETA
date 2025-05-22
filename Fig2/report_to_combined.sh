#!/bin/bash

# Initialize output file with header
echo -e "Sample\tTaxon\tPercent\tReads\tRank\tTaxID" > combined_abundance.tsv

# Loop through all Kraken2 report files
for file in *.Kraken2.Paired.report; do
  sample=$(basename "$file" .Kraken2.Paired.report)
  echo "Processing: $sample"

  awk -v sample="$sample" '{
    # Extract taxon name by removing the first 5 fields (numbers and codes)
    taxon=$0;
    sub(/^ *[0-9.]+ +[0-9]+ +[0-9]+ +[A-Z] +[0-9]+ +/, "", taxon);
    gsub(/^\s+|\s+$/, "", taxon);  # Trim leading/trailing whitespace

    # Print formatted line: Sample, Taxon, Percent, Reads, Rank, TaxID
    printf "%s\t%s\t%s\t%s\t%s\t%s\n", sample, taxon, $1, $2, $4, $5
  }' "$file" >> combined_abundance.tsv
done
