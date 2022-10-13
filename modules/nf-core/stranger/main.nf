process STRANGER {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::stranger=0.8.1" : null)
        def container_image = "/stranger:0.8.1--pyh5e36f6f_0"
                                           container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    tuple val(meta), path(vcf)
    path variant_catalog

    output:
    tuple val(meta), path("*.gz"), emit: vcf
    path "versions.yml"          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def options_variant_catalog = variant_catalog ? "--repeats-file $variant_catalog" : ""
    """
    stranger \\
        $args \\
        $vcf \\
        $options_variant_catalog | gzip --no-name > ${prefix}.vcf.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        stranger: \$( stranger --version )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.vcf.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        stranger: \$( stranger --version )
    END_VERSIONS
    """
}
