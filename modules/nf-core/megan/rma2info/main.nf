process MEGAN_RMA2INFO {
    tag "$meta.id"
    label 'process_single'

    conda (params.enable_conda ? "bioconda::megan=6.21.7" : null)
        def container_image = "/megan:6.21.7--h9ee0642_0"
                                                 container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    tuple val(meta), path(rma6)
    val(megan_summary)

    output:
    tuple val(meta), path("*.txt.gz")               , emit: txt
    tuple val(meta), path("*.megan"), optional: true, emit: megan_summary
    path "versions.yml"                             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def summary = megan_summary ? "-es ${prefix}.megan" : ""
    """
    rma2info \\
        -i ${rma6} \\
        -o ${prefix}.txt.gz \\
        ${summary} \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        megan: \$(echo \$(rma2info 2>&1) | grep version | sed 's/.*version //g;s/, built.*//g')
    END_VERSIONS
    """
}
