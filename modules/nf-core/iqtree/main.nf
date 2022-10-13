process IQTREE {
    tag "$alignment"
    label 'process_medium'

    conda (params.enable_conda ? 'bioconda::iqtree=2.1.4_beta' : null)
    def container_image = "/iqtree:2.1.4_beta--hdcc8f71_0"
    container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    path alignment
    val constant_sites

    output:
    path "*.treefile",    emit: phylogeny
    path "versions.yml" , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def fconst_args = constant_sites ? "-fconst $constant_sites" : ''
    def memory      = task.memory.toString().replaceAll(' ', '')
    """
    iqtree \\
        $fconst_args \\
        $args \\
        -s $alignment \\
        -nt AUTO \\
        -ntmax $task.cpus \\
        -mem $memory \\

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        iqtree: \$(echo \$(iqtree -version 2>&1) | sed 's/^IQ-TREE multicore version //;s/ .*//')
    END_VERSIONS
    """
}
