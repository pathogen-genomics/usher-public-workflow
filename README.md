# usher-public-workflow
A Dockstore WDL Workflow that uses UShER to place your consensus.fasta sequences on the SARS-CoV-2 phylogeny

## Introduction
[UShER](https://github.com/yatisht/usher) (Ultrafast Sample Placement on Existing Trees) uses maximum parsimony to rapidly place new samples onto an existing phylogenetic tree (1).  We built this UShER workflow so that Public Health Labs with SARS-CoV-2 consensus fasta sequences can more easily identify the most similar viral genomes available in public databases.  The output files could potentially be used to facilitate not only outbreak investigations, but also genomic surveillance.  By modifying the input files, the same approach could be easily applied to monitor other pathogens.
## Required Data File
You must have already aligned the fastq file reads to create a bam file for each sample, and then used that bam file to create a so-called "consensus fasta" file for each sample (e.g. using IVAR, freebayes, etc.).  Concatenate these fasta files into a single fasta file, and make sure that each sequence has a unique fasta header.  When this Workflow is running on Terra the text strings in the fasta file header rows is converted into Sample IDs in the output tables and data structures.
## How-to Run the Workflow
There are four suggested ways to run the publicTreeSamplePlacement workflow.  In order of increasing complexity:
### 1. Use the Dockstore Workflow to create a new Workflow on Terra
### 2. Use the WDL file to create a new Workflow on Terra
### 3. Use Cromwell to run the WDL file on your localhost or an HPC cluster
  #### A. Use a JSON file to specify the input parameters
  #### B. Use a text editor to modify the WDL file directly to specify the input parameters
## Trouble-shooting
Depending on the number of samples (sequences) in your input fasta file a run will sometimes fail with an "Out of Memory" error.  In our experience if this happens it is usually during the extractSubtrees task.  In the runtime block of this task, one of the parameters, named 'maxRetries' has been set to '5'.  When you launch the analysis from the Workflow tab in Terra, you have the option of selecting the option to "Retry with more memory", and if you click in this checkbox then Terra will attempt to rerun the workflow using more RAM.
## Output Data Files
In the current configuration, which uses Terra's filepath specification to provide the input parameters, all of your output data files from each WDL task should be located in Terra's Execution Directories (as shown in this example):

![image](https://user-images.githubusercontent.com/1062689/137817380-a209723d-4a2d-403a-be5b-9f6349a2fd08.png)

The new phylogenetic tree, named *'user_seqs.pb'* is located in the Execution Directory of the usher task.  By itself this file, which contains all of your sample sequences placed on the Global SARS-CoV-2 phylogeny, may not seem very useful (the phylogenetic tree it stores is extremely large with over a million sequences).  However, one of the other WDL tasks named 'taxodium' uses the matUtils tools to reformat the user_seqs.pb file into one named *'user_seqs.taxodium.pb'*, which is in the taxodium Execution Directory.  After downloading and saving this file to your localhost you can upload it into the taxonium visualization website located at https://cov2tree.org/. Just click on the 'Choose File' button and it will open a file selector widget and let you upload the new tree containing your sequences placed on the public BigTree.  Taxonium lets you zoom in and zoom out of of locations in the tree, in real time (conceptually similar to the way that Google Maps lets you rapidly zoom in and out).

The UShER output files that often get used the most for visualization are located in the extractSubtrees Execution Directory on Terra.  There is a TSV table, named subtree-assignments.tsv, produced by the matUtils tool, which lists all of your samples and the name of each sample's subtree (containing the 500 nearest neighbours in the larger tree), as well as related metadata.  These subtree.json files are located in a subdirectory whose name begins 'glob-xxxxxx' (as shown in this screenshot from Terra): 

![image](https://user-images.githubusercontent.com/1062689/134108736-366f7a6e-c6ce-45eb-a14b-bed3c7170640.png)

Inside the glob-xxxx directory will be a collection of JSON documents that contain the "sub-trees" with your sample sequences, that have been extracted by matUtils from the user_seqs.pb tree:

![image](https://user-images.githubusercontent.com/1062689/134108483-5cd7f2e7-cbb0-4072-9b24-7e4de106c535.png)

After downloading those JSON renditions of the subtrees extracted from the huge user_seqs.pb tree, you can upload individual examples to Nextstrain's Auspice Tree Viewer, located here: https://auspice.us/  In Auspice there are many different options that you can set that lets you view and label the subtree using different facets, as shown in this example:

![image](https://user-images.githubusercontent.com/1062689/134108100-ccebf065-08ce-4081-a0a1-29700022712c.png)

## Workflow Details
### Sequence of steps in this Workflow
#### Pass in name and path to fasta sequence file
This is the only required file that the user must supply to run the publicTreeSamplePlacement Workflow.  Each sequence must have a unique fasta header preceding it, where the first character on the header line is '>'.  The file can contain from one SARS-CoV-2 consensus fasta sequence, up to thousands of sequences.
#### Get publicly available sequence files
These five files are required by UShER and the other tools for the various steps.  One of them is static, two of them are more stable, and two of them change every night.
#### Align user fasta sequences with SARS-CoV-2 RefSeq
The maftt multiple sequence aligner is used at this step.  It is relatively rapid for such short genomes.  This step makes sure that all of the sequences are the same length as the SARS-CoV-2 RefSeq, in preparation for the next step.
#### Create a VCF file of all the variants from the aligned user sequences
This step uses a program named _faToVcf_ to convert all of your aligned, input fasta sequences into a much more compact, text-based data structure, using the common VCF format 
#### Place user sequences on the Phylogenetic Tree built from public sequence databases
UShER ingests both the VCF file with all of the annotated variants in your sample sequences, and the SARS-CoV-2 phylogenetic tree built using sequences available in public databases.  The resulting user_seqs.pb file contains the information for a Newick tree, that has been converted into Google's protobuf file format.
#### Annotate the resulting amino acid changes from each variant
matUtils integrates annotated genomic features in a GTF file from NCBI, and adds the predicted amino acid changes resulting from the nucleotide sequence variants found in your samples.
#### Create a list of sample IDs from the user sequences
#### Extract a subtree for each sample from the new cumulative Phylogenetic Tree for visualization on Nextstrain/auspice
#### Reformat the new Phylogenetic tree for visualization on Taxodium/Cov2tree




(1) [Ultrafast Sample placement on Existing tRees (UShER) enables real-time phylogenetics for the SARS-CoV-2 pandemic](https://www.nature.com/articles/s41588-021-00862-7)
