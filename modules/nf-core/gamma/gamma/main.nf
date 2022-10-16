
process GAMMA_GAMMA {
    tag "$meta.id"
    label 'process_low'

    // WARN: Version information not provided by tool on CLI. Please update version string below when bumping container versions.
    conda (params.enable_conda ? "bioconda::gamma=2.1" : null)
    def container_image = "gamma:2.1--hdfd78af_0"
    container [ params.container_registry ?: 'quay.io/biocontainers' , container_image ].join('/')

    input:
    tuple val(meta), path(fasta)
    path(db)

    output:
    tuple val(meta), path("*.gamma")                , emit: gamma
    tuple val(meta), path("*.psl")                  , emit: psl
    tuple val(meta), path("*.gff")  , optional:true , emit: gff
    tuple val(meta), path("*.fasta"), optional:true , emit: fasta
    path "versions.yml"                             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = '2.1' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    """
    if [[ ${fasta} == *.gz ]]
    then
        FNAME=\$(basename ${fasta} .gz)
        gunzip -f ${fasta}
        GAMMA.py \\
        $args \\
        "\${FNAME}" \\
        $db \\
        $prefix
    else
        GAMMA.py \\
        $args \\
        $fasta \\
        $db \\
        $prefix
    fi
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gamma: $VERSION
    END_VERSIONS
    """
}
