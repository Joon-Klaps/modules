#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { KRAKEN2_BUILD } from '../../../../../modules/nf-core/kraken2/build/main.nf'

workflow test_kraken2_build_library {

    KRAKEN2_BUILD ( 'viral', [] )
}

workflow test_kraken2_build_standard{

    KRAKEN2_BUILD ( [], true )
}
