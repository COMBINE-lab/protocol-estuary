// 10x Chromium 3' v3 gene expression data processing
// https://combine-lab.github.io/alevin-fry-tutorials/2023/simpleaf-piscem/
#############################################################################
# README:

# *IMPORTANT*: For most user, the sections in "Required config" are the only things to complete.
# You must select one option from the options listed in each section. 

# For example, you can select `utils.spliceu()` in section 1, and fill in the required arguments.

# All fields that are null, empty array ([]), and empty dictionary ({}) will be pruned (ignored).

# NOTE: You can pass optional simpleaf arguments specified in the advanced-config and optional config sections.
#############################################################################
local utils = std.extVar("__utils"); # system variable, DO NOT MODIFY
local output = std.extVar("__output");# system variable, DO NOT MODIFY

# **For most users**, ONLY the information in the "recommended-config" section needs to be completed.
# For advanced usage, please check the "advanced-config" sections.
local template = {
	fast_config : {
		##############
		# Fast config
		##############
		# output directory
		# Do not change if setting `--output` from command line
		output: output, # or output: "/path/to/output/dir" # this defines `simpleaf index/quant --output`

		#-----------------------------------------------------------------------#
		# section 1 . provide genome fasta and gtf files to build a splici index
		# For other types, please check the "advanced_config" sections.
		splici : {
			gtf : "splici.gtf", # e.g., "path/to/genes.gtf" # This defines `/workflow/simpleaf_index/--gtf`
			fasta : "splici.fasta", # e.g., "path/to/genome.fa" # This defines `/workflow/simpleaf_index/--fasta`
			rlen : 91,  # This defines `/workflow/simpleaf_index/--rlen`
		}
		,

		#-----------------------------------------------------------------------#
		# 2. provide comma separated read fastq files for mapping
		map_reads : {
			reads1 : "reads1.fastq", # e.g., "path/to/read1_1.fq.gz,path/to/read1_2.fq.gz" # This defines `simpleaf quant --reads1`
			reads2 : "reads2.fastq", # e.g., "path/to/read2_1.fq.gz,path/to/read2_2.fq.gz" # This defines `simpleaf quant --reads2`
		},
	},

	#---------------------------------------------------------------------------#
	# ---- > If using default settings, stop here and run this template. < ---- #
	#---------------------------------------------------------------------------#

	##################
	# advanced config
	##################
	advanced_config : {
		# number of threads for all commands
		threads : 16, # change to other integer if needed # This defines `simpleaf index/quant --threads`

		# boolean, true or false
		use_piscem : false, # or use_piscem: false # This defines `simpleaf index/quant --use-piscem`

		simpleaf_index : {
		#-----------------------------------------------------------------------#
			# 1. reference options
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
				},

				# Option 3 : existing_index
				existing_index : {
					map_dir : null, # e.g., "path/to/existing_index" # This defines `/workflow/simpleaf_quant/--index`
					t2g_map : null, # e.g., "path/to/existing_index/t2g.tsv" or "t2g_3col.tsv" # This defines `/workflow/simpleaf_quant/--t2g-map`
				},
			},

		#-----------------------------------------------------------------------#
			# 2. simpleaf index arguments
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
			# 3. provide simpleaf index output directory
			# If no special requirements, please use the default arguments
			output : $.fast_config.output + "/simpleaf_index",
		},

		simpleaf_quant : {
		#-----------------------------------------------------------------------#
			# 4. mapping options
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
			# 5. provide cell filter strategy
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
			# 6. provide simpleaf quant arguments
			# If no special requirements, please use the default arguments
			arguments : {
				active : true,
				"--min-reads" : null,
				"--resolution" :  "cr-like",
				"--expected-ori" :  "fw",
				"--threads" :  $.advanced_config.threads,
				"--use-piscem" : $.advanced_config.use_piscem,
				"--chemistry" :  "10xv3",
			},

			#----------------------------#
			# 4. provide simpleaf quant output directory
			# If no special requirements, please use the default arguments
			output : $.fast_config.output + "/simpleaf_quant",
		},
	},
	#----------------------------------------------------------------------------------------#
	# --- > NOTE : The following sections are ONLY for developers. < --- #
	#----------------------------------------------------------------------------------------#

	##########################################
	# do not modify anything below line
	##########################################

	# meta info of the workflow
	meta_info : {
		template_name :  "10x Chromium 3' v3 gene expression",
		template_id : "10x-chromium-3p-v3",
		template_version : "0.0.3",
		threads : $.advanced_config.threads,
		use_piscem : $.advanced_config.use_piscem,
		output : $.fast_config.output,		
	},

	workflow : {
		simpleaf_index : utils.simpleaf_index(
			1, 
			utils.ref_type($.advanced_config.simpleaf_index.ref_type + $.fast_config), 
			$.advanced_config.simpleaf_index.arguments, 
			$.advanced_config.simpleaf_index.output,
		),

    simpleaf_quant : utils.simpleaf_quant(
			2, 
			utils.map_type($.advanced_config.simpleaf_quant.map_type + $.fast_config, $.workflow.simpleaf_index),
			utils.cell_filt_type($.advanced_config.simpleaf_quant.cell_filt_type),
			$.advanced_config.simpleaf_quant.arguments, 
			$.advanced_config.simpleaf_quant.output,
		),
	},
};

template