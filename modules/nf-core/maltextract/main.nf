process MALTEXTRACT {

    label 'process_medium'

    conda (params.enable_conda ? "bioconda::hops=0.35" : null)
    def container_image = "/hops:0.35--hdfd78af_1"
    container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    path rma6
    path taxon_list
    path ncbi_dir

    output:
    path "results"      , emit: results
    path "versions.yml" , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    MaltExtract \\
        -Xmx${task.memory.toGiga()}g \\
        -p $task.cpus \\
        -i ${rma6.join(' ')} \\
        -t $taxon_list \\
        -r $ncbi_dir \\
        -o results/ \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        maltextract: \$(MaltExtract --help | head -n 2 | tail -n 1 | sed 's/MaltExtract version//')
    END_VERSIONS
    """
}
