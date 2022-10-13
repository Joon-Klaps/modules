process BAMCMP {
    label 'process_low'

    // WARN: Version information not provided by tool on CLI. Please update version string below when bumping container versions.
    conda (params.enable_conda ? "bioconda::bamcmp=2.2" : null)
    def container_image = "/bamcmp:2.2--h05f6578_0"
                                         container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    tuple val(meta), path(sample), path(contaminant)

    output:
    tuple val(meta), path("*primary.bam")      , emit: bam
    tuple val(meta), path("*contamination.bam"), emit: contamination_bam
    path "versions.yml"                        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = '2.2' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    """
    bamcmp \\
        -1 $sample \\
        -2 $contaminant \\
        -A ${prefix}_primary.bam \\
        -B ${prefix}_contamination.bam \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bamcmp: $VERSION
    END_VERSIONS
    """

}
