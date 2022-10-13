process GATK4_INTERVALLISTTOBED {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::gatk4=4.2.6.1" : null)
    def container_image = "/gatk4:4.2.6.1--hdfd78af_0"
    container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    tuple val(meta), path(intervals)

    output:
    tuple val(meta), path("*.bed"), emit: bed
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    def avail_mem = 3
    if (!task.memory) {
        log.info '[GATK IntervalListToBed] Available memory not known - defaulting to 3GB. Specify process memory requirements to change this.'
    } else {
        avail_mem = task.memory.giga
    }
    """
    gatk --java-options "-Xmx${avail_mem}g" IntervalListToBed \\
        --INPUT $intervals \\
        --OUTPUT ${prefix}.bed \\
        --TMP_DIR . \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk4: \$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
    END_VERSIONS
    """
}
