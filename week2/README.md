# Week 2 Assignment

---

## 1. Organism

The organism is a bird called a kestrel.  

[Ensembl GFF3 link](https://ftp.ensembl.org/pub/current_gff3/falco_tinnunculus/Falco_tinnunculus.FalTin1)

---

## 2. Sequence Regions

There are way more sequence regions than chromosomes. I think this is because the chromosomes haven't been assembled computationally yet.

$ grep '^##seq' Falco_tinnunculus.FalTin1.0.115.gff3 | wc -l
69109

---

## 3. Features

$ cat Falco_tinnunculus.FalTin1.0.115.gff3 | grep -v '^#' > falco_no_metadata.gff3

$ cat falco_no_metadata.gff3 | wc -l
950008

So about a **million features**.

---

## 4. Gene Count

$ cat falco_no_metadata.gff3 | cut -f 3 | sort | uniq -c | sort -rn | head
 349721 exon
 340317 CDS
 116409 biological_region
  69109 region
  25330 mRNA
  18650 five_prime_UTR
  15237 gene
  13285 three_prime_UTR
    818 ncRNA_gene
    618 lnc_RNA

So about **15,000** genes

---

## 5. Feature Definitions

Lots of these terms are new to me, and I think there are some definitions that might be specific to bioinformatics, GFF3, or even this particular dataset. Here's what ChatGPT has given me:

Exon = not spliced. Can be coding (CDS) or non-coding (UTR)
CDS = DNA that eventually codes for protein. Usually continuous within an exon
biological_region = â'we don't know what this is'
region = something vague that I doubt I should be worrying about at this stage
mRNA = DNA that codes for spliced mRNA. Think CDS + UTR. Will likely be interrupted bits of a gene (see below). Maybe bps 100â€“200, then 300â€“400 etc.
5'²UTR = DNA coding for 5â€² UTR
gene = everything. Exons, introns, UTRs, whole shabang
3'²UTR = what you'd think it is

I'm quite unsure of the rest of these, but I'm trying to do a week's work every half day I have for this project, so I'll stop here.

---

## 6. Most Common Features

Exon, CDS, biological_region, region, mRNA

---

## 7. Complete and Well Annotated?

Clearly not. I don't think there's a full chromosome in here.

---

## 8. What Else Have I Learned?

ChatGPT has told me that the reason the common kestrel hasn't had its genome organised into chromosomes is likely not because we haven't read all its base pairs. Rather, it's more likely that we haven't put these short reads together.

This is harder than it sounds, at least partly because there are repetitive regions longer than the length of a read.
