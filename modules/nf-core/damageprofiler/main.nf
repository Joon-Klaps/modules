process DAMAGEPROFILER {
    tag "$meta.id"
    label 'process_single'

    conda (params.enable_conda ? "bioconda::damageprofiler=1.1" : null)
    def container_image = "damageprofiler:1.1--hdfd78af_2"
    container [ params.container_registry ?: 'quay.io/biocontainers' , container_image ].join('/')

    input:
    tuple val(meta), path(bam)
    path fasta
    path fai
    path specieslist

    output:
    tuple val(meta), path("${prefix}"), emit: results
    path  "versions.yml"              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args   ?: ''
    prefix   = task.ext.prefix ?: "${meta.id}"
    def reference    = fasta ? "-r $fasta" : ""
    def species_list = specieslist ? "-sf $specieslist" : ""
    """
    damageprofiler \\
        -i $bam \\
        -o $prefix/ \\
        $args \\
        $reference \\
        $species_list

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        damageprofiler: \$(damageprofiler -v | sed 's/^DamageProfiler v//')
    END_VERSIONS
    """
}
