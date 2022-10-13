process SAMTOOLS_AMPLICONCLIP {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::samtools=1.15.1" : null)
    def container_image = "/samtools:1.15.1--h1170115_0"
                                                        container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    tuple val(meta), path(bam)
    path bed
    val save_cliprejects
    val save_clipstats

    output:
    tuple val(meta), path("*.bam")            , emit: bam
    tuple val(meta), path("*.clipstats.txt")  , optional:true, emit: stats
    tuple val(meta), path("*.cliprejects.bam"), optional:true, emit: rejects_bam
    path "versions.yml"                       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def rejects = save_cliprejects ? "--rejects-file ${prefix}.cliprejects.bam" : ""
    def stats   = save_clipstats   ? "-f ${prefix}.clipstats.txt"               : ""
    if ("$bam" == "${prefix}.bam") error "Input and output names are the same, use \"task.ext.prefix\" to disambiguate!"
    """
    samtools \\
        ampliconclip \\
        --threads ${task.cpus-1} \\
        $args \\
        $rejects \\
        $stats \\
        -b $bed \\
        -o ${prefix}.bam \\
        $bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}
