# usher-public-workflow
A Dockstore WDL Workflow that uses UShER to place your consensus.fasta sequences on the SARS-CoV-2 phylogeny

## Introduction
[UShER](https://github.com/yatisht/usher) (Ultrafast Sample Placement on Existing Trees) uses maximum parsimony to rapidly place new samples onto an existing phylogenetic tree (1).  We have built a workflow that lets Public Health Labs with SARS-CoV-2 consensus fasta sequence files easily identify the most similar viral genomic sequences in public databases.  This has potential applications for not only outbreak investigations, but also genomic surveillance.  By modifying the input files, the same approach could be easily applied to monitor other pathogens.

## Sequence of steps in this Workflow
### Get publicly available sequence file



(1) [Ultrafast Sample placement on Existing tRees (UShER) enables real-time phylogenetics for the SARS-CoV-2 pandemic](https://www.nature.com/articles/s41588-021-00862-7)
