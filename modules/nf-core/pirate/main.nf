process PIRATE {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::pirate=1.0.4 bioconda::perl-bioperl=1.7.2" : null)
        def container_image = "/pirate:1.0.4--hdfd78af_2"
                                         container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    tuple val(meta), path(gff)

    output:
    tuple val(meta), path("results/*")                                   , emit: results
    tuple val(meta), path("results/core_alignment.fasta"), optional: true, emit: aln
    path "versions.yml"                                                  , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    PIRATE \\
        $args \\
        --threads $task.cpus \\
        --input ./ \\
        --output results/

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pirate: \$( echo \$( PIRATE --version 2>&1) | sed 's/PIRATE //' )
    END_VERSIONS
    """
}
