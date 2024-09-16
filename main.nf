#!/usr/bin/env nextflow

import groovy.json.JsonBuilder
nextflow.enable.dsl = 2

include { fastq_ingress; xam_ingress } from './lib/ingress'
include { minimap_pipeline } from './wf-metagenomics/subworkflows/minimap_pipeline'
// standard kraken2
include { kraken_pipeline } from './wf-metagenomics/subworkflows/kraken_pipeline'
include { real_time_pipeline } from './wf-metagenomics/subworkflows/real_time_pipeline'
// databases
include { prepare_databases } from "./wf-metagenomics/modules/local/databases.nf"

nextflow.preview.recursion=true

// entrypoint workflow
WorkflowMain.initialise(workflow, params, log)
workflow {
    Pinguscript.ping_start(nextflow, workflow, params)

    dataDir = projectDir + '/data'

    // Ready the optional file
    OPTIONAL = file("$projectDir/data/OPTIONAL_FILE")


    // Checking user parameters
    log.info("Checking inputs.")

    // Check maximum and minimum length
    ArrayList fastcat_extra_args = []
    if (params.min_len) { fastcat_extra_args << "-a $params.min_len" }
    if (params.max_len) { fastcat_extra_args << "-b $params.max_len" }
    if (params.min_read_qual) { fastcat_extra_args << "-q $params.min_read_qual" }
    // If BAM files are output, keep runIDs in case they are reused in the wf to track them.
    boolean keep_bam = (params.keep_bam || params.igv)
    if (keep_bam) {fastcat_extra_args << "-H"}

    // Check source param is valid
    sources = params.database_sets
    if (params.containsKey('include_kraken2_assignments')){
        throw new Exception("`include_kraken2_assignments` is now deprecated in favour of `include_read_assignments`.")
    }

    // Stop the pipeline in case not valid parameters combinations
    if (params.classifier == 'minimap2' && params.database) {
        throw new Exception("To use minimap2 with your custom database, you need to use `--reference` (instead of `--database`) and `--ref2taxid`.")
    }
    if ((params.classifier == 'kraken2' || params.real_time ) && params.reference) {
        throw new Exception("To use kraken2 with your custom database, you need to use `--database` (instead of `--reference`) and include the `bracken_dist` within it.")
    }
    if (params.classifier != 'kraken2' && params.real_time) {
        throw new Exception("Real time subworkflow must use kraken2 classifier.")
    }

    // If user provides each database, set to 'custom' the params.database_set
    if (params.reference || params.database) {
        source_name = 'custom'
        // distinguish between taxonomy and database to be able to use taxonomy default db in some cases.
        // this can be potentially risky but might be justified if the reference and ref2taxid use NCBI taxids.
        source_data_database = null
        source_name_taxonomy = params.database_set
        source_data_taxonomy = sources.get(source_name_taxonomy, false)
        log.info("Note: Reference/Database are custom.")
        log.info("Note: Memory available to the workflow must be slightly higher than size of the database $source_name index.")
        if (params.classifier == "kraken2"){
            log.info("Note: Or consider to use the --kraken2_memory_mapping.")
        }

    } 
    if(params.taxonomy){
        // this can be useful if the user wants to use a new taxonomy database (maybe updated) but the default reference.
        source_name = params.database_set
        source_data_database = sources.get(source_name, false)
        source_data_taxonomy = null
        log.info("Note: Taxonomy database is custom.")
    } else {
        source_name = params.database_set
        source_data_database = sources.get(source_name, false)
        source_data_taxonomy = sources.get(source_name, false)
        if (!sources.containsKey(source_name) || !source_data_database) {
            keys = sources.keySet()
            throw new Exception("Source $params.database_set is invalid, must be one of $keys")
        }
    }

    // Input data
    // real time wf still requires per-read-stats as it computes its own aggregated statistics
    // TODO: investigate chunk option for real time and use of histograms
    if (params.fastq) {
            samples = fastq_ingress([
                "input":params.fastq,
                "sample": params.real_time ? null : params.sample,
                "sample_sheet": params.real_time ? null : params.sample_sheet,
                "analyse_unclassified":params.analyse_unclassified,
                "stats": true,
                "fastcat_extra_args": fastcat_extra_args.join(" "),
                "watch_path": params.real_time,
                "per_read_stats": params.real_time ? true : false
            ])
    } else {
            // if we didn't get a `--fastq`, there must have been a `--bam` (as is codified
            // by the schema)
            samples = xam_ingress([
                "input":params.bam,
                "sample":params.sample,
                "sample_sheet":params.sample_sheet,
                "analyse_unclassified":params.analyse_unclassified,
                "return_fastq": true,
                "keep_unaligned": true,
                "stats": true,
                "watch_path": params.real_time,
                "per_read_stats": params.real_time ? true : false
            ])
    }
    

    // Discard empty samples
    log.info(
        "Note: Empty files or those files whose reads have been discarded after filtering based on " +
        "read length and/or read quality will not appear in the report and will be excluded from subsequent analysis.")
    samples = samples
    | filter { meta, seqs, stats ->
        valid = meta['n_seqs'] > 0
        if (!valid) {
            log.warn "Found empty file for sample '${meta["alias"]}'."
        }
        valid
    }

    // Set minimap2 common options
    ArrayList common_minimap2_opts = [
        "-ax map-ont",
        "--cap-kalloc 100m",
        "--cap-sw-mem 50m",
    ]

    // Call the proper pipeline
    if ("${params.classifier}" == "minimap2") {
        log.info("Minimap2 pipeline.")
        database = null
        kmer_dist = null
        if (keep_bam) {
            common_minimap2_opts = common_minimap2_opts + ["-y"]
        }
        databases_minimap2 = prepare_databases(
            source_data_taxonomy,
            source_data_database
        )
        results = minimap_pipeline(
            samples,
            databases_minimap2.reference,
            databases_minimap2.ref2taxid,
            databases_minimap2.taxonomy,
            databases_minimap2.taxonomic_rank,
            common_minimap2_opts,
            keep_bam
            )
    }

    // Handle getting kraken2 database files if kraken2 classifier selected
    if ("${params.classifier}" == "kraken2") {
        log.info("Kraken2 pipeline.")
        reference = null
        ref2taxid = null
        databases_kraken2 = prepare_databases(
                source_data_taxonomy,
                source_data_database
        )
        // check combination of params are set
        if (params.real_time){
            if (params.sample_sheet != null) {
                log.info("The `sample_sheet` parameter is not used in the real time mode.")
            }
            if (params.sample != null) {
                log.info("The `sample` parameter is not used in the real time mode.")
            }
            if (!params.read_limit){
                log.info("Workflow will run indefinitely as no read_limit is set.")
            }
            log.info("Workflow will stop processing files after ${params.read_limit} reads.")
        }

        // Distinguish between real time or not
       if (params.real_time) {
            results = real_time_pipeline(
                samples,
                databases_kraken2.taxonomy,
                databases_kraken2.database,
                databases_kraken2.bracken_length,
                databases_kraken2.taxonomic_rank,
                common_minimap2_opts
            )
        } else {
            results = kraken_pipeline(
                samples,
                databases_kraken2.taxonomy,
                databases_kraken2.database,
                databases_kraken2.bracken_length,
                databases_kraken2.taxonomic_rank,
                common_minimap2_opts
            )
        }

    }
}

workflow.onComplete {
    Pinguscript.ping_complete(nextflow, workflow, params)
}
workflow.onError {
    Pinguscript.ping_error(nextflow, workflow, params)
}
