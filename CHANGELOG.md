# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [v1.6.1]
### Added
- Links to available datasets in the documentation.
- Greengenes2 database: the database used in the recent ZymoBIOMICS Microbial Communities with 16S dataset blog post is now available as "Greengenes2_plus".
- Workflow overview diagram in the documentation.
- Comprehensive database reference table to the README with citations and resource links.
### Changed
- Updated to wf-template v5.7.0 to maintain compliance with our latest wf-template standard, changing:
  - Pipeline overview now appears before pipeline parameters in README.
  - ezCharts plotting library has been updated to 0.15.1, there are no user facing changes to plots.
  - Fastcat FASTQ pre-processing program has been updated to 0.24.2, it is more robust to malformed FASTQ input.
  - CHANGELOG to be compliant with our formatting rules.
- Bump to wf-metagenomics v2.14.2
### Fixed
- Missing ranks when the user-selected taxonomic_rank was deeper than the maximum rank available for a given taxon in the database.

## [v1.6.0]
This release of wf-16s updates documentation to include guidance for analysis of ITS amplicons with the SQK-MAB114 kit. Additionally, this version of wf-16s fixes issues with missing files and division by zero, which were triggered when input data coverage was very low. This release removes the real time analysis options to simplify the workflow; new solutions for real time taxonomic classification are in development but users who wish to continue using this functionality will need to pin wf-16s to v1.5.0.
### Changed
- Update wf-metagenomics to [v2.14.0](https://github.com/epi2me-labs/wf-metagenomics/blob/master/CHANGELOG.md#v2140):
    - Update wf-template to v5.6.2, which changes:
        - Reduce verbosity of debug logging from fastcat which can occasionally occlude errors found in FASTQ files during ingress.
        - Log banner art to say "EPI2ME" instead of "EPI2ME Labs" to match current branding. This has no effect on the workflow outputs.
        - pre-commit configuration to resolve an internal dependency problem with flake8. This has no effect on the workflow.
    - Values in the diversity table appear as None if there are no reads in the sample.
    - Values in the abundance table are now integers instead of floats.
    - Samples with fewer than 50% of the median read count across all samples are excluded from the rarefaction table. This is to avoid the rest of the samples being rarefied to a very low number of reads, which would lead to a loss of information.
### Added
- Section in the README about presets for analysing ITS sequencing.
### Fixed
- Update to wf-metagenomics [v2.14.0](https://github.com/epi2me-labs/wf-metagenomics/blob/master/CHANGELOG.md#v2140):
    - Update wf-template to v5.6.2, which fixes:
        - Sequence summary read length N50 incorrectly displayed minimum read length, it now correctly shows the N50.
        - Sequence summary component alignment and coverage plots failed to plot under some conditions.
    - Missing output file containing per-read assignments after identity and coverage filters when using include_read_assignments with the minimap2 subworkflow; this table is now correctly published to {alias}_lineages.minimap2.assignments.tsv.
    - Missing output file(s) encountered in the prepare_databases:determine_bracken_length process when using the bracken_length option.
    - Missing output file(s) encountered in the minimap_pipeline:getAlignmentStats process when all reads are unclassified.
    - pandas.errors.EmptyDataError encountered in the getAlignmentStats process when reference coverage does not reach 1x
    - ZeroDivisionError: division by zero encountered in the progressive_bracken process when there are no taxa identified at all.
    - Versions of some tools were not properly displayed in the report.
    - raise ValueError("All objects passed were None") caused by all samples containing zero classified reads after applying bracken threshold.

### Removed
- Real time functionality has been removed to simplify the workflow. The following parameters have been removed as they are no longer required: `server_threads`, `kraken_clients`, `port`, `host`, `external_kraken2`, `batch_size`, `real_time`, `read_limit`. Using these parameters in v1.6.0 onwards will cause an error.
 - Update image to remove kraken2-server dependency as it was only required by the real time workflow.

## [v1.5.0]
### Changed
- Bump to wf-metagenomics v2.13.0
    - NCBI Taxonomy database updated to the 2025-01-01 release
    - Reconciled workflow with wf-template v5.5.0.
    - Fix error: bracken-build: line 231: syntax error: unexpected end of file when using SILVA database.
### Added
- `output_unclassified` parameter. When True, output unclassified FASTQ sequences for both minimap2 and kraken2 modes (default: False).
- Table with alignment stats is now an output: alignment_tables/{{ alias }}.alignment-stats.tsv

## [v1.4.0]
### Changed
- Bump to wf-metagenomics v2.12.0
### Added
- `bracken_threshold` parameter to adjust bracken minimum read threshold, default 10.

## [v1.3.0]
### Fixed
- Switch to markdown links in the outputs table in the README.
- Exclude samples if all the reads are removed during host depletion.
### Added
- `igv` option to enable IGV in the EPI2ME Desktop Application.
- `include_read_assignments` option to output a file with the taxonomy of each read.
- `Reads` section in the report to track the number of reads after filtering, host depletion and unclassified.
### Changed
- Bump to wf-metagenomics v2.11.0
- `keep_bam` is now only required to output BAM files.
- `include_kraken2_assignments` has been replaced by `include_read_assignments`.
- Update databases:
    - Taxonomy database to the one released 2024-09-01
### Removed
- `split-prefix` parameter, as the workflow automatically enables this option for large reference genomes.
- Plot showing number of reads per sample has been replaced for a new table in `Reads` section.

## [v1.2.0]
### Added
- Output IGV configuration file if the `keep_bam` option is enabled and a custom reference is provided (in minimap2 mode).
- Output reduced reference file if the `keep_bam` option is enabled (in minimap2 mode).
- `abundance_threshold` reduces the number of references to be displayed in IGV.
### Fixed
- `exclude-host` can input a file in the EPI2ME Desktop Application.
### Changed
- Bump to wf-metagenomics v2.10.0

## [v1.1.3]
### Added
- Reads below percentages of identity (`min_percent_identity`) and the reference covered (`min_ref_coverage`) are considered as unclassified in the minimap2 approach.
### Fixed
- Files that are empty following the fastcat filtering are discarded from downstream analyses.
### Changed
- Bump to wf-metagenomics v2.9.4
- `bam` folder within output has been renamed to `bams`

## [v1.1.2]
### Fixed
- "Can only use .dt accessor with datetimelike values" error in makeReport 
- "invalid literal for int() with base 10" error in makeReport
### Changed
- Bump to wf-metagenomics v2.9.2

## [v1.1.1]
### Changed
- Bump to wf-metagenomics v2.9.1

## [v1.1.0]
### Added
- Workflow now accepts BAM or FASTQ files as input (using the `--bam` or `--fastq` parameters, respectively).
### Changed
- Bump to wf-metagenomics v2.9.0
- Default for `--n_taxa_barplot` increased from 8 to 9.

## [v1.0.0]
### Changed
- Bump to wf-metagenomics v2.8.0
- Update docs

## [v0.0.4]
### Changed
- Bump to wf-metagenomics v2.7.0
- Fixed CHANGELOG format

## [v0.0.3]
### Changed
- Bump to wf-metagenomics v2.6.1

## [v0.0.2]
### Changed
- Bump to wf-metagenomics v2.6.0

## [v0.0.1]
First release.