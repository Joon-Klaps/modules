#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { KRAKEN2_BUILD } from '../../../../../modules/nf-core/kraken2/build/main.nf'

workflow test_kraken2_build {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    KRAKEN2_BUILD ( input )
}
