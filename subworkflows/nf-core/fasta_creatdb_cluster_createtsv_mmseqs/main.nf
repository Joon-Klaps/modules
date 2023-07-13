include { MMSEQS_CREATEDB      } from '../../../modules/nf-core/mmseqs/createdb/main'
include { MMSEQS_CLUSTER     } from '../../../modules/nf-core/mmseqs/cluster/main'
include { MMSEQS_CREATETSV     } from '../../../modules/nf-core/mmseqs/createtsv/main'

workflow FASTA_CREATEDB_CLUSTER_CREATETSV_MMSEQS {

    take:
    sequence  // channel: [ val(meta), [ fasta/fastq ] ]

    main:

    ch_versions = Channel.empty()

    MMSEQS_CREATEDB ( sequence )
    ch_seq_db   = MMSEQS_CREATEDB.out.db
    ch_versions = ch_versions.mix(MMSEQS_CREATEDB.out.versions.first())

    MMSEQS_CLUSTER ( ch_seq_db )
    ch_cluster_db = MMSEQS_CLUSTER.out.cluster_db
    ch_versions   = ch_versions.mix(MMSEQS_CLUSTER.out.versions.first())

    MMSEQS_CREATETSV ( MMSEQS_CLUSTER.out.cluster_db, ch_seq_db, [[],[]] )
    ch_versions   = ch_versions.mix(MMSEQS_CREATETSV.out.versions.first())

    emit:
    input_db      = ch_seq_db                   // channel: [ val(meta), [ db_directory ] ]
    cluster_db    = ch_cluster_db               // channel: [ val(meta), [ db_directory ] ]
    tsv           = MMSEQS_CREATETSV.out.tsv    // channel: [ val(meta), [ tsv ] ]

    versions = ch_versions                     // channel: [ versions.yml ]
}

