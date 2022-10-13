process PRESEQ_LCEXTRAP {
    tag "$meta.id"
    label 'process_single'
    label 'error_ignore'

    conda (params.enable_conda ? "bioconda::preseq=3.1.2" : null)
    def container_image = "/preseq:3.1.2--h445547b_2"
    container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.lc_extrap.txt"), emit: lc_extrap
    tuple val(meta), path("*.log")          , emit: log
    path  "versions.yml"                    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def paired_end = meta.single_end ? '' : '-pe'
    """
    preseq \\
        lc_extrap \\
        $args \\
        $paired_end \\
        -output ${prefix}.lc_extrap.txt \\
        $bam
    cp .command.err ${prefix}.command.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        preseq: \$(echo \$(preseq 2>&1) | sed 's/^.*Version: //; s/Usage:.*\$//')
    END_VERSIONS
    """
}
