
// 10x feature barcoding has two parts
// 1. Gene Expression
// 2. Antibody Capture
#############################################################################
# README:

# *IMPORTANT* : For most user, the fields in section "Recommended Configuration" are the only things to complete (replacing the nulls with your values).

# To modify an argument, please replace the Right hand side of each field (separated by `:`) with your value **wrapped in quotes**.
# For example, you can replace `"output" : null` in the meta_info section with `"output" : "/path/to/output/dir"`, and `"threads" : null` with `"threads" : "16"`

# All fields that are null, empty array ([]), and empty dictionary ({}) will be pruned (ignored).

# NOTE : You can pass optional simpleaf arguments specified in the "Optional Configuration" section.

#############################################################################

# meta info for the workflow
local meta_info =  {
    template_name : "10x Chromium 3' Feature Barcode CRISPR (TotalSeq-B/C)",
    template_id : "10x-feature-barcode-crispr_totalseq-b-c",
    template_version : "0.0.3",

    
    # number of threads for all commands
    threads : 16, # or threads : INT, for example, threads : 16  
    
    # output directory
    # default : `--output` arg in the command line
    output : output, # or output : "/path/to/output/dir"

    # boolean, true or false
    use_piscem : true, # or use_piscem : false
};

# **For most users**, ONLY the information in the "recommended-config" section needs to be completed.
# For advanced usage, please check the "advanced-config" sections.
local workflow = {
	##################
	# Required config
	##################
	#------------------------------------------------#
	# section 1 . gene expression modality
    gene_expression_arguments :: {
        #------------------------------------------------#
        # section 1.1 select one of the follolwing reference type
        simpleaf_index_ref_type :: utils.splici(null, null, 91) # recommended
        # utils.splici("path/to/genome.fasta", "path/to/genes.gtf", read_length)
        # utils.spliceu("path/to/genome.fasta", "path/to/genes.gtf")
        # utils.direct_ref("path/to/transcriptome.fasta")
        # utils.existing_index("path/to/existing_index", "path/to/t2g_3col.tsv" | "path/to/t2g.tsv")
        ,
  
        #-----------------------#
        # section 1.2 select mapping type
        simpleaf_quant_map_type :: 
            utils.map_reads(null, null, $.gene_expression.simpleaf_index) # Recommended
            # utils.map_reads("path/to/R1_001.fastq,path/to/R1_002.fastq", "path/to/R2_001.fastq,path/to/R2_002.fastq", $.simpleaf_index)
            # utils.existing_mappings("path/to/existing_map_dir, path/to/t2g.tsv" | "path/to/t2g_3col.tsv")
        ,

        #------------------------------#
        # section 1.3 select cell filtering type
        simpleaf_quant_cell_filt :: 
            utils.unfiltered_pl(true) # recommended
            # utils.unfiltered_pl("path/to/whitelist")
            # utils.knee()
            # utils.forced(forced_cell_nulber : int)
            # utils.expect(expected_cell_number : int)
            # utils.explicit_pl("path/to/whitelist")
        ,
    },
	#------------------------------------------------#
	# section 2 . antibody modality
    antibody_capture_arguments :: {
        #-----------------------#
        # 1. path to feature barcode csv file
        # https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/using/feature-bc-analysis#feature-ref 
        feature_barcode_csv :: null # REQUIRED
        // feature_barcode_csv :: "path/to/feature_barcode.csv",
        ,

        #---------------------#
        # 2. provide arguments
        # If no special requirements, please use the default arguments
        simpleaf_index_arguments :: {	
            active : true,
            optional_arguments : {
                "--sparse" : false,
                "--keep-duplicates" : false,
                "--threads" : meta_info.threads,
                "--use-pisem" : meta_info.use_piscem,
                "--overwrite" : meta_info.use_piscem,
                "--kmer-length" :  7,
                "--minimizer-length" : utils.ml(meta_info.use_piscem, std.get(self, "--kmer-length")), # a quick way to calculate minimizer length
            }
        },

        #----------------------------#
        # 3. provide output directory
        simpleaf_index_output :: meta_info.output + "/antibody_capture/simpleaf_index"
        ,

        ##########################################
        # Information for running `simpleaf quant`
        ##########################################        
        #-----------------------#
        # 1. select mapping type
        simpleaf_quant_map_type :: 
            utils.map_reads(null, null, $.antibody_capture.simpleaf_index) # Recommended
            # utils.map_reads("path/to/R1_001.fastq,path/to/R1_002.fastq", "path/to/R2_001.fastq,path/to/R2_002.fastq", $.simpleaf_index)
            # utils.existing_mappings("path/to/existing_map_dir, path/to/t2g.tsv" | "path/to/t2g_3col.tsv")
        ,

        #------------------------------#
        # 2. OPTIONAL : select cell filtering type
        simpleaf_quant_cell_filt :: 
            utils.explicit_pl($.external_commands.barcode_translation.quant_cb) # recommended
            # utils.unfiltered_pl("path/to/whitelist")
            # utils.knee()
            # utils.forced(forced_cell_nulber : int)
            # utils.expect(expected_cell_number : int)
            # utils.explicit_pl("path/to/whitelist")
        ,

        #---------------------#
        # 3. OPTIONAL : provide arguments
        # If no special requirements, please use the default arguments
        simpleaf_quant_arguments :: {
            active : true,
            optional_arguments : {
                "--chemistry" :  "1{b[16]u[12]}2{x[10]r[15]x:}",
                "--resolution" :  "cr-like",
                "--use-piscem" : meta_info.use_piscem,
                "--expected-ori" :  "fw",
                "--threads" :  meta_info.threads,
                "--min-reads" : null,
            }
        },

        #----------------------------#
        # 4. OPTIONAL : provide output directory
        # If no special requirements, please use the default arguments
        simpleaf_quant_output :: meta_info.output + "/gene_expression/simpleaf_quant",

    },

    gene_expression +: {
        #---------------------#
        # 2. provide arguments
        # If no special requirements, please use the default arguments
        simpleaf_index_arguments :: {	
            active : true,
            optional_arguments : {
                "--spliced" : null,
                "--unspliced" : null,
                "--dedup" : false,
                "--sparse" : false,
                "--keep-duplicates" : false,
                "--threads" : meta_info.threads,
                "--use-pisem" : meta_info.use_piscem,
                "--overwrite" : meta_info.use_piscem,
                "--kmer-length" :  31,
                "--minimizer-length" : utils.ml(meta_info.use_piscem, std.get(self, "--kmer-length")), # a quick way to calculate minimizer length
            }
        },

        #----------------------------#
        # 3. provide output directory
        simpleaf_index_output :: meta_info.output + "/gene_expression/simpleaf_index"
        ,

        #---------------------#
        # 3. OPTIONAL : provide arguments
        # If no special requirements, please use the default arguments
        simpleaf_quant_arguments :: {
            active : true,
            optional_arguments : {
                "--chemistry" :  "10xv3",
                "--resolution" :  "cr-like",
                "--use-piscem" : meta_info.use_piscem,
                "--expected-ori" :  "fw",
                "--threads" :  meta_info.threads,
                "--min-reads" : null,
            }
        },

        #----------------------------#
        # 4. OPTIONAL : provide output directory
        # If no special requirements, please use the default arguments
        simpleaf_quant_output :: meta_info.output + "/gene_expression/simpleaf_quant",
    },

    antibody_capture_arguments +: {

    }
    # do not modify anything below line
    gene_expression : {
        # do not modify anything below line
        simpleaf_index : utils.simpleaf_index(1, $.gene_expression_arguments.simpleaf_index_ref_type, $.gene_expression_arguments.simpleaf_index_arguments, $.gene_expression_arguments.simpleaf_index_output),

        simpleaf_quant : utils.simpleaf_quant(2, $.gene_expression_arguments.simpleaf_quant_map_type, $.gene_expression_arguments.simpleaf_quant_cell_filt, $.gene_expression_arguments.simpleaf_quant_arguments, $.gene_expression_arguments.simpleaf_quant_output),

    },
    antibody_capture : {
        # do not modify anything below line
        simpleaf_index : utils.simpleaf_index(1, $.external_commands.feature_barcode_ref.ref_type, $.antibody_capture_arguments.simpleaf_index_arguments, $.antibody_capture_arguments.simpleaf_index_output),

        simpleaf_quant : utils.simpleaf_quant(2, $.antibody_capture_arguments.simpleaf_quant_map_type, $.gene_expression_arguments.simpleaf_quant_cell_filt, $.antibody_capture_arguments.simpleaf_quant_arguments, $.antibody_capture_arguments.simpleaf_quant_output),
    },
    external_commands : {
        feature_barcode_ref : utils.feature_barcode_ref(3, $.antibody_capture_arguments.feature_barcode_csv, $.antibody_capture_arguments.simpleaf_index_output),
        barcode_translation : utils.barcode_translation(3, "https://github.com/10XGenomics/cellranger/raw/master/lib/python/cellranger/barcodes/translation/3M-february-2018.txt.gz", $.gene_expression_arguments.simpleaf_quant_output + "/af_quant/alevin/quants_mat_rows.txt", $.gene_expression_arguments.simpleaf_quant_output)
    }
    
};

std.prune({
	"meta-info": meta_info,
	workflow : workflow
})
