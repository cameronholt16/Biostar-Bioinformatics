# GCF
GCF = GCF_000013465.1

#path to fasta and gff3 files
PATH_TO_FASTA = ncbi_dataset/data/$(GCF)

#SRR (determined with bio search PRJNA887926 | grep "SRR")
SRR = SRR21835896
#Probably has to point to a paired reads file, but I haven't tested it.

#number of read pairs to download for 10x coverage of the genome
N_READ_PAIRS = 150000

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
	mkdir -p reads
	fastq-dump -X $(N_READ_PAIRS) -F --outdir reads --split-files $(SRR)

Analyse_fastq:
	@echo "What does a FASTQ file look like?"
	cat reads/$(SRR)_1.fastq | head -n8
	@echo "What's the big picture these fastq files?"
	seqkit stats reads/*.fastq
	@echo "What's the quality of these fastq files?"
	fastqc reads/*.fastq
	@echo "Let's look at the results!"
	-cd reads && explorer.exe $(SRR)_1_fastqc.html
	-cd reads && explorer.exe $(SRR)_2_fastqc.html

#Reference genome indexing for read mapping
REF = $(PATH_TO_FASTA)/*genomic.fna

#Reads
R1 = reads/$(SRR)_1.fastq
R2 = reads/$(SRR)_2.fastq

#SAM output file
SAM = aligned_reads.sam

#BAM output file
BAM = aligned_reads.bam

index:
	@echo "Indexing the genome..."
	bowtie2-build $(REF) $(GCF)_index
	@echo "Indexing complete. Index files generated with prefix: $(GCF)_index

align:
	@echo "Aligning reads to the reference genome..." 
	bowtie2 -x $(GCF)_index -1 $(R1) -2 $(R2) > $(SAM)
	@echo "Indexing complete. SAM file generated: $(SAM)"

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