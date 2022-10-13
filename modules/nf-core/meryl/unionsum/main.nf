process MERYL_UNIONSUM {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::meryl=1.3" : null)
    def container_image = "/meryl:1.3--h87f3376_1"
                                                 container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    tuple val(meta), path(meryl_dbs)

    output:
    tuple val(meta), path("*.unionsum.meryldb"), emit: meryl_db
    path "versions.yml"                        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    meryl union-sum \\
        threads=$task.cpus \\
        $args \\
        output ${prefix}.unionsum.meryldb \\
        $meryl_dbs

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        meryl: \$( meryl --version |& sed 's/meryl //' )
    END_VERSIONS
    """
}
