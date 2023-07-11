#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include {  } from '../../../../subworkflows/nf-core//main.nf'

workflow test_fasta_creatdb_cluster_createtsv_mmseqs {
    
    input = file(params.test_data['sarscov2']['illumina']['test_single_end_bam'], checkIfExists: true)

     ( input )
}
