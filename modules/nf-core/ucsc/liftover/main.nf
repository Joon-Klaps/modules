process UCSC_LIFTOVER {
    tag "$meta.id"
    label 'process_low'

    // WARN: Version information not provided by tool on CLI. Please update version string below when bumping container versions.
    conda (params.enable_conda ? "bioconda::ucsc-liftover=377" : null)
        def container_image = "/ucsc-liftover:377--h0b8a92a_3"
                                                container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    tuple val(meta), path(bed)
    path(chain)

    output:
    tuple val(meta), path("*.lifted.bed")  , emit: lifted
    tuple val(meta), path("*.unlifted.bed"), emit: unlifted
    path "versions.yml"                    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = '377' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    """
    liftOver \\
        $args \
        $bed \\
        $chain \\
        ${prefix}.lifted.bed \\
        ${prefix}.unlifted.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ucsc: $VERSION
    END_VERSIONS
    """
}
