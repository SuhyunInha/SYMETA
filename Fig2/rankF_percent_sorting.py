import pandas as pd

# Load the percent abundance table
df = pd.read_csv("rankF_percent.tsv", sep='\t', dtype={'TaxID': str})

# Filter only entries at the 'Family' rank
family_df = df[df['Rank'] == 'F'].copy()

# Identify sample columns (exclude metadata)
metadata_cols = [
    'TaxID', 'Taxon', 'Rank', 'Unclassified', 'Root', 'Domain',
    'Phylum', 'Class', 'Order', 'Family'
]
sample_cols = [col for col in family_df.columns if col not in metadata_cols]

# Calculate mean abundance across all samples
family_df['Mean'] = family_df[sample_cols].mean(axis=1)

# Sort families by mean abundance in descending order
sorted_df = family_df.sort_values('Mean', ascending=False)
sorted_df.to_csv("rankF_percent_sorted.tsv", sep='\t', index=False)
print("rankF_percent_sorted.tsv generated.")

# Select top 30 families and clean up for final table
top30 = sorted_df.nlargest(30, 'Mean').copy()
top30_table = top30[['Phylum', 'Class', 'Order', 'Family'] + sample_cols]
top30_table = top30_table.sort_values(by=['Phylum', 'Class', 'Order', 'Family'])
top30_table.to_csv("rankF_percent_top30.tsv", sep='\t', index=False)
print("rankF_percent_top30.tsv generated.")
