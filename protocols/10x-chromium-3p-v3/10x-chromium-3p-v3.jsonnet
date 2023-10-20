
// 10x Chromium 3' v3 gene expression data processing
// https://combine-lab.github.io/alevin-fry-tutorials/2023/simpleaf-piscem/
#############################################################################
# README:

# *IMPORTANT*: For most user, the fields in section "recommended_config" are the only things to complete.

# To modify an argument, please replace the Right hand side of each field (separated by `:`) with your value.
# For example, you can replace `output: null` in the meta_info section with `output: "/path/to/output/dir"`, and `threads: null` with `threads: 16`
# All fields that are null, empty array ([]), and empty dictionary ({}) will be pruned (ignored).

# NOTE: You can pass optional simpleaf arguments specified in the advanced-config and optional config sections.
#############################################################################
local utils = std.extVar("__utils"); # system variable, DO NOT MODIFY
local output = std.extVar("__output");# system variable, DO NOT MODIFY

# meta info for the workflow
local meta_info =  {
    template_name :  "10x Chromium 3' v3 gene expression",
    template_id : "10x-chromium-3p-v3",
    template_version : "0.0.3",
    
    # number of threads for all commands
    threads: null, # or threads : INT, for example, threads : 16  
    
    # output directory
    # default: `--output` arg in the command line
    output: output, # or output: "/path/to/output/dir"

    # boolean, true or false
    use_piscem: true, # or use_piscem: false
};

# **For most users**, ONLY the information in the "recommended-config" section needs to be completed.
# For advanced usage, please check the "advanced-config" sections.
local workflow = {
	##########################################
	# Information for running `simpleaf index`
	##########################################
	simpleaf_index_step_number :: 1, # step number: system variable, DO NOT MODIFY
	#------------------------------------------------#
	# 1 . select one of the follolwing reference type
	simpleaf_index_ref_type :: utils.splici(null, null, 91) # recommended
	# utils.splici("path/to/genome.fasta", "path/to/genes.gtf", read_length)
	# utils.spliceu("path/to/genome.fasta", "path/to/genes.gtf")
	# utils.direct_ref("path/to/transcriptome.fasta")
	# utils.existing_index("path/to/existing_index", "path/to/t2g_3col.tsv" | "path/to/t2g.tsv")
	,
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
			"--minimizer-length" : utils.ml(std.get(self, "--kmer-length")), # a quick way to calculate minimizer length
		}
	},
	#----------------------------#
	# 3. provide output directory
	simpleaf_index_output :: meta_info.output + "/simpleaf_index",

	##########################################
    # Information for running `simpleaf quant`
	##########################################
	simpleaf_quant_step_number :: 2, # step number: system variable, DO NOT MODIFY
	
	#-----------------------#
	# 1. select mapping type
	simpleaf_quant_map_type :: 
		utils.map_reads(null, null, $.simpleaf_index) # Recommended
		# utils.map_reads("path/to/R1_001.fastq,path/to/R1_002.fastq", "path/to/R2_001.fastq,path/to/R2_002.fastq", $.simpleaf_index)
		# utils.existing_mappings("path/to/existing_map_dir, path/to/t2g.tsv" | "path/to/t2g_3col.tsv")
	,

	#------------------------------#
	# 2. REQUIRED : select cell filtering type
	simpleaf_quant_cell_filt :: 
		utils.unfiltered_pl(true) # recommended
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
			"--t2g-map": null,
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
	simpleaf_quant_output :: meta_info.output + "/simpleaf_quant",

	# do not modify anything below line
	simpleaf_index : utils.simpleaf_index($.simpleaf_index_step_number, $.simpleaf_index_ref_type, $.simpleaf_index_arguments, $.simpleaf_index_output),
    simpleaf_quant : utils.simpleaf_quant($.simpleaf_quant_step_number, $.simpleaf_quant_map_type, $.simpleaf_quant_cell_filt, $.simpleaf_quant_arguments, $.simpleaf_quant_output),
};

std.prune({
	"meta-info": meta_info,
	workflow : workflow
})