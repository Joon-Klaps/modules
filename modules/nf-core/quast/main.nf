process QUAST {
    label 'process_medium'

    conda (params.enable_conda ? 'bioconda::quast=5.2.0' : null)
    def container_image = "quast:5.2.0--py39pl5321h2add14b_1"
    container [ params.container_registry ?: 'quay.io/biocontainers' , container_image ].join('/')

    input:
    path consensus
    path fasta
    path gff
    val use_fasta
    val use_gff

    output:
    path "${prefix}"    , emit: results
    path '*.tsv'        , emit: tsv
    path "versions.yml" , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args   ?: ''
    prefix   = task.ext.prefix ?: 'quast'
    def features  = use_gff ? "--features $gff" : ''
    def reference = use_fasta ? "-r $fasta" : ''
    """
    quast.py \\
        --output-dir $prefix \\
        $reference \\
        $features \\
        --threads $task.cpus \\
        $args \\
        ${consensus.join(' ')}

    ln -s ${prefix}/report.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        quast: \$(quast.py --version 2>&1 | sed 's/^.*QUAST v//; s/ .*\$//')
    END_VERSIONS
    """
}
