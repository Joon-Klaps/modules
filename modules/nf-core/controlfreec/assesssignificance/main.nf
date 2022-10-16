process CONTROLFREEC_ASSESSSIGNIFICANCE {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::control-freec=11.6" : null)
    def container_image = "control-freec:11.6--h1b792b2_1"
    container [ params.container_registry ?: 'quay.io/biocontainers' , container_image ].join('/')

    input:
    tuple val(meta), path(cnvs), path(ratio)

    output:
    tuple val(meta), path("*.p.value.txt"), emit: p_value_txt
    path "versions.yml"                   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    cat \$(which assess_significance.R) | R --slave --args ${cnvs} ${ratio}

    mv *.p.value.txt ${prefix}.p.value.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        controlfreec: \$(echo \$(freec -version 2>&1) | sed 's/^.*Control-FREEC  //; s/:.*\$//' | sed -e "s/Control-FREEC v//g" )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.p.value.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        controlfreec: \$(echo \$(freec -version 2>&1) | sed 's/^.*Control-FREEC  //; s/:.*\$//' | sed -e "s/Control-FREEC v//g" )
    END_VERSIONS
    """
}
