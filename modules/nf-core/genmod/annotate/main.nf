process GENMOD_ANNOTATE {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::genmod=3.7.4" : null)
    def container_image = "/genmod:3.7.4--pyh5e36f6f_0"
    container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }
n

    input:
    tuple val(meta), path(input_vcf)

    output:
    tuple val(meta), path("*_annotate.vcf"), emit: vcf
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    genmod \\
        annotate \\
        $args \\
        --outfile ${prefix}_annotate.vcf \\
        $input_vcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        genmod: \$(echo \$(genmod --version 2>&1) | sed 's/^.*genmod version: //' ))
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_annotate.vcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        genmod: \$(echo \$(genmod --version 2>&1) | sed 's/^.*genmod version: //' ))
    END_VERSIONS
    """
}
