version 1.0

workflow publicTreeSamplePlacement {
    input {
        File user_fasta_seqs
        Int treesize = 500
    }

    parameter_meta {}
    call getFiles {}
    call alignSeqs {
        input :
            sequences = user_fasta_seqs,
            ref_fasta = getFiles.ref_fasta
    }
    call createVcf {
        input :
            aligned_sequences = alignSeqs.aligned_sequences,
            problem_vcf = getFiles.problem_vcf
    }
    call usher {
        input :
            user_vcf = createVcf.user_vcf,
            protobuf = getFiles.protobuf
    }
    call translate {
        input :
            #gtf = getFiles.gtf,
            user_tree = usher.new_tree
            #ref_fasta = getFiles.ref_fasta
    }
    call getSampleIds {
        input :
            user_fasta_seqs = user_fasta_seqs
    }
    call extractSubtrees {
        input :
            metadata = getFiles.metadata,
            user_tree = usher.new_tree,
            translation_table = translate.translation_table,
            user_samples = getSampleIds.user_samples, 
            treesize = treesize
    }
    call taxodium {
        input :
            user_tree = usher.new_tree,
            #gtf = getFiles.gtf,
            #ref_fasta = getFiles.ref_fasta,
            metadata = getFiles.metadata
    }
    output {
        File integrated_tree = usher.new_tree
        File taxodium_file = taxodium.taxodium_file
        File translation_table = translate.translation_table
        File subtree_table = extractSubtrees.out_tsv
    }

    meta {
        author: "Marc Perry"
        email: "madperry@ucsc.edu"
        description: "Uses tools in the UShER tree builder to place user consensus fasta sequence files onto a SARS-CoV-2 phylogenetic tree built from publicly accessible databases"
    }
}

# IDEA: Let's make one task, that grabs all of the files that we need?
task getFiles {
    meta { 
        description: "These five files are required for UShER.  One of them is static, two of them are more stable, and two of them change every night."
    }
    command {
        # Download the SARS-CoV-2 Reference Sequence fasta file
        wget -O wuhCor1.fa.gz "https://hgdownload.soe.ucsc.edu/goldenPath/wuhCor1/bigZips/wuhCor1.fa.gz"
        gunzip wuhCor1.fa.gz
        
        # Download the masking VCF file 
        wget -O problematic_sites_sarsCov2.vcf "https://raw.githubusercontent.com/W-L/ProblematicSites_SARS-CoV2/master/problematic_sites_sarsCov2.vcf"

        # Download the Public Tree protobuf file
        wget -O public-latest.all.masked.pb.gz "http://hgdownload.soe.ucsc.edu/goldenPath/wuhCor1/UShER_SARS-CoV-2/public-latest.all.masked.pb.gz"
        gunzip public-latest.all.masked.pb.gz 

        # Download the metadata for the Public Tree
        wget -O public-latest.metadata.tsv.gz "http://hgdownload.soe.ucsc.edu/goldenPath/wuhCor1/UShER_SARS-CoV-2/public-latest.metadata.tsv.gz"
        gunzip public-latest.metadata.tsv.gz 

        # Download the gtf file
        wget -O ncbiGenes.gtf.gz "http://hgdownload.soe.ucsc.edu/goldenPath/wuhCor1/bigZips/genes/ncbiGenes.gtf.gz"
        gunzip ncbiGenes.gtf.gz 
    }
    runtime {
        docker: "yatisht/usher:latest"        
    }
    output {
        File ref_fasta = "wuhCor1.fa"
        File problem_vcf = "problematic_sites_sarsCov2.vcf"
        File protobuf = "public-latest.all.masked.pb"
        File metadata = "public-latest.metadata.tsv"
        File gtf = "ncbiGenes.gtf"
    }
}

task alignSeqs {
    meta {
        description: "Align multiple sequences from FASTA. Only appropriate for closely related (within 99% nucleotide conservation) genomes. See https://mafft.cbrc.jp/alignment/software/closelyrelatedviralgenomes.html"
    }
    input {
        File   sequences
        File   ref_fasta
        String docker = "quay.io/broadinstitute/viral-phylo:2.1.19.1"
        Int    mem_size = 500
        Int    cpus = 64
    }
    command <<<
        set -e

        mafft --auto --thread ~{cpus} --keeplength --addfragments ~{sequences} ~{ref_fasta} > aligned.fasta
    >>>
    runtime {
        docker:      docker
        memory:      mem_size + " GB"
        cpu:         cpus
        disks:       "local-disk 750 LOCAL"
        preemptible: 0 # what is this? should I add this to all of my runtimes?
    }
    output {
        File aligned_sequences = "aligned.fasta"
    }
}

task createVcf {
    input {
        File aligned_sequences
        File problem_vcf
        Int  num_threads = 16
        Int  mem_size = 500
        Int  diskSizeGB = 30
    }
    command <<<
         faToVcf -maskSites=~{problem_vcf} ~{aligned_sequences} "aligned_seqs.vcf"
    >>>
    output {
         File user_vcf = "aligned_seqs.vcf"
    }
    runtime {
        docker: "yatisht/usher:latest"
        cpu:    num_threads
        memory: mem_size +" GB"
        disks:  "local-disk " + diskSizeGB + " SSD"
    }
}

task usher {
    input {
        File user_vcf
        File protobuf
        Int  threads = 64
        Int  mem_size = 160
        Int  diskSizeGB = 10
    }
    command <<<
        usher -T ~{threads} -i ~{protobuf} -v ~{user_vcf} -o user_seqs.pb > usher
    >>>
    output {
        File new_tree = "user_seqs.pb"
        # File idunno "final-tree.nh"
        # File idunno_2 "mutation-paths.txt"
    }
    runtime { 
        docker: "yatisht/usher:latest" 
        cpu:    threads
        memory: mem_size +" GB"
        disks:  "local-disk " + diskSizeGB + " SSD"
    }     
}

task translate {
    input {
        # File gtf 
        File user_tree 
        # File ref_fasta    
        Int  threads = 64
        Int  mem_size = 160
        Int  diskSizeGB = 10
    }
    command <<<
        wget -O wuhCor1.fa.gz "https://hgdownload.soe.ucsc.edu/goldenPath/wuhCor1/bigZips/wuhCor1.fa.gz"
        gunzip wuhCor1.fa.gz
        wget -O ncbiGenes.gtf.gz "http://hgdownload.soe.ucsc.edu/goldenPath/wuhCor1/bigZips/genes/ncbiGenes.gtf.gz"
        gunzip ncbiGenes.gtf.gz 
        matUtils summary --translate user_seqs.translation.tsv -i ~{user_tree} -g "ncbiGenes.gtf" -f "wuhCor1.fa" > translate
    >>>
    output {
        File translation_table = "user_seqs.translation.tsv"
    }
    runtime {
        docker: "yatisht/usher:latest"
        cpu:    threads
        memory: mem_size +" GB"
        disks:  "local-disk " + diskSizeGB + " SSD"
    }   

}

task getSampleIds {
    input {
        File user_fasta_seqs
    }
    command <<<
        grep -e '>' ~{user_fasta_seqs} | perl -pi -e 's/>//' > "user_samples.txt"
    >>>
    output {
        File user_samples = "user_samples.txt"
    }
    runtime {
        docker: "yatisht/usher:latest"        
    }
}

task extractSubtrees {
    input {
        File user_tree
        File metadata
        File user_samples
        File translation_table 
        Int  treesize
        Int  threads = 64
        Int  mem_size = 160
        Int  diskSizeGB = 10
    }
    command <<<
        matUtils extract -T ~{threads} -i ~{user_tree} -M ~{metadata},~{translation_table} -s ~{user_samples} -N ~{treesize} -j "user" > matUtils
    >>>
    output {
        File out_tsv = "subtree-assignments.tsv"
        Array[File] subtree_jsons = glob("*subtree*")
    }
    runtime {
        docker: "yatisht/usher:latest"
        cpu:    threads
        memory: mem_size +" GB"
        disks:  "local-disk " + diskSizeGB + " SSD"
    }   
}

task taxodium {
    input {
        File user_tree
        # File gtf
        # File ref_fasta
        File metadata
        Int  threads = 64
        Int  mem_size = 160
        Int  diskSizeGB = 10
    }        
    command <<<
         wget -O wuhCor1.fa.gz "https://hgdownload.soe.ucsc.edu/goldenPath/wuhCor1/bigZips/wuhCor1.fa.gz"
         gunzip wuhCor1.fa.gz
         wget -O ncbiGenes.gtf.gz "http://hgdownload.soe.ucsc.edu/goldenPath/wuhCor1/bigZips/genes/ncbiGenes.gtf.gz"
         gunzip ncbiGenes.gtf.gz 
         matUtils extract -i ~{user_tree} -T ~{threads} -l user_seqs.taxodium.pb -g "ncbiGenes.gtf" -f "wuhCor1.fa" -M ~{metadata} > taxodium
    >>>
    output {
        File taxodium_file = "user_seqs.taxodium.pb"
    }        
    runtime {
        docker: "yatisht/usher:latest"
        cpu:    threads
        memory: mem_size +" GB"
        disks:  "local-disk " + diskSizeGB + " SSD"
    }   
}



