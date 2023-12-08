If your question is not answered here, please report any issues or suggestions on the [github issues](https://github.com/epi2me-labs/wf-16s/issues) page or start a discussion on the [community](https://community.nanoporetech.com/). 

+ *Which database is used per default?* - By default, the workflow uses the NCBI 16S + 18S rRNA database. It will be downloaded the first time the workflow is run and re-used in subsequent runs.

+ *Are more databases available?* - Other 16s databases (listed below) can be selected with the `database_set` parameter, but the workflow can also be used with a custom database if required (see [here](https://labs.epi2me.io/how-to-meta-offline/) for details).
    * 16S, 18S, ITS
        * ncbi_16s_18s and ncbi_16s_18s_28s_ITS:  Archaeal, bacterial and fungal 16S/18S and ITS data. There are two databases available using the data from [NCBI]https://www.ncbi.nlm.nih.gov/refseq/targetedloci/)
        * SILVA_138_1: The [SILVA](https://www.arb-silva.de/) database (version 138) is also available. Note that SILVA uses its own set of taxids, which do not match the NCBI taxids. We provide the respective taxdump files, but if you prefer using the NCBI ones, you can create them from the SILVA files ([NCBI](https://www.arb-silva.de/no_cache/download/archive/current/Exports/taxonomy/ncbi/)). As the SILVA database uses genus level, the last taxonomic rank at which the analysis is carried out is genus (`taxonomic_rank G`).

+ *How can I use Kraken2 indexes?* - There are different databases available [here](https://benlangmead.github.io/aws-indexes/k2).

+ *How can I use custom databases?* - If you want to run the workflow using your own Kraken2 database, you'll need to provide the database and an associated taxonomy dump. For a custom Minimap2 reference database, you'll need to provide a reference FASTA (or MMI) and an associated ref2taxid file. For a guide on how to build and use custom databases, take a look at our [article on how to run wf-16s offline](https://labs.epi2me.io/how-to-meta-offline/).

+ *How can I run the workflow with less memory?* -
    When running in Kraken mode, you can set the `kraken2_memory_mapping` parameter if the available memory is smaller than the size of the database.

+ *How can I run the workflow offline?* - To run wf-16s offline you can use the workflow to download the databases from the internet and prepare them for offline re-use later. If you want to use one of the databases supported out of the box by the workflow, you can run the workflow with your desired database and any input (for example, the test data). The database will be downloaded and prepared in a directory on your computer. Once the database has been prepared, it will be used automatically the next time you run the workflow without needing to be downloaded again. You can find advice on picking a suitable database in our [article on selecting databases for wf-metagenomics](https://labs.epi2me.io/metagenomic-databases/).
