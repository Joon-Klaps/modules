process NEXTCLADE_RUN {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::nextclade=2.2.0" : null)
    def container_image = "/nextclade:2.2.0--h9ee0642_0"
                                                container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    tuple val(meta), path(fasta)
    path dataset

    output:
    tuple val(meta), path("${prefix}.csv")           , optional:true, emit: csv
    tuple val(meta), path("${prefix}.errors.csv")    , optional:true, emit: csv_errors
    tuple val(meta), path("${prefix}.insertions.csv"), optional:true, emit: csv_insertions
    tuple val(meta), path("${prefix}.tsv")           , optional:true, emit: tsv
    tuple val(meta), path("${prefix}.json")          , optional:true, emit: json
    tuple val(meta), path("${prefix}.auspice.json")  , optional:true, emit: json_auspice
    tuple val(meta), path("${prefix}.ndjson")        , optional:true, emit: ndjson
    tuple val(meta), path("${prefix}.aligned.fasta") , optional:true, emit: fasta_aligned
    tuple val(meta), path("*.translation.fasta")     , optional:true, emit: fasta_translation
    path "versions.yml"                              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    nextclade \\
        run \\
        $args \\
        --jobs $task.cpus \\
        --input-dataset $dataset \\
        --output-all ./ \\
        --output-basename ${prefix} \\
        $fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nextclade: \$(echo \$(nextclade --version 2>&1) | sed 's/^.*nextclade //; s/ .*\$//')
    END_VERSIONS
    """
}
