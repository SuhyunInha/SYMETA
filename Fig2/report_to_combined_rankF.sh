#!/usr/bin/env bash

# Print initial header with tab separation
printf 'Sample\tTaxon\tPercent\tReads\tRank\tTaxID\n' > combined_rankF.tsv

# Process each Kraken2 report file
for file in *.Kraken2.Paired.report; do
  sample=${file%.Kraken2.Paired.report}
  echo "Processing: $sample"

  awk -v sample="$sample" '
    BEGIN {
      FS = "\t"     # set input field separator to tab
      OFS = "\t"    # set output field separator to tab
    }
    # skip Genus (G), Species (S), and Strain (S1) ranks
    $4 == "G" || $4 == "S" || $4 == "S1" { next }

    {
      # concatenate taxon name from field 6 through the last field
      taxon = $6
      for (i = 7; i <= NF; i++) {
        taxon = taxon OFS $i
      }
      # trim leading/trailing whitespace from the taxon string
      gsub(/^[ \t]+|[ \t]+$/, "", taxon)

      # $1 = percent; $2 = reads in clade; $3 = direct reads
      # use $2 for clade reads (or $3 for direct reads if preferred)
      print sample, taxon, $1, $2, $4, $5
    }
  ' "$file" >> combined_rankF.tsv
done
