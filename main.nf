#!/usr/bin/env nextflow

// Developer notes
//
// This template workflow provides a basic structure to copy in order
// to create a new workflow. Current recommended practices are:
//     i) create a simple command-line interface.
//    ii) include an abstract workflow scope named "pipeline" to be used
//        in a module fashion
//   iii) a second concrete, but anonymous, workflow scope to be used
//        as an entry point when using this workflow in isolation.

import groovy.json.JsonBuilder
nextflow.enable.dsl = 2

include { fastq_ingress } from './lib/fastqingress'

OPTIONAL_FILE = file("$projectDir/data/OPTIONAL_FILE")

process getVersions {
    label "wftemplate"
    cpus 1
    output:
        path "versions.txt"
    script:
    """
    python -c "import pysam; print(f'pysam,{pysam.__version__}')" >> versions.txt
    fastcat --version | sed 's/^/fastcat,/' >> versions.txt
    """
}


process getParams {
    label "wftemplate"
    cpus 1
    output:
        path "params.json"
    script:
        String paramsJSON = new JsonBuilder(params).toPrettyString()
    """
    # Output nextflow params object to JSON
    echo '$paramsJSON' > params.json
    """
}


process makeReport {
    label "wftemplate"
    input:
        val metadata
        path per_read_stats
        path "versions/*"
        path "params.json"
    output:
        path "wf-template-*.html"
    script:
        String report_name = "wf-template-report.html"
        String metadata = new JsonBuilder(metadata).toPrettyString()
        String stats_args = \
            (per_read_stats.name == OPTIONAL_FILE.name) ? "" : "--stats $per_read_stats"
    """
    echo '${metadata}' > metadata.json
    workflow-glue report $report_name \
        --versions versions \
        $stats_args \
        --params params.json \
        --metadata metadata.json
    """
}


// See https://github.com/nextflow-io/nextflow/issues/1636. This is the only way to
// publish files from a workflow whilst decoupling the publish from the process steps.
// The process takes a tuple containing the filename and the name of a sub-directory to
// put the file into. If the latter is `null`, puts it into the top-level directory.
process output {
    // publish inputs to output directory
    label "wftemplate"
    publishDir (
        params.out_dir,
        mode: "copy",
        saveAs: { dirname ? "$dirname/$fname" : fname }
    )
    input:
        tuple path(fname), val(dirname)
    output:
        path fname
    """
    """
}

// Creates a new directory named after the sample alias and moves the fastcat results
// into it.
process collectFastqIngressResultsInDir {
    label "wftemplate"
    input:
        // both the fastcat seqs as well as stats might be `OPTIONAL_FILE` --> stage in
        // different sub-directories to avoid name collisions
        tuple val(meta), path(concat_seqs, stageAs: "seqs/*"), path(fastcat_stats,
            stageAs: "stats/*")
    output:
        // use sub-dir to avoid name clashes (in the unlikely event of a sample alias
        // being `seq` or `stats`)
        path "out/*"
    script:
    String outdir = "out/${meta["alias"]}"
    String metaJson = new JsonBuilder(meta).toPrettyString()
    String concat_seqs = \
        (concat_seqs.fileName.name == OPTIONAL_FILE.name) ? "" : concat_seqs
    String fastcat_stats = \
        (fastcat_stats.fileName.name == OPTIONAL_FILE.name) ? "" : fastcat_stats
    """
    mkdir -p $outdir
    echo '$metaJson' > metamap.json
    mv metamap.json $concat_seqs $fastcat_stats $outdir
    """
}

// workflow module
workflow pipeline {
    take:
        reads
    main:
        per_read_stats = reads.map {
            it[2] ? it[2].resolve('per-read-stats.tsv') : null
        }
        | collectFile ( keepHeader: true )
        | ifEmpty ( OPTIONAL_FILE )
        software_versions = getVersions()
        workflow_params = getParams()
        metadata = reads.map { it[0] }.toList()
        report = makeReport(
            metadata, per_read_stats, software_versions.collect(), workflow_params
        )
        reads
        // replace `null` with path to optional file
        | map { [ it[0], it[1] ?: OPTIONAL_FILE, it[2] ?: OPTIONAL_FILE ] }
        | collectFastqIngressResultsInDir
    emit:
        fastq_ingress_results = collectFastqIngressResultsInDir.out
        report
        workflow_params
        // TODO: use something more useful as telemetry
        telemetry = workflow_params
}


// entrypoint workflow
WorkflowMain.initialise(workflow, params, log)
workflow {

    if (params.disable_ping == false) {
        Pinguscript.ping_post(workflow, "start", "none", params.out_dir, params)
    }

    // demo mutateParam
    if (params.containsKey("mutate_fastq")) {
        CWUtil.mutateParam(params, "fastq", params.mutate_fastq)
    }

    samples = fastq_ingress([
        "input":params.fastq,
        "sample":params.sample,
        "sample_sheet":params.sample_sheet,
        "analyse_unclassified":params.analyse_unclassified,
        "fastcat_stats": params.wf.fastcat_stats,
        "fastcat_extra_args": "",
        "required_sample_types": [] ])

    pipeline(samples)
    pipeline.out.fastq_ingress_results
    | map { [it, "fastq_ingress_results"] }
    | concat (
        pipeline.out.report.concat(pipeline.out.workflow_params)
        | map { [it, null] }
    )
    | output
}

if (params.disable_ping == false) {
    workflow.onComplete {
        Pinguscript.ping_post(workflow, "end", "none", params.out_dir, params)
    }

    workflow.onError {
        Pinguscript.ping_post(workflow, "error", "$workflow.errorMessage", params.out_dir, params)
    }
}
