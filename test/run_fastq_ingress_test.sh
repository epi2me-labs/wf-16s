#!/bin/bash
set -exo pipefail

get-test_data-from-aws () {
    # get aws-cli
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip

    # get test data
    aws/dist/aws s3 cp --recursive --quiet \
        "$S3_TEST_DATA" \
        test_data_from_S3
}

fastq=$1
wf_output_dir=$2
sample_sheet=$3

# `fastq` and `wf_output_dir` are required
if ! [[ $# -eq 2 || $# -eq 3 ]]; then
    echo "Provide 2 or 3 arguments!" >&2
    exit 1
fi

# get test data from s3 if required
if [[ $fastq =~ ^s3:// ]]; then
    get-test_data-from-aws
    fastq="$PWD/test_data_from_S3/${fastq#*test_data/}"
    [[ -n $sample_sheet ]] &&
        sample_sheet="$PWD/test_data_from_S3/${sample_sheet#*test_data/}"
fi

# add CWD if paths are relative
[[ ( $fastq != /* ) ]] && fastq="$PWD/$fastq"
[[ ( $wf_output_dir != /* ) ]] && wf_output_dir="$PWD/$wf_output_dir"
[[ ( -n $sample_sheet ) && ( $sample_sheet != /* ) ]] &&
    sample_sheet="$PWD/$sample_sheet"

# add flags to parameters (need an array for `fastq` here as there might be spaces in
# the filename)
fastq=("--fastq" "$fastq")
wf_output_dir="--wf-output-dir $wf_output_dir"
[[ -n $sample_sheet ]] && sample_sheet="--sample_sheet $sample_sheet"

# get container hash from config
img_hash=$(grep 'common_sha.\?=' nextflow.config | grep -oE 'sha[0-9,a-f,A-F]+')

# run test
docker run -v "$PWD":"$PWD" \
    ontresearch/wf-common:"$img_hash" \
    python "$PWD"/test/test_fastq_ingress.py "${fastq[@]}" $wf_output_dir $sample_sheet
