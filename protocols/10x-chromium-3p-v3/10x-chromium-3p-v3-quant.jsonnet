local utils = std.extVar("__utils"); # system variable, DO NOT MODIFY
local output = if std.type(std.extVar("__output")) == "null" then error "The provided value to the system variable output was null, please avoid using it in the template." else std.extVar("__output");# system variable, DO NOT MODIFY
// 10X Chromium 3' v3 gene expression reads quantification
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

	# Output directory.
	output: output, # or output: "/path/to/output/dir" # this defines `simpleaf index/quant --output`
};

local template = {
	# meta info of the workflow
	fast_config : {
		##############
		# Fast config
		##############
		#-----------------------------------------------------------------------#
		# section 1 . provide the existing index directory
        # If you have the mapping results, skip this and provide mapping dir in the advanced_config/map_type section
        existing_index : {
            index : null, # e.g., "path/to/existing_index" # This defines `/workflow/simpleaf_quant/--index`
            t2g_map : null, # e.g., "path/to/existing_index/t2g.tsv" or "t2g_3col.tsv" # This defines `/workflow/simpleaf_quant/--t2g-map`
        },

		#-----------------------------------------------------------------------#
		# 2. provide comma separated read fastq files for mapping
        # If you have the mapping results, skip this and provide mapping dir in the advanced_config/map_type section
		map_reads : {
			reads1 : null, # e.g., "path/to/read1_1.fq.gz,path/to/read1_2.fq.gz" # This defines `simpleaf quant --reads1`
			reads2 : null, # e.g., "path/to/read2_1.fq.gz,path/to/read2_2.fq.gz" # This defines `simpleaf quant --reads2`
		},
	},

	#---------------------------------------------------------------------------#
	# ---- > If using default settings, stop here and run this template. < ---- #
	#---------------------------------------------------------------------------#

	##################
	# advanced config
	##################
	advanced_config : {
		simpleaf_index : {
		#-----------------------------------------------------------------------#
			# 1. reference options
			ref_type : {
                # DO NOT CHANGE
				type : "existing_index", 
			},

		#-----------------------------------------------------------------------#
			# 2. simpleaf index arguments
			# If no special requirements, please use the default arguments
			arguments : {	
				active : true, # if false, simpleaf index command will be skipped
				"--spliced" : null, # or "path/to/extra_spliced_sequences.fa"
				"--unspliced" : null, # or "path/to/extra_unspliced_sequences.fa"
				"--dedup" : false,
				"--sparse" : false,
				"--keep-duplicates" : false,
				"--gff3-fomrat" : false,
				"--threads" : $.meta_info.threads,
				"--use-piscem" : $.meta_info.use_piscem, 
				"--overwrite" : $.meta_info.use_piscem,
				"--kmer-length" :  31,
				"--minimizer-length" : utils.ml($.meta_info.use_piscem, std.get(self, "--kmer-length")), # a quick way to calculate minimizer length
				"--decoy-paths" : null, # only if using piscem >= 0.7
			},

		#-----------------------------------------------------------------------#
			# 3. provide simpleaf index output directory
			# If no special requirements, please use the default arguments
			output : $.meta_info.output + "/simpleaf_index",
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
				"--min-reads" : 10,
				"--resolution" :  "cr-like",
				"--expected-ori" :  "fw",
				"--threads" :  $.meta_info.threads,
				"--chemistry" :  "10xv3",
				"--use-selective-alignment" : false, # only if using salmon alevin as theunderlying mapper
				# piscem options
				"--use-piscem" : $.meta_info.use_piscem,
				"--struct-constraints" : false,
				"--ignore-ambig-hits" : false,
				"--no-poison" : false,
				"--skipping-strategy" : null, # Options : "strict" "permissive"
				"--max-ec-card" : null, # e.g., 4096
				"--max-hit-occ" : null, # e.g., 256
				"--max-hit-occ-recover" : null, # e.g., 1024
				"--max-read-occ" : null, # e.g., 2500
			},

			#----------------------------#
			# 4. provide simpleaf quant output directory
			# If no special requirements, please use the default arguments
			output : $.meta_info.output + "/simpleaf_quant",
		},
	},
	#----------------------------------------------------------------------------------------#
	# --- > NOTE : The following sections are ONLY for developers. < --- #
	#----------------------------------------------------------------------------------------#

	##########################################
	# do not modify anything below line
	##########################################
	meta_info : {
		template_name :  "10X Chromium 3' v3 gene expression quantification only",
		template_id : "10x-chromium-3p-v3-quant",
		template_version : "0.1.0",
	} + meta_info,
	
	workflow : {
		simpleaf_quant : utils.simpleaf_quant(
			1, 
			utils.map_type($.advanced_config.simpleaf_quant.map_type + $.fast_config, utils.existing_index($.fast_config.existing_index.index, $.fast_config.existing_index.t2g_map)),
			utils.cell_filt_type($.advanced_config.simpleaf_quant.cell_filt_type),
			$.advanced_config.simpleaf_quant.arguments, 
			$.advanced_config.simpleaf_quant.output,
		),
	},
};

template