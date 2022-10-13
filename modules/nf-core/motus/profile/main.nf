process MOTUS_PROFILE {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::motus=3.0.1" : null)
    def container_image = "/motus:3.0.1--pyhdfd78af_0"
    container { (params.container_registry ?: 'quay.io/biocontainers' + container_image) }

    input:
    tuple val(meta), path(reads)
    path db

    output:
    tuple val(meta), path("*.out"), emit: out
    tuple val(meta), path("*.bam"), optional: true, emit: bam
    tuple val(meta), path("*.mgc"), optional: true, emit: mgc
    tuple val(meta), path("*.log")                , emit: log
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def inputs = reads[0].getExtension() == 'bam' ?
                    "-i ${reads}" :
                    reads[0].getExtension() == 'mgc' ? "-m $reads" :
                        meta.single_end ?
                            "-s $reads" : "-f ${reads[0]} -r ${reads[1]}"
    def refdb = db ? "-db ${db}" : ""
    """
    motus profile \\
        $args \\
        $inputs \\
        $refdb \\
        -t $task.cpus \\
        -n $prefix \\
        -o ${prefix}.out \\
        2> ${prefix}.log

    ## mOTUs version number is not available from command line.
    ## mOTUs save the version number in index database folder.
    ## mOTUs will check the database version is same version as exec version.
    if [ "$db" == "" ]; then
        VERSION=\$(echo \$(motus -h 2>&1) | sed 's/^.*Version: //; s/References.*\$//')
    else
        VERSION=\$(grep motus $db/db_mOTU_versions | sed 's/motus\\t//g')
    fi
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        motus: \$VERSION
    END_VERSIONS
    """
}
