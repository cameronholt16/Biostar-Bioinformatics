# download, unzip, rename, and index the reference genome with both bowtie2 and samtools

# GCF Reference genome (I think GCF is kind of the level above NC, but is effectively the same for this single chromosome organism)
GCF = GCF_000013465.1

#Give a more readable name if you have one, else just use the GCF.
REFERENCE_GENOME_READABLE_NAME = $(GCF)

#path to fasta and gff3 files
PATH_TO_REFERENCE_GENOME = $(REFERENCE_GENOME_READABLE_NAME)_dataset/ncbi_dataset/data/$(GCF)

#Reference genome fasta file
REFERENCE_GENOME_FASTA = $(PATH_TO_REFERENCE_GENOME)/*genomic.fna

usage:
	@echo "reference_genome.mk: Makefile to download, unzip, and index the reference genome with both bowtie2 and samtools."
	@echo "#"
	@echo "arguments:"
	@echo "GCF: The GCF accession number for the reference genome. Default is $(GCF)."
	@echo "REFERENCE_GENOME_READABLE_NAME: Optionally provide a more human-readable name for the reference genome. Defaults to GCF."
	@echo "#"
	@echo "targets:"
	@echo "download_and_unzip: Downloads the reference genome dataset from NCBI and unzips it."
	@echo "bowtie2_index: Indexes the reference genome using bowtie2."
	@echo "samtools_index_fai: Indexes the reference genome for bedtools using samtools faidx. Produces an .fai file in the same directory as the reference genome."
	@echo "#"
	@echo "Future improvements:"
	@echo "download and unzip creates a seemingly unnecessary tree of directories."
	@echo "I wonder if there's a way to only have to declare REFERENCE_GENOME_READABLE_NAME once. Maybe in the command line?"
	@echo "#"

download_and_unzip:
	@echo "Downloading genome..."
	datasets download genome accession $(GCF) \
		--include gff3,genome \
		--filename $(REFERENCE_GENOME_READABLE_NAME)_dataset.zip
	@echo "Unzipping dataset..."
	unzip -n $(REFERENCE_GENOME_READABLE_NAME)_dataset.zip \
		-d $(REFERENCE_GENOME_READABLE_NAME)_dataset

#The above actually just puts the same generic ncbi_dataset into a file called REFERENCE_GENOME_READABLE_NAME_dataset, but I'm happy with this for now.

bowtie2_index:
	@echo "Indexing the genome..."
	mkdir -p $(REFERENCE_GENOME_READABLE_NAME)_indices
	bowtie2-build $(REFERENCE_GENOME_FASTA) \
		$(REFERENCE_GENOME_READABLE_NAME)_indices/$(REFERENCE_GENOME_READABLE_NAME)_index
	@echo "Indexing complete. Bowtie2 index files generated in $(REFERENCE_GENOME_READABLE_NAME)_indices directory with prefix $(REFERENCE_GENOME_READABLE_NAME)_index."

#Apparently I need to index the reference genome in yet another way for bedtools to work, so I need to generate a .fai file
samtools_index_fai:
	@echo "Indexing reference genome for bedtools..."
	samtools faidx $(REFERENCE_GENOME_FASTA)
	@echo "Reference genome indexed for bedtools: $(REFERENCE_GENOME_FASTA).fai. Inside the same directory as the reference genome."

clean:
	@echo "Cleaning up downloaded and generated files..."
	rm -r $(REFERENCE_GENOME_READABLE_NAME)_dataset
	rm -r $(REFERENCE_GENOME_READABLE_NAME)_dataset.zip
	rm -r $(REFERENCE_GENOME_READABLE_NAME)_indices
	@echo "Cleanup complete."

#AI suggests -f for clean, but this looks risky.