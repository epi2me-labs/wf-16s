This workflow can be used for the following:

+ Taxonomic classification of 16S rDNA and 18S rDNA amplicons using [default or custom databases](#FAQs). Default databases:
    - NCBI targeted loci: 16S rDNA, 18S rDNA, ITS (ncbi_16s_18s, ncbi_16s_18s_28s_ITS; see [here](https://www.ncbi.nlm.nih.gov/refseq/targetedloci/) for details).
+ Generate taxonomic profiles of one or more samples.

Additional features:
+ Two different approaches are available: `minimap2` (using alignment, default option) or `kraken2` (k-mer based).
+ Option to run it in [real time](#321-running-wf-metagenomics-in-real-time): `real_time`.
+ Results include:
    - An abundance table with counts per taxa in all the samples.
    - Interactive sankey and sunburst plots to explore the different identified lineages.
    - A bar plot comparing the abundances of the most abundant taxa in all the samples.
