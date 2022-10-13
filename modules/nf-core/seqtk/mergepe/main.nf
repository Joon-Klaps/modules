process SEQTK_MERGEPE {
    tag "$meta.id"
    label 'process_single'

    conda (params.enable_conda ? "bioconda::seqtk=1.3" : null)
    def container_image = "/seqtk:1.3--h5bf99c6_3"
                                                container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.fastq.gz"), emit: reads
    path "versions.yml"          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    if (meta.single_end) {
        """
        ln -s ${reads} ${prefix}.fastq.gz

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            seqtk: \$(echo \$(seqtk 2>&1) | sed 's/^.*Version: //; s/ .*\$//')
        END_VERSIONS
        """
    } else {
        """
        seqtk \\
            mergepe \\
            $args \\
            ${reads} \\
            | gzip -n >> ${prefix}.fastq.gz

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            seqtk: \$(echo \$(seqtk 2>&1) | sed 's/^.*Version: //; s/ .*\$//')
        END_VERSIONS
        """
    }
}
