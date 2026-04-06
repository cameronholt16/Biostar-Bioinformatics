# Week 2 Assignment

---

## 1. Organism

The organism is a bird called a kestrel.

[Ensembl GFF3 link](https://ftp.ensembl.org/pub/current_gff3/falco_tinnunculus/)

---

## 2. Sequence Regions

There are way more sequence regions than chromosomes. I think this is because the chromosomes haven't been assembled computationally yet.

```bash
grep '^##seq' Falco_tinnunculus.FalTin1.0.115.gff3 | wc -l
```

```
69109
```

---

## 3. Features

```bash
grep -v '^#' Falco_tinnunculus.FalTin1.0.115.gff3 > falco_no_metadata.gff3
```

```bash
wc -l falco_no_metadata.gff3
```

```
950008
```

So about a **million features**.

---

## 4. Gene Count

```bash
cut -f 3 falco_no_metadata.gff3 | sort | uniq -c | sort -rn | head
```

```
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
```

So about **15,000 genes**.

---

## 5. Feature Definitions

Lots of these terms are new to me, and I think there are some definitions that might be specific to bioinformatics, GFF3, or even this particular dataset. Here's my understanding:

* **Exon** = not spliced. Can be coding (CDS) or non-coding (UTR)
* **CDS** = DNA that eventually codes for protein. Usually continuous within an exon
* **biological_region** = "we don't know what this is"
* **region** = something vague that I doubt I should be worrying about at this stage
* **mRNA** = DNA that codes for spliced mRNA. Think CDS + UTR. Will likely be interrupted bits of a gene (e.g. bases 100–200, then 300–400 etc.)
* **five_prime_UTR** = DNA coding for 5' UTR
* **gene** = everything. Exons, introns, UTRs, whole shabang
* **three_prime_UTR** = what you'd think it is

I'm quite unsure of the rest of these, but I'm trying to do a week's work every half day I have for this project, so I'll stop here.

---

## 6. Most Common Features

Using the same command as in Q4:

```bash
cut -f 3 falco_no_metadata.gff3 | sort | uniq -c | sort -rn | head
```

Top 10 feature types:

* exon
* CDS
* biological_region
* region
* mRNA
* five_prime_UTR
* gene
* three_prime_UTR
* ncRNA_gene
* lnc_RNA

---

## 7. Complete and Well Annotated?

Clearly not. I don't think there's a full chromosome in here.

---

## 8. What Else Have I Learned?

ChatGPT has told me that the reason the common kestrel hasn't had its genome organised into chromosomes is likely not because we haven't read all its base pairs. Rather, it's more likely that we haven't put these short reads together.

This is harder than it sounds, at least partly because there are repetitive regions longer than the length of a read.
