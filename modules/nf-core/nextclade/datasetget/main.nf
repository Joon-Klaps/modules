process NEXTCLADE_DATASETGET {
    tag "$dataset"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::nextclade=2.2.0" : null)
    def container_image = "/nextclade:2.2.0--h9ee0642_0"
    container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    val dataset
    val reference
    val tag

    output:
    path "$prefix"     , emit: dataset
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${dataset}"
    def fasta = reference ? "--reference ${reference}" : ''
    def version = tag ? "--tag ${tag}" : ''
    """
    nextclade \\
        dataset \\
        get \\
        $args \\
        --name $dataset \\
        $fasta \\
        $version \\
        --output-dir $prefix

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nextclade: \$(echo \$(nextclade --version 2>&1) | sed 's/^.*nextclade //; s/ .*\$//')
    END_VERSIONS
    """
}
