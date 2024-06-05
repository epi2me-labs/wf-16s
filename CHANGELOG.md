# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


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
- First release.