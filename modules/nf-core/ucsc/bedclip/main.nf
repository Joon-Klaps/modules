process UCSC_BEDCLIP {
    tag "$meta.id"
    label 'process_medium'

    // WARN: Version information not provided by tool on CLI. Please update version string below when bumping container versions.
    conda (params.enable_conda ? "bioconda::ucsc-bedclip=377" : null)
        'https://depot.galaxyproject.org/singularity/ucsc-bedclip:377--h0b8a92a_2' :
        "${params.docker_registry ?: 'quay.io/biocontainers'}/ucsc-bedclip:377--h0b8a92a_2" }

    input:
    tuple val(meta), path(bedgraph)
    path  sizes

    output:
    tuple val(meta), path("*.bedGraph"), emit: bedgraph
    path "versions.yml"                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = '377' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    """
    bedClip \\
        $bedgraph \\
        $sizes \\
        ${prefix}.bedGraph

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ucsc: $VERSION
    END_VERSIONS
    """
}
