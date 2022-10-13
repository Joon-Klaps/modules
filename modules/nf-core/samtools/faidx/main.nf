process SAMTOOLS_FAIDX {
    tag "$fasta"
    label 'process_single'

    conda (params.enable_conda ? "bioconda::samtools=1.15.1" : null)
        def container_image = "/samtools:1.15.1--h1170115_0"
                                                 container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path ("*.fai"), emit: fai
    tuple val(meta), path ("*.gzi"), emit: gzi, optional: true
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    samtools \\
        faidx \\
        $args \\
        $fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """

    stub:
    """
    touch ${fasta}.fai
    cat <<-END_VERSIONS > versions.yml

    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}
