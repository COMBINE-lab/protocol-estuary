
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
	#Information for running `simpleaf index`
	simpleaf_index : simpleaf_index(
		# 1 . select one of the follolwing reference type
		utils.splici(null, null,91)
		# utils.splici("path/to/genome.fasta", "path/to/genes.gtf", read_length)
		# utils.spliceu("path/to/genome.fasta", "path/to/genes.gtf")
		# utils.direct_ref("path/to/transcriptome.fasta")
		# utils.existing_index("path/to/existing_index", "path/to/t2g_3col.tsv" | "path/to/t2g.tsv")
		,
		# 2. provide arguments
		{	
			active : true,
			step : 1,
			optional_arguments : {
				"--spliced" : null,
				"--unspliced" : null,
				"--threads" : meta_info.threads,
				"--dedup" : false,
				"--sparse" : false,
				"--use-pisem" : meta_info.use_piscem,
				"--overwrite" : meta_info.use_piscem,
				"--keep-duplicates" : false,
				"--kmer-length" :  31,
				"--minimizer-length" : utils.ml(std.get(self, "--kmer-length")), # a quick way to calculate minimizer length
			}
		},
		# 3. provide output directory
		meta_info.output + "/simpleaf_index/index"
	),
    #Information for running `simpleaf quant`
    simpleaf_quant : simpleaf_quant(
		# 1. select mapping type
		utils.map_reads(null, null, $.simpleaf_index)
		# utils.map_reads("path/to/R1_001.fastq,path/to/R1_002.fastq", "path/to/R2_001.fastq,path/to/R2_002.fastq", $.simpleaf_index)
		# utils.existing_mappings("path/to/existing_map_dir, path/to/t2g.tsv" | "path/to/t2g_3col.tsv")
		,

		# 2. select cell filtering type
		utils.unfiltered_pl(null)
		# utils.unfiltered_pl("path/to/whitelist")
		# utils.knee()
		# utils.forced(forced_cell_nulber : int)
		# utils.expect(expected_cell_number : int)
		# utils.explicit_pl("path/to/whitelist")
		,

		# 3. provide arguments
		{
			active : true,
			step : 2,
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
		# 4. provide output directory
		meta_info.output + "/simpleaf_quant"
	),
};

local advanced_config =  {
	simpleaf_index : {

		# splici, spliceu, or direct_ref
		reference_type : 'splici',

		ref_type : splici()



		splici : {
		"--fasta" : recommended_config.simpleaf_index.custom_ref_fasta,

		"--gtf" : recommended_config.simpleaf_index.custom_ref_gtf,

		"--rlen" : 91,
		},

		spliceu: {
			# spliced + unspliced transcriptome
			# https : //pyroe.readthedocs.io/en/latest/building_splici_index.html#preparing-a-spliced-unspliced-transcriptome-reference
			"--ref-type" : "spliceu",
			# The path to the genome FASTA file
			"--fasta" :  recommended_config.simpleaf_index.custom_ref_fasta,
			# The path to the gene annotation GTF file
			"--gtf" :  recommended_config.simpleaf_index.custom_ref_gtf,
		},

		direct_ref: {
			"--ref-seq" :  null,
		},
	},

	# if you have an existing index, please fill out the corresponding field below.
	# This will skip the index building step and use the existing index.
	existing_index : {
		enabled : false, # switch to true if you have an existing index
		index_path : null,
		t2g_map_path : null,
	},

	simpleaf_quant : {
		# map_reads or existing_mappings
		# if existing_mappings, please fill out the corresponding field below
		map_type : "map_reads",

		# Recommended Mapping Option :  Mapping reads against the splici reference generated by the simpleaf index command above.
		# Other mapping options can be found in the "advanced-config" section
		map_reads : {
			"--index" : if advanced_config.existing_index.enabled then advanced_config.existing_index.index_path else meta_info.output + "/simpleaf_index/index",
			"--reads1" : recommended_config.simpleaf_quant.reads1,
			"--reads2" : recommended_config.simpleaf_quant.reads2,
		},

		# Option 2 : 
		# Choose only if you have an existing mapping directory and don"t want to rerun mapping
		existing_mappings :  {
			# the path to an existing salmon/piscem mapping result directory
			"--map-dir" :  null,
		},
		
		# five options, 1. (DEFAUT) unfiltered_pl, 2. knee, 3. forced, 4. expect, 5. explicit_pl
		# please fill out the corresponding field below
		cell_filtering_type : "unfiltered_pl",

		# No cell filtering, but correct cell barcodes according to a permitlist file
		# If you would like to use other cell filtering options, please change this field to null,
		# and select one cell filtering strategy listed in the "advanced-config" section
		# DEFAULT
		unfiltered_pl : {
		# empty string means using 10X whitelist.
		# Provide a path if you want to use a different whitelist.
		"--unfiltered-pl" :  "", 
		},

		# 2. knee finding cell filtering. If choosing this, change the value from null to "".
		knee : {
		"--knee" :  true, # false or true,
		},

		# 3. A hard threshold. If choosing this, change the value from null to an integer
		forced : {
		"--forced-cells" :  null, # or "--forced-cells" : INT, for example, "--forced-cells" : 3000
		},

		# 4. A soft threshold. If choosing this, change the null to an integer
		expect : {
		"--expect-cells" :  null, #or "--expect-cells" : INT, for example, "--expect-cells" : 3000
		},

		# 5. filter cells using an explicit whitelist. Only use when you know exactly the 
		# true barcodes. 
		# If choosing this, change the null to the path to the whitelist file. 
		explicit_pl : {
		"--explicit-pl" : null, # or "--explicit-pl" : "/path/to/pl",
		},
	},
};

local optional_config = {
	simpleaf_index : {
		active : !advanced_config.existing_index.enabled,
		step : 1,
		"program-name": "simpleaf index",
		"--output" :  meta_info.output + "/simpleaf_index",
		"--spliced" : null,
		"--unspliced" : null,
		"--threads" : meta_info.threads,
		"--dedup" : false,
		"--sparse" : false,
		"--use-pisem" : meta_info.use_piscem,
		"--overwrite" : meta_info.use_piscem,
		"--keep-duplicates" : false,
		"--kmer-length" :  31,
		"--minimizer-length" : std.ceil(std.get(self, "--kmer-length") / 1.8) + 1,
	},
	simpleaf_quant : {
		active : true,
		step : 2,
		"program-name": "simpleaf quant",
		"--t2g-map": if advanced_config.existing_index.enabled then advanced_config.existing_index.t2g_map_path else null,
		"--chemistry" :  "10xv3",
		"--resolution" :  "cr-like",
		"--use-piscem" : meta_info.use_piscem,
		"--expected-ori" :  "fw",
		"--output" : meta_info.output + "/simpleaf_quant",
		"--threads" :  meta_info.threads,
		"--min-reads" : null,
	},
};

# build simpleaf index command
local simpleaf_index = optional_config.simpleaf_index + 
	utils.get_field(advanced_config.simpleaf_index, advanced_config.simpleaf_index.reference_type)
;

local simpleaf_quant = optional_config.simpleaf_quant +
	utils.get_field(advanced_config.simpleaf_quant, advanced_config.simpleaf_quant.map_type) +
	utils.get_field(advanced_config.simpleaf_quant, advanced_config.simpleaf_quant.cell_filtering_type)
;

std.prune({
	"meta-info": meta_info,
	workflow : {
		simpleaf_index : simpleaf_index,
		simpleaf_quant : simpleaf_quant,
	}
})
