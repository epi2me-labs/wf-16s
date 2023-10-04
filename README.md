# wf-16s

`wf-16s` is a Nextflow workflow leveraging the power of `wf-metagenomics` for identification of the origin of reads from targeted amplicon sequencing. The workflow has two modes of operation, it can use either [kraken2](https://ccb.jhu.edu/software/kraken2/) or [minimap2](https://github.com/lh3/minimap2) to determine the origin of reads.

The kraken2 mode can be used in real-time, allowing the workflow to run continuously alongside an ongoing sequencing run as read data is being produced by the Oxford Nanopore Technologies' sequencing instrument. The user can visualise the classification of reads and species abundances in a real-time updating report.




## Introduction

`wf-16s` offers two different approaches to assigning sequence reads to a species:

### Minimap2 - Default

[Minimap2](https://github.com/lh3/minimap2) provides the finest resolution analysis but, depending on the reference database used, at the expense of significantly more compute time. Currently the minimap2 mode does not support real-time.

The wf-16s workflow by default uses the NCBI 16S + 18S rRNA database that will be downloaded at the start of an analysis.

### Kraken2 

[Kraken2](https://github.com/DerrickWood/kraken2) is used with the [Kraken2-server](https://github.com/epi2me-labs/kraken2-server) to offer the fastest method for classification of reads. [Bracken](https://github.com/jenniferlu717/Bracken) is then used to give a good estimate of species level abundance in the sample which can be visualised in the report. The Kraken2 workflow mode can be run in real time. See quickstart below for more details.




## Quickstart

The workflow uses [nextflow](https://www.nextflow.io/) to manage compute and 
software resources, as such nextflow will need to be installed before attempting
to run the workflow.

The workflow can currently be run using either
[Docker](https://www.docker.com/products/docker-desktop) or
[Singularity](https://sylabs.io/singularity/) to provide isolation of
the required software. Both methods are automated out-of-the-box provided
either docker or singularity is installed.

It is not required to clone or download the git repository in order to run the workflow.
For more information on running EPI2ME Labs workflows [visit out website](https://labs.epi2me.io/wfindex).

**Workflow options**

To obtain the workflow, having installed `nextflow`, users can run:

```
nextflow run epi2me-labs/wf-16s --help
```

to see the options for the workflow.

The main options are: 

* `fastq`: A fastq file or directory containing fastq input files or directories of input files.
* `minimap2`: When set to true will run the analysis with minimap2.
* `kraken2`: When set to true will run the analysis with Kraken2 and Bracken.
* `watch_path`: Used to run the workflow in real-time, will continue to watch until a "STOP.fastq" is found.
* `read_limit`: Used in combination with watch_path the specify an end point.
* `kraken2_memory_mapping`: Used to avoid load the database into RAM memory. Available for kraken2 pipeline.


***Minimap2***

You can run the workflow with test_data available in the github repository using minimap2. Currently this mode does not support real-time.

```nextflow run epi2me-labs/wf-16s --fastq test_data```

Viewing alignment statistics can be enabled with the `--minimap2_by_reference` flag. Using this option produces a table and scatter plot in the report showing sequencing depth and coverage of each reference. Also in the report will be a heatmap showing the sequencing depth in percetile-windows per reference (for those whose percentage of depth is higher than 0.1%).

***Kraken2***

You can run the workflow with test_data using kraken2 instead. This mode supports real-time.

```nextflow run epi2me-labs/wf-16s --fastq test_data --classifier kraken2```

Alternatively, you can also run the workflow in real-time, meaning the workflow will watch the input directory(s) and process inputs at they become available in the batch sizes specified.

```nextflow run epi2me-labs/wf-16s --fastq test_data --classifier kraken2 --watch_path --batch_size 1000```

When using the workflow in real-time, the workflow will run indefinitely until a user interrupts the program (e.g with a ```ctrl+c``` command). The workflow can be configured to complete automatically after a set number of reads have been analysed using the ```read_limit``` variable. Once this threshold has been reached, the program will emit a "STOP.fastq" file into the fastq directory, which will instruct the workflow to complete. The "STOP.fastq" file is then deleted. 

```nextflow run epi2me-labs/wf-16s --fastq test_data --classifier kraken2 --watch_path --read_limit 4000```

**Important Note**

When using the real-time functionality of the workflow, the input directory must contain sequencing reads in fastq files or sub-directories which themselves contain sequencing reads in fastq files. This is in contrast to the standard workflow which can additionally accept reads provided as a single file directly.

The below is therefore the only input layout supported by the real-time functionality (the names of the child directories are unrestricted):

eg.

```
 ─── input_directory        ─── input_directory
    ├── reads0.fastq            ├── barcode01
    └── reads1.fastq            │   ├── reads0.fastq
                                │   └── reads1.fastq
                                ├── barcode02
                                │   ├── reads0.fastq
                                │   ├── reads1.fastq
                                │   └── reads2.fastq
                                └── barcode03
                                    └── reads0.fastq
```
**Notes on CPU resource of kraken server and client**
The kraken2 subworkflow uses a server process to handle kraken2 classification requests. This allows the workflow to persist the sequence database in memory throughout the duration of processing. There are some parameters that may be worth considering to improve the performance of the workflow:
- `--port`: The option specifies the local network port on which the server and clients will communicate.
- `--host`: Network hostname (or IP address) for communication between kraken2 server and clients. (See also `external_kraken2` parameter).
- `--external_kraken2`: Whether a pre-existing kraken2 server should be used, rather than creating one as part of the workflow. By default the workflow assumes that it is running on a single host computer, and further that it should start its own kraken2 server. It may be desirable to start a kraken2 server outside of the workflow (for example to host a large database), in which case this option should be enabled. This option may be used in conjuction with the `host` option to specify that the kraken2 server is running on a remote computer.
- `--kraken2_memory_mapping`: Kraken 2 will by default load the database into process-local RAM; this flag will avoid doing so. It may be useful if the available RAM memory is lower than the size of the chosen database.
- `--threads`: Several tasks in this workflow benefit from using multiple CPU threads. This option sets the number of CPU threads for all such processes. The total CPU resource used by the workflow is constrained by the executor configuration. See `server_threads` parameter for kraken specific threads.
- `--server_threads`: Number of CPU threads used by the kraken2 server for classifying reads.
- `--kraken_clients`: Number of clients that can connect at once to the kraken-server for classifying reads. It should not be set to more than 4 fewer than the executor CPU limit.

If running the kraken2 pipeline in a cluster, there are two options to enable the workflow to be able to communicate with the kraken_server: 1: Run a kraken_server separately outside of the workflow; 2: Submit the workflow job to run on a single node (so running as if on a local server).

***Databases***

wf-16s has 3 pre-defined databases that can be chosen with `--database_set`:

To analyze  archaeal, bacterial and fungal 16S/18S and ITS data, there are two databases available that we have put together using the data from [NCBI](https://www.ncbi.nlm.nih.gov/refseq/targetedloci/). They can be used in both kraken2 and minimap2 pipelines:
* ncbi_16s_18s
* ncbi_16s_18s_28s_ITS
* SILVA_138_1

Besides, you can also use the [SILVA] (https://www.arb-silva.de/) database (version 138). Note that in this case, SILVA uses its own taxids, which do not match the NCBI taxids. We provide the respective taxdump files, but if you prefer using the NCBI ones, you can create them from the SILVA files [NCBI] (https://www.arb-silva.de/no_cache/download/archive/current/Exports/taxonomy/ncbi/). As SILVA database uses genus level, the last taxonomic rank at which the analysis is carried out is genus (`--taxonomic_rank G`).

If you want to run the workflow using your own database, you can use the parameters: database_set, taxonomy, database (kraken2) and reference (either a FASTA format reference or a minimap2 MMI format index) and ref2taxid (minimap2). Run `nextflow run main.nf --help` to find out more about them.

***Output***

The main output of the wf-16s pipeline is the `wf-16s-report.html` which can be found in the output directory. It contains a summary of read statistics, the taxonomic composition of the community and some diversity metrics. We have also added a couple of options to customize the results in the report. Use `--abundance_threshold` to remove from the abundance table all the taxa below the threshold. If it is a natural number it removes from the table those taxa with less counts; however to remove those taxa below a percent use a percent expressed as a decimal between 0-1). Furthermore, `--n_taxa_barplot` controls the number of taxa displayed in the bar plot and groups the rest under the category ‘Other’.

There are also other folders within the output folder that contain other output files from the pipeline such as the kraken and bracken reports. Additionally, the ‘species-abundance.tsv’ is a table with the counts of the different taxa per sample. You can use the flag `--include_kraken2_assignments` to include a per sample TSV file that indicates how each input sequence was classified as well as the taxon that has been assigned to each read. This TSV file will only be output on completion of the workflow and therefore not at all if using the real time option whilst running indefinitely. This option is available in the kraken2 pipeline.

***Host depletion***

We have included an optional host filtering step in the pipeline to remove any sequences that map (using minimap2) against a provided reference, which can be a FASTA file or a MMI index. To use this option, just add `--exclude_host` and the path to your host reference. The mapped reads are output in a BAM file and excluded for further analysis.

```nextflow run epi2me-labs/wf-16s --fastq test_data/case04/reads.fastq.gz --exclude_host test_data/case04/host.fasta.gz```

***Diversity***

Species diversity refers to the taxonomic composition in a specific microbial community. There are three main concepts:

* Richness: number of unique taxonomic groups present in the community,
* Taxonomic group abundance: number of individuals of a particular taxonomic group present in the community,
* Evenness: refers to the equitability of the different taxonomic groups in terms of their abundances.

Two different communities can host the same number of different taxonomic groups (i.e. they have the same richness), but they can have different evenness. For instance, if there is one taxon whose abundance is much larger in one community compared to the other.

To provide a quick overview of the diversity of the microbial community, we provide some of the most common indices calculated by a specific taxonomic rank <sup>[1](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4224527/)</sup>. This rank can be chosen by the user providind the flag `--taxonomic_rank` and the desired rank: 'D'=Domain,'P'=Phylum, 'C'=Class, 'O'=Order, 'F'=Family, 'G'=Genus, 'S'=Species. By default, the rank is 'G' (genus level). Some of these indices are:

* Shannon Diversity Index (H): Shannon entropy approaches zero when one of the taxa is much more abundant than the others.    
```math
H = -\sum_{i=1}^{S}p_i*ln(p_i)
```

* Simpson's Diversity Index (D): The range is from 0 (low diversity) to 1 (high diversity).    

```math
D = \sum_{i=1}^{S}p_i^2
```

* Pielou Index (J): The values range from 0 (presence of a dominant genus) and 1 (maximum evennes).    

```math
J = H/ln(S)
```


These indices are calculated by default using the original abundance table (see McMurdie and Holmes<sup>[2](https://pubmed.ncbi.nlm.nih.gov/24699258/)</sup>, 2014 and Willis<sup>[3](https://www.frontiersin.org/articles/10.3389/fmicb.2019.02407/full)</sup>, 2019). If you want to calculate them from a rarefied abundance table (i.e. all the samples have been subsampled to contain the same number of counts per sample, which is the 95% of the minimum number of total counts), you can use download the rarefied table from the report.

The report also includes the rarefaction curve per sample which displays the mean of genus richness for a subsample of reads (sample size). Generally, this curve initially grows rapidly, as most abundant genus are sequenced and they add new taxa in the community, then slightly flattens due to the fact that 'rare' genus are more difficult of being sampled, and because of that is more difficult to report an increase in the number of observed genus.

*Note: Within each rank, each named taxon is considered to be a unique unit. The counts are the number of reads assigned to that taxon. All 'Unknown' sequences are considered as a unique taxon.*



## Useful links

* [nextflow](https://www.nextflow.io/)
* [docker](https://www.docker.com/products/docker-desktop)
* [singularity](https://docs.sylabs.io/guides/latest/user-guide/)
