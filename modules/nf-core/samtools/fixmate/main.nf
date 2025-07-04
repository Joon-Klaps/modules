process SAMTOOLS_FIXMATE {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.21--h50ea8bc_0' :
        'biocontainers/samtools:1.21--h50ea8bc_0' }"

    input:
    tuple val(meta), path(input)

    output:
    tuple val(meta), path("${prefix}.bam") , emit: bam , optional: true
    tuple val(meta), path("${prefix}.cram"), emit: cram, optional: true
    tuple val(meta), path("${prefix}.sam") , emit: sam , optional: true
    path "versions.yml"                    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}_fixmate"
    def extension = args.contains("--output-fmt sam") ? "sam" :
                    args.contains("--output-fmt bam") ? "bam" :
                    args.contains("--output-fmt cram") ? "cram" :
                    "bam"
    if ("$input" == "${prefix}.${extension}") error "Input and output names are the same, use \"task.ext.prefix\" to disambiguate!"
    """
    # Note: --threads value represents *additional* CPUs to allocate (total CPUs = 1 + --threads).
    samtools \\
        fixmate  \\
        $args \\
        --threads ${task.cpus-1} \\
        $input \\
        ${prefix}.${extension} \\

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}_fixmate"
    def extension = args.contains("--output-fmt sam") ? "sam" :
                    args.contains("--output-fmt bam") ? "bam" :
                    args.contains("--output-fmt cram") ? "cram" :
                    "bam"
    if ("$input" == "${prefix}.${extension}") error "Input and output names are the same, use \"task.ext.prefix\" to disambiguate!"
    """
    touch ${prefix}.${extension}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}
