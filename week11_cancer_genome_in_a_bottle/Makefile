all:
	$(MAKE) get_reference_genome
	$(MAKE) index_reference_genome
	$(MAKE) download_and_index_bams
	$(MAKE) call_variants_locally
	$(MAKE) index_local_variants
	$(MAKE) find_tumour_specific_variants
	$(MAKE) get_deep_variant_calls

#Approximate location of TP53 on GRCh38
TP53_REGION=chr17:7600000-7750000

# Set the URL of the reference genome
REFERENCE_GENOME_URL=https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/references/GRCh38/GRCh38_GIABv3_no_alt_analysis_set_maskedGRC_decoys_MAP2K3_KMT2C_KCNJ18.fasta.gz

# Set the path to the reference genome
REFERENCE_GENOME=refs/GRCh38.fasta.gz

get_reference_genome:
	@echo "Downloading reference genome..."
	mkdir -p refs
	curl -L ${REFERENCE_GENOME_URL} > ${REFERENCE_GENOME}
	@echo "Reference genome downloaded: ${REFERENCE_GENOME}"

#The mrsa stuff I've been doing in the first 10 weeks downloads reference genomes with an ncbi friendly tool. This is less abstract and "tool-y".

index_reference_genome:
	@echo "Indexing reference genome..."
	samtools faidx ${REFERENCE_GENOME}
	@echo "Reference genome indexed: ${REFERENCE_GENOME}.fai. Inside the same directory as the reference genome."

#Set the URL of the BAM files we want. Found this myself - the tutorial gets confused between duodenal and pancreatic cell lines.	
#Also set the names and locations of the bam files.
NORMAL_PANCREATIC_BAM_URL=https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/Element-AVITI-20241216/HG008-N-P_Element-StdInsert_70x_GRCh38-GIABv3.bam
NORMAL_PANCREATIC_BAM=bam/TP53_normal_pancreatic.bam

PANCREATIC_CANCER_TUMOUR_BAM_URL=https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/Element-AVITI-20241216/HG008-T_Element-StdInsert_111x_GRCh38-GIABv3.bam
PANCREATIC_CANCER_TUMOUR_BAM=bam/TP53_pancreatic_cancer_tumour.bam

DEEP_VARIANT_VCF_URL=https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/Ultima_DeepVariant-somatic-SNV-INDEL_20240822/HG008_edv_AF_recalibration.result.PASS.vcf.gz

download_and_index_bams:
	mkdir -p bam
	samtools view -b ${NORMAL_PANCREATIC_BAM_URL} ${TP53_REGION} > ${NORMAL_PANCREATIC_BAM}
	samtools index ${NORMAL_PANCREATIC_BAM}
	samtools flagstat ${NORMAL_PANCREATIC_BAM}
	samtools view -b ${PANCREATIC_CANCER_TUMOUR_BAM_URL} ${TP53_REGION} > ${PANCREATIC_CANCER_TUMOUR_BAM}
	samtools index ${PANCREATIC_CANCER_TUMOUR_BAM}
	samtools flagstat ${PANCREATIC_CANCER_TUMOUR_BAM}

call_variants_locally:
	#call variants in the normal pancreatic sample
	$(MAKE) -f cams_first_toolbox/variant_calling.mk call_variants \
		REFERENCE_GENOME_FASTA=refs/GRCh38.fasta.gz \
		BAM=${NORMAL_PANCREATIC_BAM} \
		READABLE_SAMPLE_NAME=TP53_normal_pancreatic \
		F2="--ploidy 2 --annotate FORMAT/GQ"

	#call variants in the pancreatic cancer tumour sample
	$(MAKE) -f cams_first_toolbox/variant_calling.mk call_variants \
		REFERENCE_GENOME_FASTA=refs/GRCh38.fasta.gz \
		BAM=${PANCREATIC_CANCER_TUMOUR_BAM} \
		READABLE_SAMPLE_NAME=TP53_pancreatic_cancer_tumour \
		F2="--ploidy 2 --annotate FORMAT/GQ"

index_local_variants:
	bcftools index variant_calls/TP53_normal_pancreatic.variants.vcf.gz
	bcftools index variant_calls/TP53_pancreatic_cancer_tumour.variants.vcf.gz

find_tumour_specific_variants:
	# -C: output variants in the first file (tumour) not present in the second (normal)
	# -w 1: write full VCF records from file 1 (tumour) rather than just a site list
	bcftools isec -C -w 1 \
		variant_calls/TP53_pancreatic_cancer_tumour.variants.vcf.gz \
		variant_calls/TP53_normal_pancreatic.variants.vcf.gz \
		-o variant_calls/tumour_specific_variants.vcf

get_deep_variant_calls:
	@echo "Downloading DeepVariant calls..."
	mkdir -p variant_calls
	curl -L ${DEEP_VARIANT_VCF_URL} -o variant_calls/deep_variant_calls.vcf.gz
	curl -L ${DEEP_VARIANT_VCF_URL}.tbi -o variant_calls/deep_variant_calls.vcf.gz.tbi
	@echo "DeepVariant calls downloaded: variant_calls/deep_variant_calls.vcf.gz and variant_calls/deep_variant_calls.vcf.gz.tbi"