#Makefile for the week 8 assignent. run  (SRR, sample) pair

#Only needs to get fastq and align. Reference genome should be done outside.

#For a given line of the design file, use the SRR to get the fastq
#Use the fastq to align to the reference genome, saving everything according to the corresponding READABLE_SAMPLE_NAME.

#Outside this Makefile, parallel each line of the design file into here.

# =====================
# User-provided inputs
# =====================

#does this blank assignment work, or do I need to learn about ?=
SRR = 
SAMPLE =

# Reference (should be prepared outside this Makefile)
GCF = GCF_000013465.1
REFERENCE_GENOME_READABLE_NAME = MRSA465

# =====================
# One-sample workflow
# =====================

#tell fastq there's a readable name to deal with now.
#put fastqc in here..

workflow_for_one_sample:
	@echo "=== Processing sample $(SAMPLE) (SRR=$(SRR)) ==="

	# Step 1: get FASTQ
	make -f cams_first_toolbox/fastq.mk get_fastq \
		SRR=$(SRR) \
		READABLE_SAMPLE_NAME=$(SAMPLE)

	# Step 2: run FastQC
	make -f cams_first_toolbox/fastq.mk fastqc \
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

	@echo "=== Finished $(SAMPLE) ==="