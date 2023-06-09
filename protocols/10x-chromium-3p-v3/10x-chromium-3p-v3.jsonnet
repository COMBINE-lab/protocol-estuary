
// 10x Chromium 3' v3 gene expression data processing
// https://combine-lab.github.io/alevin-fry-tutorials/2023/simpleaf-piscem/
#############################################################################
# README:

# *IMPORTANT*: For most user, the fields in section "Recommended Configuration" are the only things to complete.

# To modify an argument, please replace the Right hand side of each field (separated by `:`) with your value **wrapped in quotes**.
# For example, you can replace `"output": null` in the meta_info section with `"output": "/path/to/output/dir"`, and `"threads": null` with `"threads": "16"`
# All fields that are null, empty array ([]), and empty dictionary ({}) will be pruned (ignored).

# NOTE: You can pass optional simpleaf arguments specified in the "Optional Configuration" section.
#############################################################################

local workflow = {

    // Meta information
    "meta_info": {
        "template_name":  "10x Chromium 3' v3 gene expression",
        "template_id": "10x-chromium-3p-v3",
        "template_version": "0.0.1",

        // This value will be assigned to all simpleaf commands that have no --threads arg specified
        // Optional: commands will use their default setting if this is null.
        "threads": null, // "threads": "16",
        
        // The parent directory of all simpleaf command output folders.
        // If this is leaved as null, you have to specify `--output` when running `simpleaf workflow`
        "output": null, // "output": "/path/to/output",

        // this meta flag says if piscem, instead of the default choice salmon, should be used for indexing and mapping for all applicable simpleaf commands.
        "use-piscem": false, // "use-piscem": true,
    },

#######################################################################################################################
// *Recommended* Configuration: 
//  For MOST users, the fields listed in the "Recommended Configuration" section are the only fields
//  that needs to be filled. You should replace all null values with valid values, 
//  as described in the comment lines (those start with double slashes `//`) .

//  For advanced users, you can check other simpleaf arguments listed in the "Optional Configurtion" section.
######################################################################################################################
    
    // **For most users**, ONLY the information in the "Recommended Configuration" section needs to be completed.
    // For advanced usage, please check the "Optional Configuration" field.
    "Recommended Configuration": {
        // Arguments for running `simpleaf index`
        "simpleaf_index": {
            // these two fields are required for all command records.
            "Step": 1,
            "Program Name": "simpleaf index",
            // Recommeneded Reference: spliced + intronic transcriptome (splici) 
            // https://pyroe.readthedocs.io/en/latest/building_splici_index.html#preparing-a-spliced-intronic-transcriptome-reference
            // You can find other reference options in the "Optional Configuration" field. You must choose one type of reference
            "spliced+intronic (splici) reference": {
                // genome fasta file of the studied species
                "--fasta": null,
                // gene annotation gtf file of the studied species
                "--gtf": null,
                // read length, usually it is "91" for 10xv3 datasets.
                // Please check the description of your experiment to make sure
                "--rlen": "91",
            },
        },

        // Information for running `simpleaf quant`
        "simpleaf_quant": {
            "Step": 2,
            "Program Name": "simpleaf quant",
            // Recommended Mapping Option: Mapping reads against the splici reference generated by the simpleaf index command above.
            // Other mapping options can be found in the "Optional Configuration" section
            "Recommended Mapping option": {
                "Mapping Reads FASTQ Files": {
                    // read1 (technical reads) files separated by comma (,)
                    // having multiple files and they are all in a directory? try the following bash command to get their name (Don't forget to quote them!)
                    // $ find -L your/fastq/absolute/path -name "*_R1_*" -type f | sort | paste -sd, -
                    // Change "*_R1_*" to the file name pattern of your files if it dosn't fit
                    "--reads1": null,

                    // read2 (biological reads) files separated by comma (,)
                    // having multiple files and they are all in a directory? try the following bash command to get their name (Don't forget to quote them!)
                    // $ find -L your/fastq/absolute/path -name "*_R1_*" -type f | sort | paste -sd, -
                    // Change "*_R1_*" to the file name pattern of your files if it dosn't fit
                    "--reads2": null,
                },
            },
        },
    },





##########################################################################################################
# OPTIONAL : The configuration options below are optional, and may be of most interest to advanced users

# If you want tyo skip invoking some commands, for example, when the exactly same command had been run before, 
# you can also change their "Active" to false.
# Simpleaf will ignore all commands with "Active": false
#########################################################################################################

    "Optional Configuration": {
        // Optioanal arguments for running `simpleaf index`
        "simpleaf_index": {
            // The required fields
            "Step": 1,
            "Program Name": "simpleaf index",
            "Active": true,

            "Other Reference Options": {
                // spliced + unspliced transcriptome
                // https://pyroe.readthedocs.io/en/latest/building_splici_index.html#preparing-a-spliced-unspliced-transcriptome-reference
                "1. spliced+unspliced (spliceu)": {
                    // specify reference type as spliced+unspliced (spliceu)
                    "--ref-type": null, // "--ref-type": "spliced+unspliced",
                    // The path to the genome FASTA file
                    "--fasta": null,
                    // The path to the gene annotation GTF file
                    "--gtf": null,
                },

                // Direct Reference
                // If the species doesn"t have its genome available,
                // you can pass the reference sequence FASTA file as `--ref-seq`.
                // simpleaf will build index directly using the given file 
                "2. Direct Reference": {
                    // The path to the reference sequence FASTA file
                    "--ref-seq": null,
                },
            },
            
            // If null, this argument will be automatically completed by the template.
            "--output": null,
            "--spliced": null,
            "--unspliced": null,
            "--threads": null,
            "--dedup": null,
            "--sparse": null,
            "--kmer-length": null,
            "--overwrite": null,
            "--use-piscem": null,
            "--minimizer-length": null,
            "--keep-duplicates": null,
        },
        // arguments for running `simpleaf quant`
        "simpleaf_quant": {
            // The required fields first 
            "Step": 2,
            "Program Name": "simpleaf quant",
            "Active": true,

            // the transcript name to gene name mapping TSV file.
            // Simpleaf will find the correct t2g map file for splici and spliceu reference.
            // This is required ONLY if `--ref-seq` is specified in the corresponding simpleaf index command. 
            "--t2g-map": null,

            "Other Mapping Options": {
                // Option 1:
                // If you have built the reference index already, 
                // you can change the Step of the simpleaf index call above to a quoted negative integer,
                // and specify the path to the index here  
                "1. Mapping Reads FASTQ Files against an existing index": {
                    // read1 (technical reads) files separated by comma (,)
                    "--reads1": null,

                    // read2 (biological reads) files separated by comma (,)
                    "--reads2": null,

                    // the path to an EXISTING salmon/piscem reference index
                    "--index": null
                },

                // Option 2:
                // Choose only if you have an existing mapping directory and don"t want to rerun mapping
                "2. Existing Mapping Directory": {
                    // the path to an existing salmon/piscem mapping result directory
                    "--map-dir": null,
                },
            },

            "Cell Filtering Options": {
                // No cell filtering, but correct cell barcodes according to a permitlist file
                // If you would like to use other cell filtering options, please change this field to null,
                // and select one cell filtering strategy listed in the "Optional Configuration section"
                // DEFAULT
                "--unfiltered-pl": "", // or "--unfiltered-pl": null 

                // 2. knee finding cell filtering. If choosing this, change the value from null to "".
                "--knee": null, // or "--knee": "",

                // 3. A hard threshold. If choosing this, change the value from null to an integer
                "--forced-cells": null, // or "--forced-cells": "INT", for example, "--forced-cells": "3000"

                // 4. A soft threshold. If choosing this, change the null to an integer
                "--expect-cells": null, //or "--expect-cells": "INT", for example, "--expect-cells": "3000"

                // 5. filter cells using an explicit whitelist. Only use when you know exactly the 
                // true barcodes. 
                // If choosing this, change the null to the path to the whitelist file. 
                "--explicit-pl": null, // or "--explicit-pl": "/path/to/pl",
            },
            "--chemistry": "10xv3",
            "--resolution": "cr-like",
            "--expected-ori": "fw",

            // If null, this argument will be automatically completed by the template.
            "--output": null,

            // If "--threads" is null but the "threads" meta info field is not,
            // "threads" meta data will be used to complete this "--threads".
            "--threads": null,

            "--min-reads": null,
            "--use-piscem": null,
            "--use-selective-alignment": null,
        },
    },
};

##########################################################################################################
// PLEASE DO NOT CHANGE ANYTHING BELOW THIS LINE
// PLEASE DO NOT CHANGE ANYTHING BELOW THIS LINE
// PLEASE DO NOT CHANGE ANYTHING BELOW THIS LINE
// PLEASE DO NOT CHANGE ANYTHING BELOW THIS LINE
// PLEASE DO NOT CHANGE ANYTHING BELOW THIS LINE
// The content below is used for parsing the config file in simpleaf internally.
#########################################################################################################

local utils = std.extVar("__utils");
local output = std.extVar("__output");

local workflow1 = utils.combine_main_sections(workflow);
local workflow2 = utils.add_meta_args(workflow1);

// post processing. 
// decide if running external program calls.
local workflow3 = utils.add_index_dir_for_simpleaf_index_quant_combo(workflow2);
workflow3
