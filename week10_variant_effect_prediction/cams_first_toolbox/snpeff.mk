#-----------Optional Variables and Derivatives-----------------

# GCF Reference genome (I think GCF is kind of the level above NC, but is effectively the same for this single chromosome organism)
GCF = GCF_000013465.1

#Give a more readable name if you have one, else just use the GCF.
REFERENCE_GENOME_READABLE_NAME = $(GCF)

#path to fasta and gff3 files
PATH_TO_REFERENCE_GENOME = $(REFERENCE_GENOME_READABLE_NAME)_dataset/ncbi_dataset/data/$(GCF)

#Reference genome fasta file
REFERENCE_GENOME_FASTA = $(PATH_TO_REFERENCE_GENOME)/*genomic.fna

#----------------End of optional variables and derivatives----------------

usage:
	@echo "snpeff.mk: Makefile to prepare reference genome and gff3 files for snpEff, build a custom snpEff database, and annotate a multisample VCF file with snpEff."
	@echo "#"
	@echo "arguments:"
	@echo "GCF: The GCF accession number for the reference genome. Default is $(GCF)."
	@echo "REFERENCE_GENOME_READABLE_NAME: Optionally provide a more human-readable name for the reference genome. Defaults to GCF."
	@echo "#"
	@echo "targets:"
	@echo "prepare_reference_genome_for_snpeff: Copy the reference genome fasta file to a new directory - snpeff_db/$(REFERENCE_GENOME_READABLE_NAME)/sequences.fa - and rename it so snpEff can read it."
	@echo "prepare_gff3_for_snpeff: Copy the gff3 file to a new directory - snpeff_db/$(REFERENCE_GENOME_READABLE_NAME)/genes.gff - and rename it so snpEff can read it."
	@echo "build_snpeff_custom_database: Build a custom snpEff database using the prepared reference genome and gff3 files."
	@echo "annotate_multisample_vcf_with_snpeff: Annotate a multisample VCF file with snpEff using the custom database built earlier. Output is annotated_variants.vcf."

#target to copy reference genome to a new directory - snpeff_db/$(REFERENCE_GENOME_NAME)/sequences.fna - and rename it so snpEff can read it
prepare_reference_genome_for_snpeff:
	mkdir -p snpeff_db/$(REFERENCE_GENOME_READABLE_NAME)
	cp $(REFERENCE_GENOME_FASTA) snpeff_db/$(REFERENCE_GENOME_READABLE_NAME)/sequences.fa

#target to copy gff3 file to a new directory - snpeff_db/$(REFERENCE_GENOME_NAME)/genes.gff - and rename it so snpEff can read it
prepare_gff3_for_snpeff:
	cp $(PATH_TO_REFERENCE_GENOME)/*genomic.gff snpeff_db/$(REFERENCE_GENOME_READABLE_NAME)/genes.gff

build_snpeff_custom_database:
	mkdir -p snpeff_config
	echo "$(REFERENCE_GENOME_READABLE_NAME).genome : $(REFERENCE_GENOME_READABLE_NAME)" > $(CURDIR)/snpeff_config/snpEff.config
	snpEff build -gff3 \
	-noCheckCds \
	-noCheckProtein \
	-dataDir $(CURDIR)/snpeff_db \
	-c $(CURDIR)/snpeff_config/snpEff.config \
	$(REFERENCE_GENOME_READABLE_NAME)

annotate_multisample_vcf_with_snpeff:
	snpEff ann \
	-dataDir $(CURDIR)/snpeff_db \
	-c $(CURDIR)/snpeff_config/snpEff.config \
	$(REFERENCE_GENOME_READABLE_NAME) multisample.vcf.gz > annotated_variants.vcf

clean:
	rm -r snpeff_db
	rm -r snpeff_config
	rm annotated_variants.vcf