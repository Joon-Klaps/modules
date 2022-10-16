process ISOSEQ3_REFINE {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::isoseq3=3.4.0" : null)
    def container_image = "isoseq3:3.4.0--0"
    container [ params.container_registry ?: 'quay.io/biocontainers' , container_image ].join('/')

    input:
    tuple val(meta), path(bam)
    path primers

    output:
    tuple val(meta), path("*.bam")                 , emit: bam
    tuple val(meta), path("*.bam.pbi")             , emit: pbi
    tuple val(meta), path("*.consensusreadset.xml"), emit: consensusreadset
    tuple val(meta), path("*.filter_summary.json") , emit: summary
    tuple val(meta), path("*.report.csv")          , emit: report
    path  "versions.yml"                           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    isoseq3 \\
        refine \\
        -j $task.cpus \\
        $args \\
        $bam \\
        $primers \\
        ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        isoseq3: \$( isoseq3 refine --version|sed 's/isoseq refine //'|sed 's/ (commit.\\+//' )
    END_VERSIONS
    """
}
