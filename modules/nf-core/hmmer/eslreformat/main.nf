process HMMER_ESLREFORMAT {
    tag "$meta.id"
    label 'process_single'

    conda (params.enable_conda ? "bioconda::hmmer=3.3.2" : null)
    def container_image = "hmmer:3.3.2--h1b792b2_1"
    container [ params.container_registry ?: 'quay.io/biocontainers' , container_image ].join('/')

    input:
    tuple val(meta), path(seqfile)

    output:
    tuple val(meta), path("*.*.gz"), emit: seqreformated
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args     = task.ext.args ?: ''
    def prefix   = task.ext.prefix ?: "${meta.id}"
    def suffix   = args ? args.trim().tokenize(" ")[-1] : "sequences"
    // Use for any postprocessing of the sequence file, e.g. removal of gap characters
    def postproc = task.ext.postprocessing ?: ""
    """
    esl-reformat \\
        $args \\
        $seqfile \\
        $postproc \\
        | gzip -c > ${prefix}.${suffix}.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hmmer/easel: \$(esl-reformat -h | grep -o '^# Easel [0-9.]*' | sed 's/^# Easel *//')
    END_VERSIONS
    """
}
