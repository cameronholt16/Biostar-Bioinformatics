# GCF Reference genome (I think GCF is kind of the level above NC, but is effectively the same for this single chromosome organism)
GCF = GCF_000013465.1

#path to fasta and gff3 files
PATH_TO_FASTA = ncbi_dataset/data/$(GCF)

#SRR (determined with bio search PRJNA887926 | grep "SRR")
SRR = SRR21835896
#Probably has to point to a paired reads file, but I haven't tested it.

#number of reads for single reads and number of paired reads if paired.
N_READS = 150000

download_and_unzip:
	@echo "Downloading genome..."
	datasets download genome accession $(GCF) --include gff3,genome
	@echo "Unzipping dataset..."
	unzip -n ncbi_dataset.zip

summarise_fasta_and_gff3:
	@echo "Summarising fasta files..."
	seqkit stats $(PATH_TO_FASTA)/*genomic.fna
	@echo "Summarising gff3 files..."
	@echo "What features are present in the gff3 file?"
	grep -v "^#" $(PATH_TO_FASTA)/*genomic.gff | cut -f3 | sort-uniq-count-rank
	@echo "What's the biggest gene and its end index?"
	grep -v "^#" $(PATH_TO_FASTA)/*genomic.gff | awk '$3=="gene" {print $9, $5-$4, $5}' | sort -k2 -nr | head -n1
	@echo "Let's have a look at another random gene"
	grep "hysA" $(PATH_TO_FASTA)/*genomic.gff

get_fastq:
	@echo "Downloading fastq files..."
	mkdir -p $(SRR).reads
	fastq-dump -X $(N_READS) -F --outdir $(SRR).reads --split-files $(SRR)

#needs updating for potential single reads
Analyse_fastq:
	@echo "What does a FASTQ file look like?"
	cat $(SRR).reads/$(SRR)_1.fastq | head -n8
	@echo "What's the big picture these fastq files?"
	seqkit stats $(SRR).reads/*.fastq
	@echo "What's the quality of these fastq files?"
	fastqc $(SRR).reads/*.fastq
	@echo "Let's look at the results!"
	-cd $(SRR).reads && explorer.exe $(SRR)_1_fastqc.html
	-cd $(SRR).reads && explorer.exe $(SRR)_2_fastqc.html

#Reference genome indexing for read mapping
REF = $(PATH_TO_FASTA)/*genomic.fna

#Reads
R1 = $(SRR).reads/$(SRR)_1.fastq
R2 = $(SRR).reads/$(SRR)_2.fastq

#SAM output file
SAM = $(SRR).aligned_reads.sam

#BAM output file
BAM = $(SRR).aligned_reads.bam

index:
	@echo "Indexing the genome..."
	bowtie2-build $(REF) $(GCF)_index
	@echo "Indexing complete. Index files generated with prefix: $(GCF)_index"

align:
	@echo "Aligning reads..."
	if [ -f $(SRR).reads/$(SRR)_2.fastq ]; then \
		echo "Detected paired-end reads"; \
		READ_ARGS="-1 $(SRR).reads/$(SRR)_1.fastq -2 $(SRR).reads/$(SRR)_2.fastq"; \
	elif [ -f $(SRR).reads/$(SRR)_1.fastq ]; then \
		echo "Detected single-end reads"; \
		READ_ARGS="-U $(SRR).reads/$(SRR)_1.fastq"; \
	else \
		echo "Could not determine read layout"; \
		exit 1; \
	fi; \
	bowtie2 -x $(GCF)_index $$READ_ARGS > $(SAM)

bam:
	@echo "Converting SAM to BAM and sorting..."
	samtools sort $(SAM) > $(BAM)
	@echo "BAM file generated: $(BAM)"

bam_index:
	@echo "Indexing BAM file..."
	samtools index $(BAM)
	@echo "BAM index generated: $(BAM).bai"

bam_stats:
	@echo "Generating BAM statistics..."
	samtools flagstat $(BAM)
	# calculate average coverage across the whole genome
	samtools depth -a $(BAM) | awk '{sum+=$$3} END {print "Average coverage: ", sum/NR}'

# Temporary bedgraph file
BG = $(SRR).coverage.bedgraph

#temporary bigwig file
BW = $(SRR).coverage.bw

#Apparently I need to index the reference genome in yet another way for bedtools to work, so I need to generate a .fai file
fai:
	@echo "Indexing reference genome for bedtools..."
	samtools faidx $(REF)
	@echo "Reference genome indexed for bedtools: $(REF).fai"
	

bedgraph:
	@echo "Generating bedgraph file..."
	LC_ALL=C; bedtools genomecov -ibam  ${BAM} -split -bg | \
    sort -k1,1 -k2,2n > ${BG}
	@echo "Bedgraph file generated: $(SRR).coverage.bedgraph"

bedgraph_to_bigwig:
	@echo "Converting bedgraph to bigwig..."
	bedGraphToBigWig ${BG} ${REF}.fai ${BW}
	@echo "BigWig file generated: $(SRR).coverage.bw"