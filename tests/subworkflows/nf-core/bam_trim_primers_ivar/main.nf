#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BAM_TRIM_PRIMERS_IVAR } from '../../../../subworkflows/nf-core/bam_trim_primers_ivar/main.nf'

workflow test_bam_trim_primers_ivar {
    
    input = file(params.test_data['sarscov2']['illumina']['test_single_end_bam'], checkIfExists: true)

    BAM_TRIM_PRIMERS_IVAR ( input )
}
