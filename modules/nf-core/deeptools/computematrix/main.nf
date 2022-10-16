process DEEPTOOLS_COMPUTEMATRIX {
    tag "$meta.id"
    label 'process_high'

    conda (params.enable_conda ? 'bioconda::deeptools=3.5.1' : null)
    def container_image = "deeptools:3.5.1--py_0"
    container [ params.container_registry ?: 'quay.io/biocontainers' , container_image ].join('/')

    input:
    tuple val(meta), path(bigwig)
    path  bed

    output:
    tuple val(meta), path("*.mat.gz") , emit: matrix
    tuple val(meta), path("*.mat.tab"), emit: table
    path  "versions.yml"              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    computeMatrix \\
        $args \\
        --regionsFileName $bed \\
        --scoreFileName $bigwig \\
        --outFileName ${prefix}.computeMatrix.mat.gz \\
        --outFileNameMatrix ${prefix}.computeMatrix.vals.mat.tab \\
        --numberOfProcessors $task.cpus

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        deeptools: \$(computeMatrix --version | sed -e "s/computeMatrix //g")
    END_VERSIONS
    """
}
