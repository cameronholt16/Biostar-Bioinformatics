# Week 8 Assignment

At this point in the course, the lectures start pushing the idea that I should be building a bioinformatics toolbox rather than writing a completely new Makefile every week. I have now started doing that, and I have included my toolbox in this repository along with the Makefile and `design.csv`.

## [Assignment]

This assignment requires the presence of a Makefile, a README.md markdown file, and a `design.csv` file. Please add all three files to your repository and submit the link to your repository.

I reused and adapted the Makefile from previous assignments. For the paper I was reproducing, I created a `design.csv` file that links SRR accessions to readable sample names.

## [Identify the sample names that connect the SRR numbers to the samples]

```bash
$ bio search PRJNA887926 | grep -E "run|sample_desc"
SRR21835898 control biological replicate 1
SRR21835899 sodium propionate treatment biological replicate 3
SRR21835896 control biological replicate 3
SRR21835897 control biological replicate 2
SRR21835900 sodium propionate treatment biological replicate 2
SRR21835901 sodium propionate treatment biological replicate 1
````

From this, I matched the SRR numbers to simple sample names.

## [Create a design.csv file that connects the SRR numbers to the sample names]

```csv
SRR,sample
SRR21835898,control_rep1
SRR21835899,propionate_rep3
SRR21835896,control_rep3
SRR21835897,control_rep2
SRR21835900,propionate_rep2
SRR21835901,propionate_rep1
```

## [Create a Makefile that can produce multiple BAM alignment files]

The Makefile can now take an SRR accession and a sample name, then produce outputs named after the sample instead of the raw SRR number. This makes the output much easier to read.

## [Using GNU parallel run the Makefile on all samples]

```bash
$ tail -n +2 design.csv | parallel --colsep ',' 'make workflow_for_one_sample SRR={1} SAMPLE={2} REFERENCE_GENOME_READABLE_NAME=mrsa465'
```

This command runs the workflow once for each row in `design.csv`.

`tail` prints the end of a file. The `-n` option controls which lines to print. Usually you give it a number like `-n 5` for the last 5 lines, but `-n +2` means "start at line 2 and print from there to the end". In this case, that just skips the header row.

`parallel --colsep ','` tells GNU parallel to treat commas as column separators.

So for each line of the CSV after the header, `{1}` becomes the SRR accession and `{2}` becomes the sample name.

## [Create a README.md file that explains how to run the Makefile]

The key command is given above and a description of the expected results is given below.

## [The result should consist of:]

### A genome named with a user-friendly name

I used:

```bash
REFERENCE_GENOME_READABLE_NAME=mrsa465
```

so the reference genome files are named with `mrsa465` instead of the less readable accession.

### FASTQ read data named by the samples

FASTQ read data goes into directories such as:

* `control_rep1.reads`
* `propionate_rep2.reads`

### FASTQC reports for each read

FASTQC reports go into directories such as:

* `control_rep1.fastqc`
* `propionate_rep2.fastqc`

### Alignments and coverage files in BAM and BW formats

The workflow produces alignment and coverage files named after the sample, including BAM and bigWig files.

### A statistics alignment report for the BAM file

For each sample, the workflow also produces a text report such as:

```text
control_rep1.bam_stats.txt
```

which contains the alignment statistics for that BAM file.

## Possible Improvements

At the moment, alignment and coverage files are written into the working directory. That worked fine here, but as the toolbox grows I may want to organise some of these outputs into their own directories.

More generally, my toolbox is still pretty basic. I expect it to get much better as I get more experience.
