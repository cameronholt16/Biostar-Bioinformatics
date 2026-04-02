if [ ! -f ncbi_dataset.zip ]; then
    echo "Downloading genome..."
    datasets download genome accession GCF_000013465.1 --include gff3,genome
else
    echo "Genome zip already exists, skipping download"
fi

if [ ! -f ncbi_dataset/data/GCF_000013465.1/genomic.gff ]; then
    echo "Unzipping dataset..."
    unzip -n ncbi_dataset.zip
else
    echo "Genome already unzipped, skipping"
fi

echo "Moving into directory with the sequencing data in it"

cd ncbi_dataset/data/GCF_000013465.1

echo "What's here?"
ls

echo "Summarise FASTA"
seqkit stats GCF_000013465.1_ASM1346v1_genomic.fna

echo "What features do we have?"
grep -v "#" genomic.gff | cut -f3 | sort-uniq-count-rank

echo "What's the biggest gene and its end index?"
grep -v "^#" genomic.gff | awk '$3=="gene" {print $9, $5-$4, $5}' | sort -k2 -nr | head

echo "Let's have a look at another random gene"
grep "hysA" genomic.gff

echo "Time for some fastq analysis!"
cd ../../..
echo "should be in directory of this assignment"
pwd

echo "Let's find our SPR accession numbers"
bio search PRJNA887926 | grep "SRR"

echo "Should see SRR21835896, SRR21835897, SRR21835900, SRR21835901, SRR21835898 SRR21835899."

echo "Let's find out about an SRR"
bio search SRR21835896
echo "Looks like about 15 million reads and 3 billion bases. This quotient is 202 = 2x the length of each read (discovered below), so these reads are clearly counted in pairs"

echo "Let's get the FASTQ data"

if [ ! -d reads ]; then
    echo "Downloading Fastq..."
    mkdir -p reads
    fastq-dump -X 150000 -F --outdir reads --split-files SRR21835896
else
    echo "Already downloaded fastq reads, skipping download"
fi

echo "What does a FASTQ file look like?"
cat reads/SRR21835896_1.fastq | head
echo "Hmmm, lots of F's..."

echo "What's the big picture these fastq files?"

seqkit stats reads/SRR21835896_*.fastq

echo "run FASTQC"
fastqc reads/SRR21835896_*.fastq

echo "Take a look at the results (For some reason, perhaps because I'm running this on a linux subsystem, I need to be in the directory for this to work properly)"
cd reads
explorer.exe SRR21835896_1_fastqc.html
explorer.exe SRR21835896_2_fastqc.html
cd ..
echo "These reads (explored above) seem to be all 'F' (best) quality. I can think of a couple of reasons why that may be, but fastqc can only analyse the data it's given. "

echo "Let's briefly compare to data from a different sequencer"

bio search SRR18432816

echo "Let's look a bit closer"
fastq-dump -X 10 -F SRR18432816
cat SRR18432816.fastq | head

echo "Nanopore appears to give longer reads of more varied length. Also, the read qualities are more modest, but it's hard to tell if this is an artefact of the sequencer or these experiments in particular"
