# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v4.2.0]
### Added
- 'CWUtil.mutateParam(params, k, v)' can be used to mutate the contents of the global Nextflow parameter map
### Changed
- Workflow uses `wf-common` container by default
- Sample `meta` contains `run_ids` key which lists all Run IDs observed by `fastcat`
- `fastqingress` processes additionally labelled with `fastq_ingress`
- Use literal names to stage process inputs wherever possible and wrap filenames in quotes otherwise.
- Any sample aliases that contain spaces will be replaced with underscores.

### Removed
- `wf-template` container is no longer used
- `params.process_label` is no longer required

## [v4.1.0]
### Added
- Optional `required_sample_types` field added to fastqingress. The sample sheet must contain at least one of each sample type provided to be deemed valid.
- Configuration for running demo data in AWS

### Changed
- Updated GitHub issue templates to force capture of more information.
- Removed glibc hack from post-test script
- Updated LICENSE to BSD-4-Clause
- Enum choices are enumerated in the `--help` output
- Enum choices are enumerated as part of the error message when a user has selected an invalid choice
- Bumped minimum required Nextflow version to 22.10.8

### Fixed
- Replaced `--threads` option in fastqingress with hardcoded values to remove warning about undefined `param.threads`

## [v4.0.0]
### Added
- GitHub issues template.
- Return of metadata with fastqingress.
- Check of number of samples and barcoded directories.
- Example of how to use the metadata from `fastqingress`.
- Implemented `--version`
- `fastcat_extra_args` option to `fastq_ingress` to pass arbitrary arguments to `fastcat` (defaults to empty string).
- `fastcat_stats` option to `fastq_ingress` to force generation of `fastcat` stats even when the input is only a single file (default is false).

### Changed
- Use `bgzip` for compression instead of `pigz`.
- pre-commit now uses `flake8` v5.0.4.
- Report is now created with [ezCharts](https://github.com/epi2me-labs/ezcharts).
- The workflow now also publishes the metadata emitted by `fastq_ingress` in `$params.out_dir`.
- `fastq_ingress` now returns `[metamap, path-to-fastcat-seqs | null, path-to-fastcat-stats | null]`.
- Bumped base container to v0.2.0.
- Use groovy script to ping after workflow has run.
- Removed sanitize fastq option.
- fastq_ingress now removes unclassified read folders by default.
- Workflow name and version is now more prominently displayed on start

### Fixed
- Output argument in Fastqingress homogenised.
- Sanitize fastq intermittent null object error.
- Add `*.pyc` and `*.pyo` ignores to wf-template .gitignore

### Note
- Bumped version to `v4` to align versioning with Launcher v4

## [v0.2.0]
### Added
- default process label parameter
- Added `params.wf.example_cmd` list to populate `--help`

### Changed
- Update WorkflowMain.groovy to provide better `--help`

## [v0.1.0]
### Changed
- `sample_name` to `sample_id` throughout to mathc MinKNOW samplesheet.

### Added
- Singularity profile include in base config.
- Numerous other changes that have been lost to the mists of time.

## [v0.0.7]
### Added
- Fastqingress module for common handling of (possibly multiplexed) inputs.
- Optimized container size through removal of various conda cruft.

### Changed
- Use mamba by default for building conda environments.
- Cut down README to items specific to workflow.

### Fixed
- Incorrect specification of conda environment file in Nextflow config.

## [v0.0.6]
### Changed
- Explicitely install into base conda env

## [v0.0.5]
### Added
- Software versioning report example.

## [v0.0.4]
### Changed
- Version bump to test CI.

## [v0.0.3]
### Changed
- Moved all CI to templates.
- Use canned aplanat report components.

## [v0.0.2]
### Added
- CI release checks.
- Create pre-releases in CI from dev branch.

## [v0.0.1]
* First release.

