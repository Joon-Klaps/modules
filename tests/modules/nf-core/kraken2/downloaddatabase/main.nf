#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { KRAKEN2_DOWNLOADDATABASE } from '../../../../../modules/nf-core/kraken2/downloaddatabase/main.nf'

workflow test_kraken2_downloaddatabase {
    
    input = file(params.test_data['sarscov2']['illumina']['test_single_end_bam'], checkIfExists: true)

    KRAKEN2_DOWNLOADDATABASE ( input )
}
