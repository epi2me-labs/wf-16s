If your question is not answered here, please report any issues or suggestions on the [github issues](https://github.com/epi2me-labs/wf-16s/issues) page or start a discussion on the [community](https://community.nanoporetech.com/). 

+ *Which database is used per default?* - By default, the workflow uses the NCBI 16S + 18S rRNA database. It will be downloaded the first time the workflow is run and re-used in subsequent runs.

+ *How can I use Kraken2 indexes?* - There are different databases available [here](https://benlangmead.github.io/aws-indexes/k2).

+ *How can I use custom databases?* - If you want to run the workflow using your own Kraken2 database, you'll need to provide the database and an associated taxonomy dump. For a custom Minimap2 reference database, you'll need to provide a reference FASTA (or MMI) and an associated ref2taxid file. For a guide on how to build and use custom databases, take a look at our [article on how to run wf-16s offline](https://labs.epi2me.io/how-to-meta-offline/).

+ *How can I run the workflow with less memory?* -
    When running in Kraken mode, you can set the `kraken2_memory_mapping` parameter if the available memory is smaller than the size of the database.

+ *How can I run the workflow offline?* - To run wf-16s offline you can use the workflow to download the databases from the internet and prepare them for offline re-use later. If you want to use one of the databases supported out of the box by the workflow, you can run the workflow with your desired database and any input (for example, the test data). The database will be downloaded and prepared in a directory on your computer. Once the database has been prepared, it will be used automatically the next time you run the workflow without needing to be downloaded again. You can find advice on picking a suitable database in our [article on selecting databases for wf-metagenomics](https://labs.epi2me.io/metagenomic-databases/).

+ *When and how are coverage and identity filters applied when using the minimap2 approach?* - With minimap2-based classification, coverage and identity filtering is applied by using the `min_ref_coverage` and `min_percent_identity` options respectively. All reads that mapped to a reference, but failed to pass these filters, are relabelled as unclassified. If the `include_read_assignments` option is used, tables in the output will show read classifications after this filtering step. However, the output BAM file always contains the raw minimap2 alignment results. To read more about both filters, see [minimap2 Options](#minimap2-options).

