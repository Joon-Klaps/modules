process FASTQSCAN {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::fastq-scan=0.4.4" : null)
        'https://depot.galaxyproject.org/singularity/fastq-scan:0.4.4--h7d875b9_0' :
        "${params.docker_registry ?: 'quay.io/biocontainers'}/fastq-scan:0.4.4--h7d875b9_0" }

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.json"), emit: json
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    zcat $reads | \\
        fastq-scan \\
        $args > ${prefix}.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastqscan: \$( echo \$(fastq-scan -v 2>&1) | sed 's/^.*fastq-scan //' )
    END_VERSIONS
    """
}
