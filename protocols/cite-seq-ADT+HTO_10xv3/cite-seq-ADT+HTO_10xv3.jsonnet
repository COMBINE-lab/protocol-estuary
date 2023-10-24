local utils = std.extVar("__utils"); # system variable, DO NOT MODIFY
local output = if std.type(std.extVar("__output")) == "null" then error "The provided value to the system variable output was null, please avoid using it in the template." else std.extVar("__output");# system variable, DO NOT MODIFY
// CITE-seq ADT with 10x Chromium 3' v3 (TotalSeq-A chemistry)
// https://combine-lab.github.io/alevin-fry-tutorials/2023/simpleaf-piscem/
#############################################################################
# README:

# *IMPORTANT*: For most user, the sections in "template/fast_config" are the only things to complete.

# For example, you can complete the arguments for splici reference build by replacing the null value with a valid path to a gene GTF file.

# All fields that are null, empty array ([]), and empty dictionary ({}) will be pruned (ignored).

# NOTE: You can pass optional simpleaf arguments specified in the advanced-config and optional config sections.
#############################################################################

# meta_info contains meta information of the workflow
local meta_info = {
    # number of threads for all commands
    threads : 16, # change to other integer if needed # This defines `simpleaf index/quant --threads`

    # boolean, true or false
    use_piscem : false, # or use_piscem: false # This defines `simpleaf index/quant --use-piscem`

    # Output directory. Do not change if setting `--output` from command line
    output: output, # or output: "/path/to/output/dir" # this defines `simpleaf index/quant --output`
};

local template = {
	# meta info of the workflow
	fast_config : {
		##############
		# Fast config
		##############
        #-----------------------------------------------------------------------#
        # Fast config section 1 . gene expression modality
        gene_expression : {
            #-----------------------------------------------------------------------#
            # section 1.1 provide genome fasta and gtf files to build a splici index
            # For other ref types, please check the "advanced_config/ref_type" sections.
            splici : {
                gtf : null, # e.g., "path/to/genes.gtf" # This defines `/workflow/simpleaf_index/--gtf`
                fasta : null, # e.g., "path/to/genome.fa" # This defines `/workflow/simpleaf_index/--fasta`
                rlen : 98,  # This defines `/workflow/simpleaf_index/--rlen`
            },

            #-----------------------------------------------------------------------#
            # section 1.2 provide comma separated read fastq files for mapping
            map_reads : {
                reads1 : null, # e.g., "path/to/read1_1.fq.gz,path/to/read1_2.fq.gz" # This defines `simpleaf quant --reads1`
                reads2 : null, # e.g., "path/to/read2_1.fq.gz,path/to/read2_2.fq.gz" # This defines `simpleaf quant --reads2`
            },
        },
        #-----------------------------------------------------------------------#
        # Fast config section 2 . ADT modality
        ADT : {
            #-----------------------------------------------------------------------#
            # section 2.1 provide genome fasta and gtf files to build a splici index
            feature_barcode_csv : null, # REQUIRED

            #-----------------------------------------------------------------------#
            # section 2.2 provide comma separated read fastq files for mapping
            map_reads : {
                reads1 : null, # e.g., "path/to/read1_1.fq.gz,path/to/read1_2.fq.gz" # This defines `simpleaf quant --reads1`
                reads2 : null, # e.g., "path/to/read2_1.fq.gz,path/to/read2_2.fq.gz" # This defines `simpleaf quant --reads2`
            },
        },
        #-----------------------------------------------------------------------#
        # Fast config section 3 . HTO modality
        HTO : {
            #-----------------------------------------------------------------------#
            # section 3.1 provide genome fasta and gtf files to build a splici index
            feature_barcode_csv : null, # REQUIRED

            #-----------------------------------------------------------------------#
            # section 3.2 provide comma separated read fastq files for mapping
            map_reads : {
                reads1 : null, # e.g., "path/to/read1_1.fq.gz,path/to/read1_2.fq.gz" # This defines `simpleaf quant --reads1`
                reads2 : null, # e.g., "path/to/read2_1.fq.gz,path/to/read2_2.fq.gz" # This defines `simpleaf quant --reads2`
            },
        },
	},

	#---------------------------------------------------------------------------#
	# ---- > If using default settings, stop here and run this template. < ---- #
	#---------------------------------------------------------------------------#

	##################
	# Advanced config
	##################
	advanced_config : {
        #-----------------------------------------------------------------------#
        # Advanced config section 1 : gene expression modality
        gene_expression : {
            simpleaf_index : {
            #-----------------------------------------------------------------------#
                # section 1.1 reference options
                ref_type : {
                    # The arguments of the default option should be set in fast_config,
                    # For other options, select one from the following options and fill in the required arguments below
                    # "spliceu", "direct_ref" or "existing_index" 
                    type : "splici", 

                    # Option 1 : spliceu
                    spliceu : {
                        gtf : null, # e.g., "path/to/genes.gtf" # This defines `/workflow/simpleaf_index/--gtf`
                        fasta : null, # e.g., "path/to/genome.fa" # This defines `/workflow/simpleaf_index/--fasta`
                    },

                    # Option 2 : direct_ref
                    direct_ref : {
                        ref_seq : null, # e.g., "path/to/transcriptome.fa" # This defines `/workflow/simpleaf_index/--ref-seq`
                        t2g_map : null, # e.g., "path/to/existing_index/t2g.tsv" or "t2g_3col.tsv" # This defines `/workflow/simpleaf_quant/--t2g-map`

                    },

                    # Option 3 : existing_index
                    existing_index : {
                        map_dir : null, # e.g., "path/to/existing_index" # This defines `/workflow/simpleaf_quant/--index`
                        t2g_map : null, # e.g., "path/to/existing_index/t2g.tsv" or "t2g_3col.tsv" # This defines `/workflow/simpleaf_quant/--t2g-map`
                    },
                },

            #-----------------------------------------------------------------------#
                # section 1.2 simpleaf index arguments
                # If no special requirements, please use the default arguments
                arguments : {	
                    active : true, # if false, simpleaf index command will be skipped
                    "--spliced" : null,
                    "--unspliced" : null,
                    "--dedup" : false,
                    "--sparse" : false,
                    "--keep-duplicates" : false,
                    "--threads" : $.meta_info.threads,
                    "--use-pisem" : $.meta_info.use_piscem, 
                    "--overwrite" : $.meta_info.use_piscem,
                    "--kmer-length" :  31,
                    "--minimizer-length" : utils.ml($.meta_info.use_piscem, std.get(self, "--kmer-length")), # a quick way to calculate minimizer length
                },

            #-----------------------------------------------------------------------#
                # section 1.3 provide simpleaf index output directory
                # If no special requirements, please use the default arguments
                output : $.meta_info.output + "/gene_expression/simpleaf_index",
            },

            simpleaf_quant : {
            #-----------------------------------------------------------------------#
                # section 1.4 mapping options
                map_type : {
                    # The arguments of the default option should be set in fast_config,
                    # For other options, select one from the following options and fill in the required arguments below
                    type : "map_reads", # "existing_mappings"
                    existing_mappings : {
                        map_dir : null, # e.g., "path/to/existing_mappings" # This defines `simpleaf quant --map-dir`
                        t2g_map : null, # e.g., "path/to/existing_mappings/t2g.tsv" or "t2g_3col.tsv" # This defines `simpleaf quant --t2g-map`
                    },
                },

            #-----------------------------------------------------------------------#
                # section 1.5 provide cell filter strategy
                cell_filt_type : {
                    # The arguments of the default option has been set,
                    # For other options, select one from the following options and fill in the required arguments below
                    # "unfiltered_pl", "knee", "expect_cells", "forced_cells", or "explicit_pl"
                    type : "unfiltered_pl", # "existing_cell_filt"
                    
                    unfiltered_pl : true, # or unfiltered_pl : "path/to/whitelist" # This defines `simpleaf quant --unfiltered-pl`
                    knee : false, # or knee : true  # This defines `simpleaf quant --knee`
                    expect_cells : null, # e.g., 10000 # This defines `simpleaf quant --expect-cells`
                    forced_cells : null, # e.g., 10000 # This defines `simpleaf quant --forced-cells`
                    explicit_pl : null,  # e.g., "path/to/whitelist" # This defines `simpleaf quant --explicit-pl`
                },

            #-----------------------------------------------------------------------#
                # section 1.6 provide simpleaf quant arguments
                # If no special requirements, please use the default arguments
                arguments : {
                    active : true,
                    "--min-reads" : null,
                    "--resolution" :  "cr-like",
                    "--expected-ori" :  "fw",
                    "--threads" :  $.meta_info.threads,
                    "--use-piscem" : $.meta_info.use_piscem,
                    "--chemistry" :  "10xv3",
                },

                #----------------------------#
                # section 1.7 provide simpleaf quant output directory
                # If no special requirements, please use the default arguments
                output : $.meta_info.output + "/gene_expression/simpleaf_quant",
            },
        },

        #-----------------------------------------------------------------------#
        # Advanced config section 2 : ADT modality
        ADT : {
            simpleaf_index : {

            #-----------------------------------------------------------------------#
                # section 2.1 reference options
                ref_type : {
                    # The arguments of the default option should be set in fast_config,
                    # For other options, select one from the following options and fill in the required arguments below
                    # "spliceu", "direct_ref" or "existing_index" 
                    type : "direct_ref", 

                    # Option 1 : direct_ref
                    # DO NOT change unless you have a 
                    direct_ref : {
                        ref_seq : $.workflow.external_commands.ADT_feature_barcode_ref.ref_seq, # e.g., "path/to/transcriptome.fa" # This defines `/workflow/simpleaf_index/--ref-seq`
                        t2g_map : $.workflow.external_commands.ADT_feature_barcode_ref.t2g_map, # e.g., "path/to/existing_index/t2g.tsv" or "t2g_3col.tsv" # This defines `/workflow/simpleaf_quant/--t2g-map`
                    },

                    # Option 2 : existing_index
                    existing_index : {
                        map_dir : null, # e.g., "path/to/existing_index" # This defines `/workflow/simpleaf_quant/--index`
                        t2g_map : null, # e.g., "path/to/existing_index/t2g.tsv" or "t2g_3col.tsv" # This defines `/workflow/simpleaf_quant/--t2g-map`
                    },
                },

            #-----------------------------------------------------------------------#
                # section 2.2 simpleaf index arguments
                # If no special requirements, please use the default arguments
                arguments : {	
                    active : true, # if false, simpleaf index command will be skipped
                    "--sparse" : false,
                    "--keep-duplicates" : false,
                    "--threads" : $.meta_info.threads,
                    "--use-pisem" : $.meta_info.use_piscem, 
                    "--overwrite" : $.meta_info.use_piscem,
                    "--kmer-length" :  7,
                    "--minimizer-length" : utils.ml($.meta_info.use_piscem, std.get(self, "--kmer-length")), # a quick way to calculate minimizer length
                },

            #-----------------------------------------------------------------------#
                # section 2.3 provide simpleaf index output directory
                # If no special requirements, please use the default arguments
                output : $.meta_info.output + "/ADT/simpleaf_index",
            },

            simpleaf_quant : {
            #-----------------------------------------------------------------------#
                # section 2.4 mapping options
                map_type : {
                    # The arguments of the default option should be set in fast_config,
                    # For other options, select one from the following options and fill in the required arguments below
                    type : "map_reads", # "existing_mappings"

                    existing_mappings : {
                        map_dir : null, # e.g., "path/to/existing_mappings" # This defines `simpleaf quant --map-dir`
                        t2g_map : null, # e.g., "path/to/existing_mappings/t2g.tsv" or "t2g_3col.tsv" # This defines `simpleaf quant --t2g-map`
                    },
                },

            #-----------------------------------------------------------------------#
                # section 2.5 provide cell filter strategy
                cell_filt_type : {
                    # The arguments of the default option has been set,
                    # For other options, select one from the following options and fill in the required arguments below
                    # "unfiltered_pl", "knee", "expect_cells", "forced_cells", or "explicit_pl"
                    type : "explicit_pl",
                    
                    explicit_pl : $.workflow.gene_expression.simpleaf_quant.output + "/af_quant/alevin/quants_mat_rows.txt",   # This defines `simpleaf quant --explicit-pl`
                    unfiltered_pl : true, # or unfiltered_pl : "path/to/whitelist" # This defines `simpleaf quant --unfiltered-pl`
                    knee : false, # or knee : true  # This defines `simpleaf quant --knee`
                    expect_cells : null, # e.g., 10000 # This defines `simpleaf quant --expect-cells`
                    forced_cells : null, # e.g., 10000 # This defines `simpleaf quant --forced-cells`
                },

            #-----------------------------------------------------------------------#
                # section 2.6 provide simpleaf quant arguments
                # If no special requirements, please use the default arguments
                arguments : {
                    active : true,
                    "--min-reads" : null,
                    "--resolution" :  "cr-like",
                    "--expected-ori" :  "fw",
                    "--threads" :  $.meta_info.threads,
                    "--use-piscem" : $.meta_info.use_piscem,
                    "--chemistry" :  "1{b[16]u[12]}2{r[15]}",
                },

                #----------------------------#
                # section 2.7 : provide simpleaf quant output directory
                # If no special requirements, please use the default arguments
                output : $.meta_info.output + "/ADT/simpleaf_quant",
            },
        },

        #-----------------------------------------------------------------------#
        # Advanced config section 3 : HTO modality
        HTO : {
            simpleaf_index : {

            #-----------------------------------------------------------------------#
                # section 3.1 reference options
                ref_type : {
                    # The arguments of the default option should be set in fast_config,
                    # For other options, select one from the following options and fill in the required arguments below
                    # "spliceu", "direct_ref" or "existing_index" 
                    type : "direct_ref", 

                    # Option 1 : direct_ref
                    # DO NOT change unless you have a 
                    direct_ref : {
                        ref_seq : $.workflow.external_commands.HTO_feature_barcode_ref.ref_seq, # e.g., "path/to/transcriptome.fa" # This defines `/workflow/simpleaf_index/--ref-seq`
                        t2g_map : $.workflow.external_commands.HTO_feature_barcode_ref.t2g_map, # e.g., "path/to/existing_index/t2g.tsv" or "t2g_3col.tsv" # This defines `/workflow/simpleaf_quant/--t2g-map`
                    },

                    # Option 2 : existing_index
                    existing_index : {
                        map_dir : null, # e.g., "path/to/existing_index" # This defines `/workflow/simpleaf_quant/--index`
                        t2g_map : null, # e.g., "path/to/existing_index/t2g.tsv" or "t2g_3col.tsv" # This defines `/workflow/simpleaf_quant/--t2g-map`
                    },
                },

            #-----------------------------------------------------------------------#
                # section 3.2 simpleaf index arguments
                # If no special requirements, please use the default arguments
                arguments : {	
                    active : true, # if false, simpleaf index command will be skipped
                    "--sparse" : false,
                    "--keep-duplicates" : false,
                    "--threads" : $.meta_info.threads,
                    "--use-pisem" : $.meta_info.use_piscem, 
                    "--overwrite" : $.meta_info.use_piscem,
                    "--kmer-length" :  7,
                    "--minimizer-length" : utils.ml($.meta_info.use_piscem, std.get(self, "--kmer-length")), # a quick way to calculate minimizer length
                },

            #-----------------------------------------------------------------------#
                # section 3.3 provide simpleaf index output directory
                # If no special requirements, please use the default arguments
                output : $.meta_info.output + "/HTO/simpleaf_index",
            },

            simpleaf_quant : {
            #-----------------------------------------------------------------------#
                # section 3.4 mapping options
                map_type : {
                    # The arguments of the default option should be set in fast_config,
                    # For other options, select one from the following options and fill in the required arguments below
                    type : "map_reads", # "existing_mappings"

                    existing_mappings : {
                        map_dir : null, # e.g., "path/to/existing_mappings" # This defines `simpleaf quant --map-dir`
                        t2g_map : null, # e.g., "path/to/existing_mappings/t2g.tsv" or "t2g_3col.tsv" # This defines `simpleaf quant --t2g-map`
                    },
                },

            #-----------------------------------------------------------------------#
                # section 3.5 provide cell filter strategy
                cell_filt_type : {
                    # The arguments of the default option has been set,
                    # For other options, select one from the following options and fill in the required arguments below
                    # "unfiltered_pl", "knee", "expect_cells", "forced_cells", or "explicit_pl"
                    type : "explicit_pl",
                    
                    explicit_pl : $.workflow.gene_expression.simpleaf_quant.output + "/af_quant/alevin/quants_mat_rows.txt",   # This defines `simpleaf quant --explicit-pl`
                    unfiltered_pl : true, # or unfiltered_pl : "path/to/whitelist" # This defines `simpleaf quant --unfiltered-pl`
                    knee : false, # or knee : true  # This defines `simpleaf quant --knee`
                    expect_cells : null, # e.g., 10000 # This defines `simpleaf quant --expect-cells`
                    forced_cells : null, # e.g., 10000 # This defines `simpleaf quant --forced-cells`
                },

            #-----------------------------------------------------------------------#
                # section 3.6 provide simpleaf quant arguments
                # If no special requirements, please use the default arguments
                arguments : {
                    active : true,
                    "--min-reads" : null,
                    "--resolution" :  "cr-like",
                    "--expected-ori" :  "fw",
                    "--threads" :  $.meta_info.threads,
                    "--use-piscem" : $.meta_info.use_piscem,
                    "--chemistry" :  "1{b[16]u[12]}2{r[15]}",
                },

                #----------------------------#
                # section 3.7 : provide simpleaf quant output directory
                # If no special requirements, please use the default arguments
                output : $.meta_info.output + "/HTO/simpleaf_quant",
            },
        },
	},
	#----------------------------------------------------------------------------------------#
	# --- > NOTE : The following sections are ONLY for developers. < --- #
	#----------------------------------------------------------------------------------------#

	##########################################
	# do not modify anything below line
	##########################################
	meta_info : {
        template_name :  "CITE-seq ADT with 10x Chromium 3' v3 (TotalSeq-A chemistry)",
        template_id : "cite-seq-ADT_10xv3",
        template_version : "0.0.4",
	} + meta_info,
	
	workflow : {
        gene_expression : {
            [if $.advanced_config.gene_expression.simpleaf_index.type != "existing_index" || $.advanced_config.gene_expression.simpleaf_quant.map_type != "existing_mappings" then "simpleaf_index"] : utils.simpleaf_index(
                1, 
                utils.ref_type($.advanced_config.gene_expression.simpleaf_index.ref_type + $.fast_config.gene_expression), 
                $.advanced_config.gene_expression.simpleaf_index.arguments, 
                $.advanced_config.gene_expression.simpleaf_index.output,
            ),

            simpleaf_quant : utils.simpleaf_quant(
                2, 
                utils.map_type($.advanced_config.gene_expression.simpleaf_quant.map_type + $.fast_config.gene_expression, $.workflow.gene_expression.simpleaf_index),
                utils.cell_filt_type($.advanced_config.gene_expression.simpleaf_quant.cell_filt_type),
                $.advanced_config.gene_expression.simpleaf_quant.arguments, 
                $.advanced_config.gene_expression.simpleaf_quant.output,
            ),
        },
        ADT : {        
            [if $.advanced_config.ADT.simpleaf_index.type != "existing_index" || $.advanced_config.ADT.simpleaf_quant.map_type != "existing_mappings" then "simpleaf_index"] : utils.simpleaf_index(
                6, 
                utils.ref_type($.advanced_config.ADT.simpleaf_index.ref_type), 
                $.advanced_config.ADT.simpleaf_index.arguments, 
                $.advanced_config.ADT.simpleaf_index.output,
            ),

            simpleaf_quant : utils.simpleaf_quant(
                7, 
                utils.map_type($.advanced_config.ADT.simpleaf_quant.map_type + $.fast_config.ADT, $.workflow.ADT.simpleaf_index),
                utils.cell_filt_type($.advanced_config.ADT.simpleaf_quant.cell_filt_type),
                $.advanced_config.ADT.simpleaf_quant.arguments, 
                $.advanced_config.ADT.simpleaf_quant.output,
            ),
        },
        HTO : {        
            [if $.advanced_config.HTO.simpleaf_index.type != "existing_index" || $.advanced_config.HTO.simpleaf_quant.map_type != "existing_mappings" then "simpleaf_index"] : utils.simpleaf_index(
                11, 
                utils.ref_type($.advanced_config.HTO.simpleaf_index.ref_type), 
                $.advanced_config.HTO.simpleaf_index.arguments, 
                $.advanced_config.HTO.simpleaf_index.output,
            ),

            simpleaf_quant : utils.simpleaf_quant(
                12, 
                utils.map_type($.advanced_config.HTO.simpleaf_quant.map_type + $.fast_config.HTO, $.workflow.HTO.simpleaf_index),
                utils.cell_filt_type($.advanced_config.HTO.simpleaf_quant.cell_filt_type),
                $.advanced_config.HTO.simpleaf_quant.arguments, 
                $.advanced_config.HTO.simpleaf_quant.output,
            ),
        },
        external_commands : {
            [if $.fast_config.ADT.feature_barcode_csv != null then "ADT_feature_barcode_ref"] : utils.feature_barcode_ref(
                3,
                $.fast_config.ADT.feature_barcode_csv, 
                1,
                4,
                $.advanced_config.ADT.simpleaf_index.output
            ),
            [if $.fast_config.HTO.feature_barcode_csv != null then "HTO_feature_barcode_ref"] : utils.feature_barcode_ref(
                8,
                $.fast_config.HTO.feature_barcode_csv, 
                1,
                4,
                $.advanced_config.HTO.simpleaf_index.output
            ),
        }
	},
};

template