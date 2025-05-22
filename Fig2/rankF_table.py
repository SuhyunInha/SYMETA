import pandas as pd

# Load combined abundance file
df = pd.read_csv("combined_rankF.tsv", sep='\t', dtype={'TaxID': str})

# Extract unique taxonomic lineage info
tax_df = df[['TaxID', 'Rank', 'Taxon']].drop_duplicates().copy()
tax_df['clean_taxon'] = tax_df['Taxon'].str.strip()

# Define rank order (up to Family)
rank_order = ['U', 'R', 'D', 'P', 'C', 'O', 'F']
rank_to_level = {r: i for i, r in enumerate(rank_order)}
level_to_name = ['Unclassified', 'Root', 'Domain', 'Phylum', 'Class', 'Order', 'Family']

# Initialize lineage structure
curr_lineage = {lvl: "" for lvl in level_to_name}
lineage_cols = {lvl: [] for lvl in level_to_name}
taxid_list = []
seen_taxids = set()

# Build lineage table
for _, row in tax_df.iterrows():
    taxid = row['TaxID']
    rank = row['Rank']
    taxon = row['clean_taxon']

    if taxid in seen_taxids or rank not in rank_to_level:
        continue

    seen_taxids.add(taxid)
    level = rank_to_level[rank]

    if rank == 'U':
        lineage_snapshot = {lvl: "" for lvl in level_to_name}
        lineage_snapshot['Unclassified'] = taxon
        for lvl in level_to_name:
            lineage_cols[lvl].append(lineage_snapshot[lvl])
        taxid_list.append(taxid)
        continue

    for i in range(level + 1, len(level_to_name)):
        curr_lineage[level_to_name[i]] = ""

    curr_lineage[level_to_name[level]] = taxon
    for lvl in level_to_name:
        lineage_cols[lvl].append(curr_lineage[lvl])
    taxid_list.append(taxid)

lineage_df = pd.concat(
    [pd.DataFrame({'TaxID': taxid_list}), pd.DataFrame(lineage_cols)],
    axis=1
)

# Add Taxon and Rank columns
tax_info = df[['TaxID', 'Taxon', 'Rank']].drop_duplicates(subset=['TaxID'])
lineage_with_info = lineage_df.merge(tax_info, on='TaxID', how='left')

# Create percent abundance table
abund_df = df[['Sample', 'TaxID', 'Percent']].copy()
abund_df['Percent'] = abund_df['Percent'].astype(float)
pivot_pct = (
    abund_df
    .pivot_table(index='TaxID', columns='Sample', values='Percent', aggfunc='sum', fill_value=0)
    .reset_index()
)
sample_cols_pct = sorted(c for c in pivot_pct.columns if c != 'TaxID')
lineage_cols = [c for c in lineage_df.columns if c != 'TaxID']
cols_pct = ['TaxID', 'Taxon', 'Rank'] + lineage_cols + sample_cols_pct
final_pct_df = lineage_with_info.merge(pivot_pct, on='TaxID', how='left').fillna(0)[cols_pct]
final_pct_df.to_csv("rankF_percent.tsv", sep='\t', index=False)

# Create read count table
reads_df = df[['Sample', 'TaxID', 'Reads']].copy()
reads_df['Reads'] = reads_df['Reads'].astype(int)
reads_sum = reads_df.groupby(['TaxID', 'Sample'], as_index=False)['Reads'].sum()
pivot_reads = (
    reads_sum
    .pivot(index='TaxID', columns='Sample', values='Reads')
    .fillna(0)
    .reset_index()
)
sample_cols_reads = sorted(c for c in pivot_reads.columns if c != 'TaxID')
cols_reads = ['TaxID', 'Taxon', 'Rank'] + lineage_cols + sample_cols_reads
final_reads_df = lineage_with_info.merge(pivot_reads, on='TaxID', how='left').fillna(0)[cols_reads]
final_reads_df.to_csv("rankF_read.tsv", sep='\t', index=False)

print("rankF_percent.tsv and rankF_read.tsv generated successfully.")
