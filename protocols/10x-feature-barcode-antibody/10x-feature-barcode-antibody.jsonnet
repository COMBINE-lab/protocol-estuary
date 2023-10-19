
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
    template_version : "0.0.2",

    
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
local recommended_config = {
    gene_expression : {
        simpleaf_index : {
            # string path to gtf file
            custom_ref_gtf : "genes.gtf",

            # string path to fasta file
            custom_ref_fasta : "genome.fa",
        },

        #Information for running `simpleaf quant`
        simpleaf_quant : {
            # having multiple files and they are all in a parent dir? try the following bash command to get their name (Don't forget to quote them!)
            # $ find -L your/fastq/absolute/path -name "*_R1_*" -type f | sort | paste -sd, -
            # Change "*_R1_*" to the file name pattern of your files if it dosn't fit

            # read1 (technical reads) files separated by comma (,)
            reads1 : "reads1.fa", # reads1 : "path/to/file1,path/to/file2"

            # read2 (biological reads) files separated by comma (,)
            reads2 : "reads2.fa", # reads2 : "path/to/file1,path/to/file2"
        },
    },
    antibody_capture : {
        simpleaf_index : {
            # The path to the feature reference molecule structure and the corresponding reference barcode sequence.
            # https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/using/feature-bc-analysis#feature-ref 
            feature_reference_csv : "feature_reference.csv", # feature_reference_csv : "/path/to/feature_reference.csv"
        },
        simpleaf_quant : {
            reads1 : "reads1.fa", # reads1 : "path/to/file1,path/to/file2"
            reads2 : "reads2.fa", # reads2 : "path/to/file1,path/to/file2"
        },
    },
    crispr_screen : {
        simpleaf_index : {
            # same format as in antibody_capture but for crispr screen
            feature_reference_csv : "feature_reference.csv", # feature_reference_csv : "/path/to/feature_reference.csv"
        },

        simpleaf_quant : {
            reads1 : "reads1.fa", # reads1 : "path/to/file1,path/to/file2"
            reads2 : "reads2.fa", # reads2 : "path/to/file1,path/to/file2"
        },
    },
};

local advanced_config = {
    gene_expression : {
        simpleaf_index : {
            # splici, spliceu, or direct_ref
            # if direct_ref, please fill out the corresponding field below
            reference_type : 'splici',

            splici : {
            "--fasta" : recommended_config.gene_expression.simpleaf_index.custom_ref_fasta,
            "--gtf" : recommended_config.gene_expression.simpleaf_index.custom_ref_gtf,
            "--rlen" : 91,
            },

            spliceu : {
                # spliced + unspliced transcriptome
                # https : //pyroe.readthedocs.io/en/latest/building_splici_index.html#preparing-a-spliced-unspliced-transcriptome-reference
                "--ref-type" : "spliceu",
                "--fasta" :  recommended_config.gene_expression.simpleaf_index.custom_ref_fasta,
                "--gtf" :  recommended_config.gene_expression.simpleaf_index.custom_ref_gtf,
            },

            direct_ref : {
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

            # Option 2 : 
            # Choose only if you have an existing mapping directory and don"t want to rerun mapping
            existing_mappings : {
                # the path to an existing salmon/piscem mapping result directory
                "--map-dir" : null,
            },

            # Recommended Mapping Option :  Mapping reads against the splici reference generated by the simpleaf index command above.
            map_reads : {
                "--index" : if advanced_config.gene_expression.existing_index.enabled then advanced_config.gene_expression.existing_index.index_path else meta_info.output + "/simpleaf_index/index",
                "--reads1" : recommended_config.gene_expression.simpleaf_quant.reads1,
                "--reads2" : recommended_config.gene_expression.simpleaf_quant.reads2,
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
    },
    antibody_capture : {
        existing_index : {
            enabled : false, # switch to true if you have an existing index
            index_path : null,
            t2g_map_path : null,
        },
        
        simpleaf_quant : {
            # map_reads or existing_mappings
            # if existing_mappings, please fill out the corresponding field below
            map_type : "map_reads",

            # Option 2 : 
            # Choose only if you have an existing mapping directory and don"t want to rerun mapping
            existing_mappings :  {
                # the path to an existing salmon/piscem mapping result directory
                "--map-dir" :  null,
            },

            # Recommended Mapping Option :  Mapping reads against the splici reference generated by the simpleaf index command above.
            map_reads : {
                "--index" : if advanced_config.antibody_capture.existing_index.enabled then advanced_config.antibody_capture.existing_index.index_path else meta_info.output + "/antibody_capture/simpleaf_index/index",
                "--reads1" : recommended_config.antibody_capture.simpleaf_quant.reads1,
                "--reads2" : recommended_config.antibody_capture.simpleaf_quant.reads2,
            },  

            # five options, 1. explicit_pl, 2. knee, 3. forced, 4. expect, 5. unfiltered_pl
            # please fill out the corresponding field below
            cell_filtering_type : "explicit_pl",

            # filter cells using an explicit whitelist. Only use when you know exactly the 
            # true barcodes. 
            # DEFAULT
            explicit_pl : {
            "--explicit-pl" : meta_info.output + "/gene_expression/simpleaf_index/af_quant/alevin/quants_mat_rows.txt"
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

            # 5. No cell filtering, but correct cell barcodes according to a permitlist file
            # If you would like to use other cell filtering options, please change this field to null,
            # and select one cell filtering strategy listed in the "advanced-config" section
            unfiltered_pl : {
            # empty string means using 10X whitelist.
            # Provide a path if you want to use a different whitelist.
            "--unfiltered-pl" :  null, 
            },
        },  
    },
    crispr_screen : {
        existing_index : {
            enabled : false, # switch to true if you have an existing index
            index_path : null,
            t2g_map_path : null,
        },
        
        simpleaf_quant : {
            # map_reads or existing_mappings
            # if existing_mappings, please fill out the corresponding field below
            map_type : "map_reads",

            # Option 2 : 
            # Choose only if you have an existing mapping directory and don"t want to rerun mapping
            existing_mappings :  {
                # the path to an existing salmon/piscem mapping result directory
                "--map-dir" :  null,
            },

            # Recommended Mapping Option :  Mapping reads against the splici reference generated by the simpleaf index command above.
            map_reads : {
                "--index" : if advanced_config.crispr_screen.existing_index.enabled then advanced_config.crispr_screen.existing_index.index_path else meta_info.output + "/crispr_screen/simpleaf_index/index",
                "--reads1" : recommended_config.crispr_screen.simpleaf_quant.reads1,
                "--reads2" : recommended_config.crispr_screen.simpleaf_quant.reads2,
            },  
            # five options, 1. explicit_pl, 2. knee, 3. forced, 4. expect, 5. unfiltered_pl
            # please fill out the corresponding field below
            cell_filtering_type : "explicit_pl",

            # filter cells using an explicit whitelist. Only use when you know exactly the 
            # true barcodes. 
            # DEFAULT
            explicit_pl : {
            "--explicit-pl" : meta_info.output + "/gene_expression/simpleaf_index/af_quant/alevin/quants_mat_rows.txt"
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

            # 5. No cell filtering, but correct cell barcodes according to a permitlist file
            # If you would like to use other cell filtering options, please change this field to null,
            # and select one cell filtering strategy listed in the "advanced-config" section
            unfiltered_pl : {
            # empty string means using 10X whitelist.
            # Provide a path if you want to use a different whitelist.
            "--unfiltered-pl" :  null, 
            },
        },  
    },
};

local optional_config = {
    gene_expression : {
        simpleaf_index : {
            active : ! (advanced_config.gene_expression.existing_index.enabled || advanced_config.gene_expression.simpleaf_quant.map_type == "existing_mappings"),
            step : 1,
            "program-name" : "simpleaf index",
            "--output" :  meta_info.output + "/gene_expression/simpleaf_index",
            "--spliced" : null,
            "--unspliced" : null,
            "--threads" : meta_info.threads,
            "--dedup" : false,
            "--sparse" : false,
            "--use-pisem" : meta_info.use_piscem,
            "--overwrite" : meta_info.use_piscem,
            "--keep-duplicates" : false,
            "--kmer-length" :  31,
            "--minimizer-length" : if meta_info.use_piscem then std.ceil(std.get(self, "--kmer-length") / 1.8) + 1 else null,
        },
        simpleaf_quant : {
            active : true,
            step : 2,
            "program-name" : "simpleaf quant",
            "--t2g-map" : if advanced_config.gene_expression.existing_index.enabled then advanced_config.existing_index.gene_expression.t2g_map_path else null,
            "--chemistry" :  "10xv3",
            "--resolution" :  "cr-like",
            "--use-piscem" : meta_info.use_piscem,
            "--expected-ori" :  "fw",
            "--output" : meta_info.output + "/gene_expression/simpleaf_quant",
            "--threads" :  meta_info.threads,
            "--min-reads" : null,
        },
    },
    antibody_capture : {
        simpleaf_index : {
            active : ! (advanced_config.antibody_capture.existing_index.enabled || advanced_config.antibody_capture.simpleaf_quant.map_type == "existing_mappings"),
            step : 11,
            "program-name" : "simpleaf index",
            "--ref-seq" : meta_info.output + "/.antibody_ref_barcode.fa",
            "--output" :  meta_info.output + "/antibody_capture/simpleaf_index",
            "--threads" : meta_info.threads,
            "--sparse" : false,
            "--use-pisem" : meta_info.use_piscem,
            "--overwrite" : meta_info.use_piscem,
            "--keep-duplicates" : false,
            "--kmer-length" : 7,
            "--minimizer-length" : if meta_info.use_piscem then std.ceil(std.get(self, "--kmer-length") / 1.8) + 1 else null,
        },
        simpleaf_quant : {
            active : true,
            step : 12,
            "program-name" : "simpleaf quant",
            "--t2g-map" : if advanced_config.antibody_capture.existing_index.enabled then advanced_config.antibody_capture.existing_index.t2g_map_path else meta_info.output + "/.antibody_ref_t2g.tsv",
            "--chemistry" :  "1{b[16]u[12]}2{x[10]r[15]x:}",
            "--resolution" :  "cr-like",
            "--use-piscem" : meta_info.use_piscem,
            "--expected-ori" :  "fw",
            "--output" : meta_info.output + "/antibody_capture/simpleaf_quant",
            "--threads" :  meta_info.threads,
            "--min-reads" : null,
        },
    },
    crispr_screen : {
        simpleaf_index : {
            active : ! (advanced_config.antibody_capture.existing_index.enabled || advanced_config.antibody_capture.simpleaf_quant.map_type == "existing_mappings"),
            step : 13,
            "program-name" : "simpleaf index",
            "--ref-seq" : meta_info.output + "/.crispr_ref_barcode.fa",
            "--output" :  meta_info.output + "/gene_expression/simpleaf_index",
            "--threads" : meta_info.threads,
            "--dedup" : false,
            "--sparse" : false,
            "--use-pisem" : meta_info.use_piscem,
            "--overwrite" : meta_info.use_piscem,
            "--keep-duplicates" : false,
            "--kmer-length" :  7,
            "--minimizer-length" : if meta_info.use_piscem then std.ceil(std.get(self, "--kmer-length") / 1.8) + 1 else null,
        },
        simpleaf_quant : {
            active : true,
            step : 14,
            "program-name" : "simpleaf quant",
            "--t2g-map" : if advanced_config.existing_index.enabled then advanced_config.existing_index.t2g_map_path else meta_info.output + "/.crispr_ref_t2g.tsv",
            "--chemistry" :  "1{b[16]u[12]}2{x:r[20]f[GTTTAAGAGCTAAGCTGGAA]x:}",
            "--resolution" :  "cr-like",
            "--use-piscem" : meta_info.use_piscem,
            "--expected-ori" :  "fw",
            "--output" : meta_info.output + "/gene_expression/simpleaf_quant",
            "--threads" :  meta_info.threads,
            "--min-reads" : null,
        },
    },
};

local external_commands = {
    fetch_cb_translation_file : {
        active : true,
        step : 3,
        "program-name" : "wget",
        "Arguments": ["-O", meta_info.output + "/.3M-february-2018.txt.gz", "https://github.com/10XGenomics/cellranger/raw/master/lib/python/cellranger/barcodes/translation/3M-february-2018.txt.gz"],
    },
    unzip_cb_translation_file : {
        active : true,
        step : 4,
        "program-name" : "gunzip",
        "Arguments": ["-c", meta_info.output + "/.3M-february-2018.txt.gz",">", meta_info.output + "/.3M-february-2018.txt"],
    },

    backup_bc_file : {
        active : true,
        step: 5,
        "program-name": "mv",
        "Arguments": [meta_info.output + "/gene_expression/simpleaf_index/af_quant/alevin/quants_mat_rows.txt", meta_info.output + "/gene_expression/simpleaf_index/af_quant/alevin/.quants_mat_rows.txt.bkp"],
    },

    // Translate RNA barcode to feature barcode
    barcode_translation : {
        active : true,
        step: 6,
        "program-name": "awk",
        "Arguments": ["'FNR==NR {dict[$1]=$2; next} {$1=($1 in dict) ? dict[$1] : $1}1'", meta_info.output + "/.3M-february-2018.txt", meta_info.output + "/gene_expression/simpleaf_index/af_quant/alevin/.quants_mat_rows.txt.bkp", ">", meta_info.output + "/gene_expression/simpleaf_index/af_quant/alevin/quants_mat_rows.txt"],
    },

    create_antibody_t2g : {
        active : ! (advanced_config.antibody_capture.existing_index.enabled || advanced_config.antibody_capture.simpleaf_quant.map_type == "existing_mappings"),
        step: 7,
        "program-name": "awk",
        "Arguments": ["-F","','","'NR>1 {sub(/ /,\"_\",$1);print $1\"\\t\"$1}'", recommended_config.antibody_capture.simpleaf_index.feature_reference_csv, ">", meta_info.output + "/.antibody_ref_t2g.tsv"],
    },
    
    create_antibody_fasta: {
        active : ! (advanced_config.antibody_capture.existing_index.enabled || advanced_config.antibody_capture.simpleaf_quant.map_type == "existing_mappings"),
        step: 8,
        "program-name": "awk",
        "Arguments": ["-F","','","'NR>1 {sub(/ /,\"_\",$1);print \">\"$1\"\\n\"$5}'", recommended_config.antibody_capture.simpleaf_index.feature_reference_csv, ">", meta_info.output + "/.antibody_ref.fa"]
    },

    create_crispr_t2g : {
        active : ! (advanced_config.antibody_capture.existing_index.enabled || advanced_config.antibody_capture.simpleaf_quant.map_type == "existing_mappings"),
        step: 9,
        "program-name": "awk",
        "Arguments": ["-F","','","'NR>1 {sub(/ /,\"_\",$1);print $1\"\\t\"$1}'", recommended_config.crispr_screen.simpleaf_index.feature_reference_csv, ">", meta_info.output + "/.crispr_ref_t2g.tsv"],
    },
    
    create_crispr_fasta: {
        active : ! (advanced_config.antibody_capture.existing_index.enabled || advanced_config.antibody_capture.simpleaf_quant.map_type == "existing_mappings"),
        step: 10,
        "program-name": "awk",
        "Arguments": ["-F","','","'NR>1 {sub(/ /,\"_\",$1);print \">\"$1\"\\n\"$5}'", recommended_config.crispr_screen.simpleaf_index.feature_reference_csv, ">", meta_info.output + "/.crispr_ref_barcode.fa"]
    },
};

# build gene expression modality
local gene_expression = {
    simpleaf_index : optional_config.gene_expression.simpleaf_index + 
	    utils.get_field(advanced_config.gene_expression.simpleaf_index, advanced_config.gene_expression.simpleaf_index.reference_type),

    simpleaf_quant : optional_config.gene_expression.simpleaf_quant +
	    utils.get_field(advanced_config.gene_expression.simpleaf_quant, advanced_config.gene_expression.simpleaf_quant.map_type) +
	    utils.get_field(advanced_config.gene_expression.simpleaf_quant, advanced_config.gene_expression.simpleaf_quant.cell_filtering_type),
};

local antibody_capture = {
    simpleaf_index : optional_config.antibody_capture.simpleaf_index,
    simpleaf_quant : optional_config.antibody_capture.simpleaf_quant + 
        utils.get_field(advanced_config.antibody_capture.simpleaf_quant, advanced_config.antibody_capture.simpleaf_quant.map_type) + 
        utils.get_field(advanced_config.antibody_capture.simpleaf_quant, advanced_config.antibody_capture.simpleaf_quant.cell_filtering_type),
}


====================================

std.prune({
	"meta-info" : meta_info,
	workflow : {
		simpleaf_index : simpleaf_index,
		simpleaf_quant : simpleaf_quant,
	}
})
