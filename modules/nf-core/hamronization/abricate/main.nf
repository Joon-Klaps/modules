process HAMRONIZATION_ABRICATE {
    tag "$meta.id"
    label 'process_single'

    conda (params.enable_conda ? "bioconda::hamronization=1.1.1" : null)
    def container_image = "hamronization:1.1.1--pyhdfd78af_0"
    container [ params.container_registry ?: 'quay.io/biocontainers' , container_image ].join('/')

    input:
    tuple val(meta), path(report)
    val(format)
    val(software_version)
    val(reference_db_version)

    output:
    tuple val(meta), path("*.json"), optional: true, emit: json
    tuple val(meta), path("*.tsv") , optional: true, emit: tsv
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    hamronize \\
        abricate \\
        ${report} \\
        $args \\
        --format ${format} \\
        --analysis_software_version ${software_version} \\
        --reference_database_version ${reference_db_version} \\
        > ${prefix}.${format}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hamronization: \$(echo \$(hamronize --version 2>&1) | cut -f 2 -d ' ' )
    END_VERSIONS
    """
}
