# usher-public-workflow
A Dockstore WDL Workflow that uses UShER to place your consensus.fasta sequences on the SARS-CoV-2 phylogeny

## Introduction
[UShER](https://github.com/yatisht/usher) (Ultrafast Sample Placement on Existing Trees) uses maximum parsimony to rapidly place new samples onto an existing phylogenetic tree (1).  We have built a workflow that lets Public Health Labs with SARS-CoV-2 consensus fasta sequence files easily identify the most similar viral genomic sequences in public databases.  This has potential applications for not only outbreak investigations, but also genomic surveillance.  By modifying the input files, the same approach could be easily applied to monitor other pathogens.

## Required Data File

## How-to Run the Workflow

## Output Data Files

## Workflow Details
### Sequence of steps in this Workflow
#### Pass in name and path to fasta sequence file
#### Get publicly available sequence files
#### Align user fasta sequences with SARS-CoV-2 RefSeq
#### Create a VCF file of all the variants from the aligned user sequences
#### Place user sequences on the Phylogenetic Tree built from public sequence databases
#### Annotate the resulting amino acid changes from each variant
#### Create a list of sample IDs from the user sequences
#### Extract a subtree for each sample from the new cumulative Phylogenetic Tree for visualization on Nextstrain/auspice
#### Reformat the new Phylogenetic tree for visualization on Taxodium/Cov2tree




(1) [Ultrafast Sample placement on Existing tRees (UShER) enables real-time phylogenetics for the SARS-CoV-2 pandemic](https://www.nature.com/articles/s41588-021-00862-7)
