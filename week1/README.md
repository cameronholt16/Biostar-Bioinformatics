# Week 1 – Setup and Basics

## Getting Started

* Followed the setup instructions to get everything running.
* All good 👍

## GitHub Setup

* Already had a GitHub account.
* Created this repository: **Biostar-Bioinformatics** to hold all assignments.

## Directory + README

* Created a directory for Week 1.
* Added this `README.md`.

## Note on Commands

This README includes commands and their outputs where relevant.

---

## Samtools Version

Checked the version of `samtools` in my `bioinfo` environment:

```bash
samtools --version
```

Output:

```
samtools 1.23.1
Using htslib 1.23.1
```

---

## Creating Nested Directories

Used `mkdir -p` to create a full directory structure in one go:

```bash
mkdir -p example_grandparent/example_parent/example_child
```

---

## Creating Files in Different Directories

Created a file inside a nested directory:

```bash
touch example_grandparent/thisfileliveswithparent.txt
```

---

## Relative vs Absolute Paths

### Relative Path

```bash
cat example_grandparent/example_parent
```

Output:

```
cat: example_grandparent/example_parent: Is a directory
```

### Absolute Path

```bash
cat /home/biocam/assignments/example_grandparent/example_parent
```

Output:

```
cat: /home/biocam/assignments/example_grandparent/example_parent: Is a directory
```

---

## Git Workflow

* Committed changes
* Pushed to GitHub

All done.

---

## Submission

* Repository link submitted.
