#Makefile for the week 9 assignent.

#Copied from week 8.

# =====================
# User-provided inputs
# =====================

SRR = 
SAMPLE =
#number of reads for single reads and number of paired reads if paired.
N_READS = 10000
#this will run quickly, but the coverage will be poor.

# Reference (should be prepared outside this Makefile)
GCF = GCF_000013465.1
REFERENCE_GENOME_READABLE_NAME = $(GCF)

# =====================
# Usage
# =====================

usage:
	@echo "Makefile for week 9 assignment: variant calling and VCF analysis."
	@echo "#"
	@echo "Variables to set:"
	@echo "SRR: The SRR accession number for the sample you want to process"
	@echo "SAMPLE: A human-readable name for the sample. Default is the same as SRR."
	@echo "N_READS: The number of reads to process. Default is $(N_READS)."
	@echo "GCF: The GCF accession number for the reference genome. Default is $(GCF)."
	@echo "REFERENCE_GENOME_READABLE_NAME: Optionally provide a more human-readable name for the reference genome. Defaults to GCF."
	@echo "#"
	@echo "Targets:"
	@echo "get_and_index_reference_genome: Download, unzip, and index the reference genome with both bowtie2 and samtools."
	@echo "alignments_and_variants_workflow_for_one_sample: Run the full workflow for one sample, from downloading fastq files to calling variants and indexing the VCF file."
	@echo "alignments_and_variants_workflow_for_samples_named_in_csv: Run the full workflow for all samples named in design.csv."
	@echo "merge_vcfs: Merge VCF files made earlier."
	@echo "annotate_multisample_vcf_with_snpeff: Annotate a multisample VCF file with snpEff using a custom database built from the reference genome and gff3 files."
	@echo "#"

get_and_index_reference_genome:
	make -f cams_first_toolbox/reference_genome.mk download_and_unzip \
		GCF=$(GCF) \
		REFERENCE_GENOME_READABLE_NAME=$(REFERENCE_GENOME_READABLE_NAME)
	make -f cams_first_toolbox/reference_genome.mk bowtie2_index \
		REFERENCE_GENOME_READABLE_NAME=$(REFERENCE_GENOME_READABLE_NAME)
	make -f cams_first_toolbox/reference_genome.mk samtools_index_fai \
		REFERENCE_GENOME_READABLE_NAME=$(REFERENCE_GENOME_READABLE_NAME)

alignments_and_variants_workflow_for_one_sample:
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

run_alignments_and_variants_workflow_for_samples_named_in_csv:
	@echo "Running workflow for samples named in design.csv..."	
	tail -n +2 design.csv | parallel --colsep ',' 'make alignments_and_variants_workflow_for_one_sample SRR={1} SAMPLE={2} REFERENCE_GENOME_READABLE_NAME=$(REFERENCE_GENOME_READABLE_NAME)'

merge_vcfs:
	make -f cams_first_toolbox/variant_calling.mk merge_vcfs

annotate_multisample_vcf_with_snpeff:
	make -f cams_first_toolbox/snpeff.mk prepare_reference_genome_for_snpeff REFERENCE_GENOME_READABLE_NAME=$(REFERENCE_GENOME_READABLE_NAME)
	make -f cams_first_toolbox/snpeff.mk prepare_gff3_for_snpeff REFERENCE_GENOME_READABLE_NAME=$(REFERENCE_GENOME_READABLE_NAME)
	make -f cams_first_toolbox/snpeff.mk build_snpeff_custom_database REFERENCE_GENOME_READABLE_NAME=$(REFERENCE_GENOME_READABLE_NAME)
	make -f cams_first_toolbox/snpeff.mk annotate_multisample_vcf_with_snpeff REFERENCE_GENOME_READABLE_NAME=$(REFERENCE_GENOME_READABLE_NAME)