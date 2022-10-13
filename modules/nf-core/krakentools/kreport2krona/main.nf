process KRAKENTOOLS_KREPORT2KRONA {
    tag "$meta.id"
    label 'process_single'

    // WARN: Version information not provided by tool on CLI. Please update version string below when bumping container versions.
    conda (params.enable_conda ? "bioconda::krakentools=1.2" : null)
    def container_image = "/krakentools:1.2--pyh5e36f6f_0"
    container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    tuple val(meta), path(kreport)

    output:
    tuple val(meta), path("*.txt"), emit: txt
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = '1.2' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    """
    kreport2krona.py \\
        -r ${kreport} \\
        -o ${prefix}.txt \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        kreport2krona.py: ${VERSION}
    END_VERSIONS
    """
}
