process CNVKIT_ANTITARGET {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::cnvkit=0.9.9" : null)
    def container_image = "/cnvkit:0.9.9--pyhdfd78af_0"
    container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    tuple val(meta), path(targets)

    output:
    tuple val(meta), path("*.bed"), emit: bed
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    cnvkit.py \\
        antitarget \\
        $targets \\
        --output ${prefix}.antitarget.bed \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cnvkit: \$(cnvkit.py version | sed -e "s/cnvkit v//g")
    END_VERSIONS
    """
}
