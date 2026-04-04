````markdown
# Week 7 Assignment

This assignment involved extending the week 6 workflow so that it could be reused on multiple sequencing runs, generating BAM and bigWig files, and comparing alignments from two datasets for the same organism.

## Overview

In week 6, I wrote a Makefile to align reads to a reference genome and generate a BAM file. In week 5, I identified an alternative sequencing run for the same organism.

The alternative SRA run I originally found in week 5 was **SRR18432816**. Looking through one of the associated papers, I confirmed that it used **NC_007793.1**, which is the same reference genome I used previously. That was enough for me to treat this as the “same” organism for the purposes of the assignment.

## Making the Makefile more generic

The assignment required the Makefile to be parameterised so that no code changes were needed when switching to a different SRR, for example:

```bash
make fastq SRR=SRR1972739
````

My original Makefile was not quite generic enough. I had hard-coded a directory called `reads` for the FASTQ files, which would clearly become messy if I wanted to process multiple SRRs. I changed the workflow so that the read directory depends on the value of `SRR`.

I then ran into a second problem: the original dataset is **paired-end**, while my alternative dataset was **single-end**. That means the workflow cannot simply assume the same structure for every run.

I considered four options:

1. Automatically detect whether the run is paired-end or single-end, then branch downstream accordingly.
2. Require the user to specify whether the data are paired or single.
3. Try to make every downstream step fully agnostic to the number of read files.
4. Abandon that SRR and choose a different alternative run.

I went with **option 1**, since it seemed the most in keeping with the idea of a generic Makefile.

## Testing alternative SRRs

After implementing that, I tried aligning the alternative Oxford Nanopore run and got a **0% alignment rate**, despite triple-checking that I had the right organism. The most likely explanation is simply that **Bowtie2 is not a good fit for Nanopore reads**, which are long and have a different error profile from Illumina reads.

I therefore tested some additional SRRs:

| SRR         | Platform        | Layout | Percent mapped |
| ----------- | --------------- | -----: | -------------: |
| SRR37925060 | Illumina        | paired |            67% |
| SRR37070131 | Illumina        | single |            98% |
| SRR4932225  | Ion Torrent     | paired |            86% |
| SRR36364339 | Oxford Nanopore | single |             0% |

The second Nanopore run also gave **0%**, which supports the idea that the issue is the combination of **Bowtie2 + Nanopore**, rather than a mistake in the accession or reference choice.

For the final comparison, I used **SRR4932225**, since it came from a different instrument and still aligned successfully. That felt most in the spirit of the assignment.

## Workflow used

I added code to produce both BAM and bigWig output.

The relevant targets are:

* `(download_and_unzip)`
* `get_fastq`
* `(index)`
* `align`
* `bam`
* `bam_index`
* `(fai)`
* `bedgraph`
* `bedgraph_to_bigwig`

The bracketed steps only need to be run once because they are not specific to a particular SRR. For all SRR-specific steps, I can now pass a run accession directly:

```bash
make get_fastq SRR=SRR21835896
make align SRR=SRR21835896
make bam SRR=SRR21835896
make bam_index SRR=SRR21835896
make bedgraph SRR=SRR21835896
make bedgraph_to_bigwig SRR=SRR21835896
```

and similarly for the comparison dataset:

```bash
make get_fastq SRR=SRR4932225
make align SRR=SRR4932225
make bam SRR=SRR4932225
make bam_index SRR=SRR4932225
make bedgraph SRR=SRR4932225
make bedgraph_to_bigwig SRR=SRR4932225
```

For the comparison SRR, I passed `N_READS=100000`. This was optional. Using the same number of reads for both datasets would have made the coverage comparison more directly comparable, but the mismatch in coverage actually helped me see the differences more clearly in IGV.

## IGV visualisation

I loaded the following into IGV:

* the reference genome
* the GFF annotation file
* both BAM files
* both bigWig coverage tracks

I combined this visual inspection with the question about the coordinate of maximum coverage.

## Differences between the two alignments

The two alignments look noticeably different in IGV.

The original Illumina dataset (**SRR21835896**) aligns much more cleanly overall and has a higher mapping rate. It also shows a very strong local peak at one coordinate that is not reproduced in the Ion Torrent dataset.

The Ion Torrent dataset (**SRR4932225**) still aligns reasonably well, but less completely. It has lower overall mapping, many more singleton alignments proportionally, and a different coverage profile. Some peaks are shared between the datasets, but others are not.

One especially striking example is that the strongest coverage peak in **SRR21835896** is completely absent in **SRR4932225**.

## BAM statistics

Using `make bam_stats`, I found that:

* **SRR21835896** had about **99%** of reads mapped.
* **SRR4932225** had about **86%** of reads mapped.

The second dataset also had a much higher proportion of **singletons**.

Because I downloaded fewer reads for `SRR4932225`, the absolute coverage is not directly comparable. Still, even allowing for that, the mapping statistics clearly show that the original Illumina dataset aligned better.

## Number of primary alignments

The assignment asks:

> How many primary alignments does each of your BAM files contain?

The counts were:

* **SRR21835896:** `298757`
* **SRR4932225:** `170913`

## Coordinate with the largest observed coverage

I used `samtools depth` as suggested:

```bash
$ samtools depth -a SRR21835896.aligned_reads.bam | sort -k3,3nr | head -n 1
NC_007793.1     2500332 29523
```

```bash
$ samtools depth -a SRR4932225.aligned_reads.bam | sort -k3,3nr | head -n 1
NC_007793.1     508240  19569
```

So the coordinates with the maximum observed coverage were:

* **SRR21835896:** `NC_007793.1:2500332`
* **SRR4932225:** `NC_007793.1:508240`

Interestingly, these are **not the same coordinate**.

I saved screenshots from IGV:

* `Week7_896_most_covered.png` shows the peak at `2500332` for `SRR21835896`. Strangely, `SRR4932225` has no reads there at all.
* `Week7_2225_most_covered.png` shows a more natural-looking peak for `SRR4932225`. Both datasets show a local peak in this region.

## Gene of interest: *ebh*

For the gene-of-interest question, I chose **ebh**.

I identified the gene coordinates from the GFF file:

```bash
$ grep -i "ebh" ncbi_dataset/data/GCF_000013465.1/genomic.gff
NC_007793.1     RefSeq  gene    1456811 1488076 .
```

The question asks:

> Select a gene of interest. How many alignments on the forward strand cover the gene?

I first inspected the alignments manually:

```bash
$ samtools view SRR4932225.aligned_reads.bam NC_007793.1:1456811-1488076
```

There were few enough to count by eye.

According to the SAM specification:

> “bit 0x10 unset indicates the forward strand, while set indicates the reverse strand”

Using that, I counted **3 forward-strand alignments** in `SRR4932225`.

I then confirmed this with:

```bash
$ samtools view -F 16 SRR4932225.aligned_reads.bam NC_007793.1:1456811-1488076 | wc -l
3
```

For comparison, the total number of alignments over the same region in the original dataset was much higher:

```bash
$ samtools view SRR21835896.aligned_reads.bam NC_007793.1:1456811-1488076 | wc -l
254
```

## Conclusion

Overall, the original Illumina dataset aligned better than the alternative Ion Torrent dataset. It had a higher mapping percentage, more primary alignments, and a different coverage profile. The two runs clearly do not produce identical alignment patterns, even though they are mapped to the same reference genome.

The Makefile is now much more reusable than it was in week 6: I can run the same targets on different SRRs by passing parameters, and the workflow now also produces bigWig coverage tracks for IGV visualisation.

## Improvements and further investigation

A few things I would investigate further if I had more time:

* Why exactly do Nanopore reads fail so badly with Bowtie2 in this workflow?
* Why do I need to index the reference genome in two different ways?
* Download the same number of reads from `SRR4932225` as from `SRR21835896` to make the coverage comparison more direct.
* Investigate why `SRR4932225` completely misses the strongest peak from `SRR21835896`, while still sharing other local peaks nearby.
* Clean up the Makefile further, since `R1` and `R2` are probably still redundant in places now that the workflow handles different layouts.
