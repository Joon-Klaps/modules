process SRATOOLS_PREFETCH {
    tag "$id"
    label 'process_low'

    conda (params.enable_conda ? 'bioconda::sra-tools=2.11.0' : null)
    def container_image = "/sra-tools:2.11.0--pl5321ha49a11a_3"
    container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    tuple val(meta), val(id)
    path ncbi_settings

    output:
    tuple val(meta), path(id), emit: sra
    path 'versions.yml'      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    shell:
    args = task.ext.args ?: ''
    args2 = task.ext.args2 ?: '5 1 100'  // <num retries> <base delay in seconds> <max delay in seconds>
    template 'retry_with_backoff.sh'
}
