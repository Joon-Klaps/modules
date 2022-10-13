process HMTNOTE {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::hmtnote=0.7.2" : null)
    def container_image = "/hmtnote:0.7.2--pyhdfd78af_0"
                                          container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    tuple val(meta), path(vcf)

    output:
    tuple val(meta), path("*_annotated.vcf"), emit: vcf
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    hmtnote \\
        annotate \\
        $vcf \\
        ${prefix}_annotated.vcf \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hmtnote: \$(echo \$(hmtnote --version 2>&1) | sed 's/^.*hmtnote, version //; s/Using.*\$//' ))
    END_VERSIONS
    """
    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_annotated.vcf
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hmtnote: \$(echo \$(hmtnote --version 2>&1) | sed 's/^.*hmtnote, version //; s/Using.*\$//' ))
    END_VERSIONS
    """
}
