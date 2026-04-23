#SRR number for the reads you want to download and analyse
SRR = SRR21835896

#Sample name. Default is the same as the SRR number, but you can change this to something more human-readable if you like.
READABLE_SAMPLE_NAME = $(SRR)

#number of reads for single reads and number of paired reads if paired.
N_READS = 10000

usage:
	@echo "fastq.mk: Makefile to download fastq files from the SRA."
	@echo "#"
	@echo "arguments:"
	@echo "SRR: The SRR accession number for the reads you want to download. Default is $(SRR)."
	@echo "READABLE_SAMPLE_NAME: The human-readable name for the sample. Default is $(SRR)."
	@echo "N_READS: The number of reads to download. Default is $(N_READS)."
	@echo "#"
	@echo "targets:"
	@echo "get_fastq: Downloads the fastq files for the specified SRR accession number and number of reads."
	@echo "#"

get_fastq:
	@echo "Downloading fastq files..."
	mkdir -p $(READABLE_SAMPLE_NAME).reads
	fastq-dump -X $(N_READS) -F --outdir $(READABLE_SAMPLE_NAME).reads --split-files $(SRR)

	# rename files to use sample name instead of SRR
	mv $(READABLE_SAMPLE_NAME).reads/$(SRR)_1.fastq $(READABLE_SAMPLE_NAME).reads/$(READABLE_SAMPLE_NAME)_1.fastq || true
	mv $(READABLE_SAMPLE_NAME).reads/$(SRR)_2.fastq $(READABLE_SAMPLE_NAME).reads/$(READABLE_SAMPLE_NAME)_2.fastq || true

	@echo "Fastq files downloaded to $(READABLE_SAMPLE_NAME).reads directory."

#The || true business above basically says "if the command on the left fails, run the command on the right". true is an empty command that always gives a successful exit code or something.

fastqc:
	@echo "Running FastQC for $(READABLE_SAMPLE_NAME)..."
	mkdir -p $(READABLE_SAMPLE_NAME).fastqc
	fastqc -o $(READABLE_SAMPLE_NAME).fastqc $(READABLE_SAMPLE_NAME).reads/*.fastq
	@echo "FastQC complete. Results saved in $(READABLE_SAMPLE_NAME).fastqc directory."

clean:
	@echo "Cleaning up downloaded fastq files..."
	rm -r $(READABLE_SAMPLE_NAME).reads
	rm -r $(READABLE_SAMPLE_NAME).fastqc
	@echo "Clean up complete."