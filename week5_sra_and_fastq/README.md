# Week 5 RNA-seq Data Processing (MRSA)

## Data retrieval

**Continue from last week:
Review the scientific publication you studied previously.
Identify the BioProject and SRR accession numbers for the sequencing data associated with the publication.**

BioProject:

```
PRJNA887926
```

To retrieve the associated runs:

```bash
bio search PRJNA887926 | grep "SRR"
```

This gives:

```
SRR21835896
SRR21835897
SRR21835900
SRR21835901
SRR21835898
SRR21835899
```

I extracted these by eye. For six runs, writing a more complex parsing command felt unnecessary.

---

## Bash script

**Reuse and expand your code from last week.
Create a bash shell script with the code from last week.**

At this point I realised I probably should have been using `.gitignore` earlier. Up to now, I’ve been running everything locally and pasting commands into the README to avoid uploading large data files.

That approach doesn’t scale very well anymore. This week’s work is more script-heavy, so the full pipeline (including a tidied version of last week) is in:

```
mrsa_rnaseq.sh
```

located alongside this README.

---

## Estimating 10× genome coverage

**Download only a subset of the data that would provide approximately 10× genome coverage.
Briefly explain how you estimated the amount of data needed for 10× coverage.**

### What is this data, physically?

My understanding:

* RNA → reverse transcription → **cDNA (double-stranded DNA)**
* cDNA is fragmented
* Adapters are added to both ends
* Library is amplified (PCR-like)
* Sequencing reads bases 5′ → 3′ using fluorescent terminators

The key constraint is read length (~100–150 bp), so for longer inserts we sequence both ends → **paired-end reads**. These are not necessarily reverse complements unless the insert is short enough that the reads overlap.

---

### Back-of-the-envelope calculation

I’m aiming for **10× coverage**, i.e. ~10 independent observations per base.

* MRSA genome ≈ **3 million bp**
* Target bases = **30 million bp**

Each paired read gives:

* 2 × 101 bp ≈ **200 bp**

So:

```
30,000,000 / 200 ≈ 150,000 paired reads
```

There are a few possible factor-of-2 mistakes lurking here, but conceptually I’m treating this as a redundancy calculation: how many bases do I need in total?

---

### Cross-check with metadata

```bash
bio search SRR21835896
```

Key fields:

```
"read_count": "15754542"
"base_count": "3182417484"
```

Check:

```
3182417484 / 15754542 = 202
```

This strongly suggests:

* reads are **paired**
* each pair contributes ~202 bases

So:

* `read_count` ≈ number of **paired reads**

---

### Final decision

I therefore download:

```
150,000 paired reads
```

using `fastq-dump` with `-X 150000`.

---

## Basic statistics

**Generate basic statistics on the downloaded reads.**

Using:

```bash
seqkit stats S*.fastq
```

Observations:

* Both files contain reads of exactly **101 bp**
* Number of reads matches the requested **150,000 subset**

Everything here is consistent with expectations.

---

## Quality assessment (FASTQC)

**Run FASTQC and evaluate the report.**

### Observations

* **Per base sequence quality** looks *suspiciously high*
* Looking directly:

  ```bash
  cat SRR21835896_1.fastq | head
  ```

  shows lots of `F` quality scores (very high confidence)

This almost feels *too* clean, but I don’t currently have evidence that anything is wrong.

---

### Sequence duplication

FASTQC flags **high duplication levels**.

The course notes basically say:

> dealing with duplication properly is non-trivial

So for now:

* I acknowledge the issue
* I do **not** attempt to fix it

This feels like something that depends heavily on the downstream analysis.


---

### Trimming / filtering

No trimming or filtering performed at this stage.

Reason:

* No catastrophic quality issues
* Duplication handling is non-trivial
* Adapter signal unclear

---

## Comparing sequencing platforms

**Find another dataset for the same genome using a different platform and compare.**

From browsing SRA:

* Original data: **Illumina**
* Alternative: **Oxford Nanopore**

### Key differences

| Feature            | Illumina             | Nanopore        |
| ------------------ | -------------------- | --------------- |
| Read length        | Short (~100 bp)      | Long            |
| Length consistency | Very uniform         | Variable        |
| Accuracy           | Very high            | Lower           |

These observed differences *might* be intrinsic to the technology, but it’s hard to disentangle from experimental variation.

---

## Open questions / improvements

A few things I still don’t fully understand:

* **Illumina chemistry**

  * My explanation is hand-wavy at best
  * Would like a more precise model of what’s happening chemically

* **Paired-end confusion**

  * Some explanations suggest only one strand is sequenced after adapter processing
  * Yet we clearly get paired reads
  * Is this a different stage of the protocol, or am I misunderstanding something?
  * Also, how are the reads paired in the data? What part of the physical sequencing process lets us recover the information of which strand was paired with which?

* **Adapters vs FASTQC**

  * I saw adapter sequence manually in just the second read
  * FASTQC didn’t complain much
  * Why the discrepancy?

* **WSL + explorer.exe behaviour**

  * File opening behaves differently depending on path
  * Likely subsystem-related
  * Worth understanding for reproducibility

* **Sequence duplication**

  * Needs proper investigation
  * Probably context-dependent

* **Script quality**

  * Output formatting could be cleaner
  * Add spacing / readability improvements
