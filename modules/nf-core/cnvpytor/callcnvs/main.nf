process CNVPYTOR_CALLCNVS {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::cnvpytor=1.2.1" : null)
    def container_image = "/cnvpytor:1.2.1--pyhdfd78af_0"
                                                    container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    tuple val(meta), path(pytor)
    val bin_sizes

    output:
    tuple val(meta), path("${pytor.baseName}.pytor")	, emit: pytor
    path "versions.yml"                                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def bins = bin_sizes ?: '1000'
    """
    cnvpytor \\
        -root $pytor \\
        -call $bin_sizes

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cnvpytor: \$(echo \$(cnvpytor --version 2>&1) | sed 's/CNVpytor //' )
    END_VERSIONS
    """

    stub:
    """
    touch ${pytor.baseName}.pytor

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cnvpytor: \$(echo \$(cnvpytor --version 2>&1) | sed 's/CNVpytor //' )
    END_VERSIONS
    """
}
