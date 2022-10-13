process CMSEQ_POLYMUT {
    tag "$meta.id"
    label 'process_low'

    // WARN: Version information not provided by tool on CLI. Please update version string below when bumping container versions.
    conda (params.enable_conda ? "bioconda::cmseq=1.0.4" : null)
    def container_image = "/cmseq:1.0.4--pyhb7b1952_0"
    container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    tuple val(meta), path(bam), path(bai), path(gff), path(fasta)

    output:
    tuple val(meta), path("*.txt"), emit: polymut
    path "versions.yml"                   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def fasta_refid = fasta ? "-c $fasta" : ""
    def sortindex = bai ? "" : "--sortindex"
    def VERSION = '1.0.4' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    """
    polymut.py \\
        $args \\
        $sortindex \\
        $fasta_refid \\
        --gff_file $gff \\
        $bam > ${prefix}.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cmseq: $VERSION
    END_VERSIONS
    """
}
