# usher-public-workflow
A Dockstore WDL Workflow that uses UShER to place your consensus.fasta sequences on the SARS-CoV-2 phylogeny

## Introduction
[UShER](https://github.com/yatisht/usher) (Ultrafast Sample Placement on Existing Trees) uses maximum parsimony to rapidly place new samples onto an existing phylogenetic tree (1).  We built this UShER workflow so that Public Health Labs with SARS-CoV-2 consensus fasta sequences can more easily identify the most similar viral genomes available in public databases.  The output files could potentially be used to facilitate not only outbreak investigations, but also genomic surveillance.  By modifying the input files, the same approach could be easily applied to monitor other pathogens.
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
Depending on the number of samples (sequences) in your input fasta file a run will sometimes fail with an "Out of Memory" error.  In out experience if this happens it is usually during the extractSubtrees task.  In the runtime block of this task, one of the parameters, named 'maxRetries' has been set to '5'.  When you launch the analysis from the Workflow tab in Terra, you have the option of selecting the option to "Retry with more memory", and if you click in this checkbox then Terra will attempt to rerun the workflow using more RAM.
## Output Data Files
As currently configured, to use the filepath specification to provide the input, all of the output files are located in the Execution Directory of their respective task.  The new phylogenetic tree, named 'user_seqs.pb' is located in the Execution Directory of the usher task.  By itself this file may have limited usefulness.  One of the tasks named 'taxodium' uses the matUtils tools to reformat the user_seqs.pb file into one named 'user_seqs.taxodium.pb', which is in the taxodium Execution Directory.  After downloading and saving this file to your localhost you can upload it into the taxodium visualization website located at https://cov2tree.org/. Just click on the 'Choose File' button and it will open a file selector widget and let you upload the new tree containing your sequences placed on the public BigTree.

The output files that often get used the most are located in the extractSubtrees Execution Directory on Terra.  There is a TSV table, named subtree-assignments.tsv, produced by the matUtils tool which lists your samples and and the name of the extracted subtree which shows it's 500 nearest neighbours, as well as related metadata.  The subtree.json files are located in a subdirectory whose name begins 'glob-xxxxxx'.  

![image](https://user-images.githubusercontent.com/1062689/134108736-366f7a6e-c6ce-45eb-a14b-bed3c7170640.png)

![image](https://user-images.githubusercontent.com/1062689/134108483-5cd7f2e7-cbb0-4072-9b24-7e4de106c535.png)
After downloading those JSON renditions of the subtree you can upload individual examples to Nextstrain's Auspice Tree Viewer, located here: https://auspice.us/  In Auspice there are many different options that you can set that lets you view and label the subtree using different facets, as shown in this example:

![image](https://user-images.githubusercontent.com/1062689/134108100-ccebf065-08ce-4081-a0a1-29700022712c.png)
## Workflow Details
### Sequence of steps in this Workflow
#### Pass in name and path to fasta sequence file
This is the only required file that the user must supply to run the publicTreeSamplePlacement Workflow.  Each sequence must have a unique fasta header preceding it, where the first character on the header line is '>'.  The file can contain one SARS-CoV-2 consensus fasta sequence, up to thousands.
#### Get publicly available sequence files
These five files are required by UShER and the other tools for the various steps.  One of them is static, two of them are more stable, and two of them change every night
#### Align user fasta sequences with SARS-CoV-2 RefSeq
The maftt multiple sequence aligner is used at this step.  It is relatively rapid for such short genomes.  This step makes sure that all of the sequences are the same length as the SARS-CoV-2 RefSeq, in preparation for the next step.
#### Create a VCF file of all the variants from the aligned user sequences
#### Place user sequences on the Phylogenetic Tree built from public sequence databases
#### Annotate the resulting amino acid changes from each variant
#### Create a list of sample IDs from the user sequences
#### Extract a subtree for each sample from the new cumulative Phylogenetic Tree for visualization on Nextstrain/auspice
#### Reformat the new Phylogenetic tree for visualization on Taxodium/Cov2tree




(1) [Ultrafast Sample placement on Existing tRees (UShER) enables real-time phylogenetics for the SARS-CoV-2 pandemic](https://www.nature.com/articles/s41588-021-00862-7)
