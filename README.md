# usher-public-workflow
A Dockstore WDL Workflow that uses UShER to place your consensus.fasta sequences on the SARS-CoV-2 phylogeny

## Introduction
[UShER](https://github.com/yatisht/usher) (Ultrafast Sample Placement on Existing Trees) uses maximum parsimony to rapidly place new samples onto an existing phylogenetic tree (1).  We built this UShER workflow so that Public Health Labs with SARS-CoV-2 consensus fasta sequences can more easily identify the most similar viral genomes available in public databases.  The output files could potentially be used to faciliate not only outbreak investigations, but also genomic surveillance.  By modifying the input files, the same approach could be easily applied to monitor other pathogens.
## Required Data File
You must have already aligned the fastq file reads to create a bam file for each sample, and then used that bam file to create a so-called "consensus fasta" file for each sample (e.g. using IVAR, freebayes, etc.).  Concatenate these fasta files into a single fasta file, and make sure that each sequence has has a unique fasta header.  During the Workflow run the text from those header rows gets used to create corresponding Sample IDs.
## How-to Run the Workflow
There are four suggested ways to run the publicTreeSamplePlacement workflow.  In order of increasing complexity:
### 1. Use the Dockstore Workflow to create a new Workflow on Terra
### 2. Use the WDL file to create a new Workflow on Terra
### 3. Use Cromwell to run the WDL file on your localhost or an HPC cluster
  #### A. Use a JSON file to specify the input parameters
  #### B. Use a text editor to modify the WDL file directly to specify the input parameters
## Trouble-shooting
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
