process SNPSIFT_SPLIT {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::snpsift=4.3.1t" : null)
    def container_image = "/snpsift:4.3.1t--hdfd78af_3"
    container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }
n

    input:
    tuple val(meta), path(vcf)

    output:
    tuple val(meta), path("*.vcf"), emit: out_vcfs
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    if (meta.split) {
        """
        SnpSift \\
            split \\
            $args \\
            $vcf

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            snpsift: \$( echo \$(SnpSift split -h 2>&1) | sed 's/^.*version //' | sed 's/(.*//' | sed 's/t//g' )
        END_VERSIONS
        """
    } else {
        """
        SnpSift \\
            split \\
            -j \\
            $args \\
            $vcf \\
            > ${prefix}.joined.vcf

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            snpsift: \$( echo \$(SnpSift split -h 2>&1) | sed 's/^.*version //' | sed 's/(.*//' | sed 's/t//g' )
        END_VERSIONS
        """
    }

}
