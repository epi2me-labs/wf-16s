# wf-16s

`wf-16s` is a Nextflow workflow leveraging the power of `wf-metagenomics` for identification of the origin of reads from targeted amplicon sequencing. The workflow has two modes of operation, it can use either [kraken2](https://ccb.jhu.edu/software/kraken2/) or [minimap2](https://github.com/lh3/minimap2) to determine the origin of reads.

The kraken2 mode can be used in real-time, allowing the workflow to run continuously alongside an ongoing sequencing run as read data is being produced by the Oxford Nanopore Technologies' sequencing instrument. The user can visualise the classification of reads and species abundances in a real-time updating report.
