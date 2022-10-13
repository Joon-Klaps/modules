process WHAMG {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::wham=1.8.0" : null)
        def container_image = "/wham:1.8.0.1.2017.05.03--h8b12597_1"
                                        container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    tuple val(meta), path(bam), path(bai)
    path(fasta)

    output:
    tuple val(meta), path("*.vcf.gz"), emit: vcf
    path("*.txt")                    , emit: graph, optional: true
    path "versions.yml"              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    whamg \\
        -x $task.cpus \\
        -f $bam \\
        -a $fasta \\
        $args \\
        > ${prefix}.vcf

        gzip ${prefix}.vcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        whamg: \$(echo \$(whamg 2>&1 | grep Version | sed 's/^Version: v//; s/-.*\$//' ))
    END_VERSIONS
    """
}
