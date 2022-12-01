process CHECKV_UPDATEDATABASE {
    label 'process_low'

    conda (params.enable_conda ? "bioconda::checkv=1.0.1" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/checkv:1.0.1--pyhdfd78af_0':
        'quay.io/biocontainers/checkv:1.0.1--pyhdfd78af_0' }"

    input:
    tulpe val(meta), path (fasta)
    path db

    output:
    path "${prefix}/*"         , emit: checkv_db
    path "versions.yml"        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix    = task.ext.prefix ?: "${meta.id}"
    def checkv_db = db ?: ''
    def update_sequence = fasta ?: ''

    """
    checkv update_database \\
        -t $task.cpus \\
        $args \\
        $checkv_db \\
        ./$prefix/  \\
        $update_sequence \\

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        checkv: \$(checkv -h 2>&1  | sed -n 's/^.*CheckV v//; s/: assessing.*//; 1p')
    END_VERSIONS
    """

}
