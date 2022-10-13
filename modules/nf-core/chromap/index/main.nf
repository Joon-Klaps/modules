process CHROMAP_INDEX {
    tag "$fasta"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::chromap=0.2.1" : null)
    def container_image = "/chromap:0.2.1--hd03093a_0"
    container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    path fasta

    output:
    path "*.index"     , emit: index
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = fasta.baseName
    """
    chromap \\
        -i \\
        $args \\
        -t $task.cpus \\
        -r $fasta \\
        -o ${prefix}.index

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        chromap: \$(echo \$(chromap --version 2>&1))
    END_VERSIONS
    """
}
