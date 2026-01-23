This workflow can be used for the following:

+ Taxonomic classification of 16S rRNA, 18S rRNA and ITS amplicons using [default or custom databases](#faqs). Default databases:
    - NCBI targeted loci: 16S rDNA, 18S rDNA, ITS (ncbi_16s_18s, ncbi_16s_18s_28s_ITS; see [here](https://www.ncbi.nlm.nih.gov/refseq/targetedloci/) for details).
    - [Other available databases](#33-databases)
+ Generate taxonomic profiles of one or more samples.

The workflow default parameters are optimised for analysis of 16S rRNA gene amplicons.
For ITS amplicons, it is strongly recommended that some parameters are changed from the defaults, please see the [ITS presets](#analysing-its-amplicons) section for more information.

Additional features:
+ Two different approaches are available: `minimap2` (using alignment, default option) or `kraken2` (k-mer based).
+ Results include:
    - An abundance table with counts per taxa in all the samples.
    - Interactive sankey and sunburst plots to explore the different identified lineages.
    - A bar plot comparing the abundances of the most abundant taxa in all the samples.


<figure>
<img src="docs/images/wf-16s.tube.svg" alt="wf-16s overview schematic."/>
<figcaption>Schematic depicting wf-16s workflow.</figcaption>
</figure>