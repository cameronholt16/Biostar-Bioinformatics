# =====================
# User-provided inputs
# =====================

SRR = 
SAMPLE =
#number of reads for single reads and number of paired reads if paired.
N_READS = 10000
#this will run quickly, but the coverage will be poor.

# Reference 
GCF = GCF_000013465.1
REFERENCE_GENOME_READABLE_NAME = MRSA_465

get_and_index_reference_genome:
	make -f cams_first_toolbox/reference_genome.mk download_and_unzip \
		GCF=$(GCF) \
		REFERENCE_GENOME_READABLE_NAME=$(REFERENCE_GENOME_READABLE_NAME)
	make -f cams_first_toolbox/reference_genome.mk bowtie2_index \
		GCF=$(GCF) \
		REFERENCE_GENOME_READABLE_NAME=$(REFERENCE_GENOME_READABLE_NAME)
	make -f cams_first_toolbox/reference_genome.mk samtools_index_fai \
		GCF=$(GCF) \
		REFERENCE_GENOME_READABLE_NAME=$(REFERENCE_GENOME_READABLE_NAME)

# =====================
# One-sample workflow
# =====================

workflow_for_one_sample:
	@echo "=== Processing sample $(SAMPLE) (SRR=$(SRR)) ==="

	# Step 1: get reads
	make -f cams_first_toolbox/reads.mk get_fastq_reads \
		SRR=$(SRR) \
		READABLE_SAMPLE_NAME=$(SAMPLE) \
		N_READS=$(N_READS)

	# Step 2: run FastQC
	make -f cams_first_toolbox/reads.mk fastqc \
		READABLE_SAMPLE_NAME=$(SAMPLE)

	# Step 3: align
	make -f cams_first_toolbox/align_reads.mk align \
		SRR=$(SRR) \
		READABLE_SAMPLE_NAME=$(SAMPLE) \
		REFERENCE_GENOME_READABLE_NAME=$(REFERENCE_GENOME_READABLE_NAME)

	# Step 4: sam to bam
	make -f cams_first_toolbox/align_reads.mk bam \
		READABLE_SAMPLE_NAME=$(SAMPLE)

	# Step 5: bam index
	make -f cams_first_toolbox/align_reads.mk bam_index \
		READABLE_SAMPLE_NAME=$(SAMPLE)

	# Step 6: bam stats
	make -f cams_first_toolbox/align_reads.mk bam_stats \
		READABLE_SAMPLE_NAME=$(SAMPLE)

	# Step 7: bedgraph
	make -f cams_first_toolbox/align_reads.mk bedgraph \
		READABLE_SAMPLE_NAME=$(SAMPLE)

	# Step 8: bedgraph to bigwig
	make -f cams_first_toolbox/align_reads.mk bedgraph_to_bigwig \
		READABLE_SAMPLE_NAME=$(SAMPLE) \
		REFERENCE_GENOME_READABLE_NAME=$(REFERENCE_GENOME_READABLE_NAME)

	#Step 9: call variants
	make -f cams_first_toolbox/variant_calling.mk call_variants \
		SRR=$(SRR) \
		READABLE_SAMPLE_NAME=$(SAMPLE) \
		REFERENCE_GENOME_READABLE_NAME=$(REFERENCE_GENOME_READABLE_NAME)

	#Step 10: index variants
	make -f cams_first_toolbox/variant_calling.mk index_variants \
		READABLE_SAMPLE_NAME=$(SAMPLE) \
		REFERENCE_GENOME_READABLE_NAME=$(REFERENCE_GENOME_READABLE_NAME)

	@echo "=== Finished $(SAMPLE) ==="

run_workflow_for_samples_named_in_csv:
	@echo "Running workflow for samples named in design.csv..."	
	tail -n +2 design.csv | parallel --colsep ',' 'make workflow_for_one_sample SRR={1} SAMPLE={2} REFERENCE_GENOME_READABLE_NAME=$(REFERENCE_GENOME_READABLE_NAME)'