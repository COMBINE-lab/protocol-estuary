
// feature barcoding can have three parts
// 1. antibody barcoding (optional)
// 2. cell multiplexing (optional)
// 3. RNA (required)
#############################################################################
# README:

# *IMPORTANT*: For most user, the fields in section "Recommended Configuration" are the only things to complete.
# *IMPORTANT*: CITE-seq uses TotalSeq-A chemistry.
# If your experiments used TotalSeq-B chemistry, you should use the `10x-feature-barcode-antibody` workflow instead of this one.

# To modify an argument, please replace the Right hand side of each field (separated by `:`) with your value **wrapped in quotes**.
# For example, you can replace `"output": null` in the meta_info section with `"output": "/path/to/output/dir"`, and `"threads": null` with `"threads": "16"`
# All fields that are null, empty array ([]), and empty dictionary ({}) will be pruned (ignored).
# NOTE: You can pass optional simpleaf arguments specified in the "Optional Configuration" section.

#############################################################################

local workflow = {

    // Meta information
    "meta_info": {
        "template_name":  "CITE-seq ADT+HTO with 10x Chromium 3' v3 (TotalSeq-A chemistry)",
        "template_id": "cite-seq-ADT+HTO_10xv3",
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
        // Information for recommended setting
        "RNA": {
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
            }
        },

        // Recommended information for analyzing cell surface protein barcoding (ADT) reads
        // For optional arguments, Please check the "Optional Arguments" field.
        "ADT": {
            // Arguments used for running `simpleaf index`
            // This is required UNLESS you have an existing salmon index. In that case, you can change the Step of this "simpleaf index" command in the "Optional Configuration" to a quoted negative integer.
            "simpleaf_index": {
                "Step": 9,
                "Program Name": "simpleaf index",
                // The path to the antibody derived tags' (ADT) reference barcode CSV file
                // The file should ends with .csv or .csv.gz.
                // If your file is already in FASTA format, use that as the "--ref-seq" field in the Optional Configuration
                // and leave this field as null.
                "ADT reference barcode CSV file path": null,
            },

            // arguments for running `simpleaf quant`
            "simpleaf_quant": {
                "Step": 10,
                "Program Name": "simpleaf quant",
                // Map sequencing reads against the reference index generated by simpleaf index call
                "Recommended Mapping Option": {
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

        // Recommended information for analyzing sample hashing barcoding (HTO) reads
        // For optional arguments, Please check the "Optional Arguments" field.
        "HTO": {
            // arguments used for running `simpleaf index`
            // If you have an existing salmon/piscem index, skip this and fill the --index field in Optional Configuration section 
            "simpleaf_index": {
                "Step": 11,
                "Program Name": "simpleaf index",
                // The path to the hash tag oligos (HTO) reference barcode CSV file
                // The file should be ending with .csv or .csv.gz.
                // Current we do not support other format.
                "HTO reference barcode CSV file path": null,
            },

            // arguments for running `simpleaf quant`
            "simpleaf_quant": {
                "Step": 12,
                "Program Name": "simpleaf quant",
                // Map sequencing reads against the reference index generated by simpleaf index call
                "Recommended Mapping Option": {
                        // read1 (technical reads) files separated by comma (,)
                        // having multiple files and they are all in a directory? try the following bash command to get their name (Don't forget to quote them!)
                        // $ find -L your/fastq/absolute/path -name "*_R1_*" -type f | sort | paste -sd, -
                        "--reads1": null,

                        // read2 (biological reads) files separated by comma (,)
                        // having multiple files and they are all in a directory? try the following bash command to get their name (Don't forget to quote them!)
                        // $ find -L your/fastq/absolute/path -name "*_R1_*" -type f | sort | paste -sd, -
                        "--reads2": null,
                },
            },
        },
    },





##########################################################################################################

# OPTIONAL : The configuration options below are optional, and may be of most interest to advanced users

##########################################################################################################

    "Optional Configuration": {
        // Optional arguments for processing RNA reads
        "RNA": {
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

            }
        },
        "ADT": {
            // arguments used for running `simpleaf index`
            "simpleaf_index": {
                // The required fields first
                "Step": 9,
                "Program Name": "simpleaf index",
                "Active": true,

                // The path to the reference sequence FASTA file
                // Only change this if the tag barcode reference file is in the FASTA format
                "--ref-seq": null,

                "--kmer-length": "7",
                "--output": null,
                "--threads": null,
                "--sparse": null,
                "--overwrite": null,
                "--use-piscem": null,
                "--minimizer-length": null,
                "--keep-duplicates": null,
            },

            // Optional arguments for running `simpleaf quant`
            "simpleaf_quant": {
                // The Step of this experiment
                "Step": 10,
                "Program Name": "simpleaf quant",
                "Active": true,

                // the transcript name to gene name mapping TSV file
                // This is required if `--ref-seq` is specified in the corresponding simpleaf index command. 
                "--t2g-map": null,

                "Other Mapping Options": {
                    // Option 1:
                    // If you have built the reference index already, 
                    // you can leave the simpleaf index section unchanged
                    // and specify the path to the index here  
                    "1. Mapping Reads FASTQ Files against an existing index": {
                        // read1 (technical reads) files separated by comma (,)
                        "--reads1": null,

                        // read2 (biological reads) files separated by comma (,)
                        "--reads2": null,

                        // the path to an existing salmon/piscem reference index
                        "--index": null
                    },

                    // Option 2:
                    // Choose only if you have an existing mapping directory and don"t want to rerun mapping
                    "2. Existing Mapping Directory": {
                        // the path to an existing salmon/piscem mapping result directory
                        "--map-dir": null,
                    },
                },

                // By default, the workflow will use the reported cell barcodes in the gene count matrix
                // obtained from processing RNA reads as the explicit permit list for feature barcoding reads.
                // If you want to choose another cell fitlering option, please specify one of the followings.
                "Other Cell Filtering Options": {
                    // 1. No cell filtering, but correct cell barcodes according to a permitlist file
                    //    if you don"t want to use this, change the value from "" to null. 
                    // *RECOMMENDED*
                    "--unfiltered-pl": null, // or "--unfiltered-pl": "" 

                    // 2. knee finding cell filtering. If choosing this, change the value from null to "".
                    "--knee": null, // or "--knee": null,

                    // 3. A hard threshold. If choosing this, change the value from null to an integer
                    "--forced-cells": null, // or "--forced-cells": "INT", for example, "--forced-cells": "3000"

                    // 4. A soft threshold. If choosing this, change the null to an integer
                    "--expect-cells": null, //or "--expect-cells": "INT", for example, "--expect-cells": "3000"

                    // 5. filter cells using an explicit whitelist. Only use when you know exactly the 
                    // true barcodes. 
                    // If choosing this, change the null to the path to the whitelist file. 
                    "--explicit-pl": null, // or "--explicit-pl": "/path/to/pl",
                },
                "--chemistry": "1{b[16]u[12]}2{r[15]}",
                "--resolution": "cr-like",
                "--expected-ori": "fw",

                // If null, this argument will be automatically completed by the template.
                "--output": null,
                "--threads": null,
                "--min-reads": null,
                "--index": null,
                "--use-piscem": null,
                "--use-selective-alignment": null,
            },
        },
        "HTO": {
            // arguments used for running `simpleaf index`
            "simpleaf_index": {
                // The required fields first
                "Step": 11,
                "Program Name": "simpleaf index",
                "Active": true,

                // The path to the reference sequence FASTA file
                // Only change this if the tag barcode reference file is in the FASTA format
                "--ref-seq": null,

                "--kmer-length": "7",
                "--output": null,
                "--threads": null,
                "--sparse": null,
                "--overwrite": null,
                "--use-piscem": null,
                "--minimizer-length": null,
                "--keep-duplicates": null,
            },

            // Optional arguments for running `simpleaf quant`
            "simpleaf_quant": {
                // The Step of this experiment
                "Step": 12,
                "Program Name": "simpleaf quant",
                "Active": true,

                // the transcript name to gene name mapping TSV file
                // This is required if `--ref-seq` is specified in the corresponding simpleaf index command. 
                "--t2g-map": null,

                "Other Mapping Options": {
                    // Option 1:
                    // If you have built the reference index already, 
                    // you can leave the simpleaf index section unchanged
                    // and specify the path to the index here  
                    "1. Mapping Reads FASTQ Files against an existing index": {
                        // read1 (technical reads) files separated by comma (,)
                        "--reads1": null,

                        // read2 (biological reads) files separated by comma (,)
                        "--reads2": null,

                        // the path to an existing salmon/piscem reference index
                        "--index": null
                    },

                    // Option 2:
                    // Choose only if you have an existing mapping directory and don"t want to rerun mapping
                    "2. Existing Mapping Directory": {
                        // the path to an existing salmon/piscem mapping result directory
                        "--map-dir": null,
                    },
                },

                // By default, the workflow will use the reported cell barcodes in the gene count matrix
                // obtained from processing RNA reads as the explicit permit list for feature barcoding reads.
                // If you want to choose another cell fitlering option, please specify one of the followings.
                "Other Cell Filtering Options": {
                    // 1. No cell filtering, but correct cell barcodes according to a permitlist file
                    //    if you don"t want to use this, change the value from "" to null. 
                    // *RECOMMENDED*
                    "--unfiltered-pl": null, // or "--unfiltered-pl": "" 
                    
                    // 2. knee finding cell filtering. If choosing this, change the value from null to "".
                    "--knee": null, // or "--knee": null,

                    // 3. A hard threshold. If choosing this, change the value from null to an integer
                    "--forced-cells": null, // or "--forced-cells": "INT", for example, "--forced-cells": "3000"

                    // 4. A soft threshold. If choosing this, change the null to an integer
                    "--expect-cells": null, //or "--expect-cells": "INT", for example, "--expect-cells": "3000"

                    // 5. filter cells using an explicit whitelist. Only use when you know exactly the 
                    // true barcodes. 
                    // If choosing this, change the null to the path to the whitelist file. 
                    "--explicit-pl": null, // or "--explicit-pl": "/path/to/pl",
                },
                "--chemistry": "1{b[16]u[12]}2{r[15]}",
                "--resolution": "cr-like",
                "--expected-ori": "fw",

                // If null, this argument will be automatically completed by the template.
                "--output": null,
                "--threads": null,
                "--min-reads": null,
                "--index": null,
                "--use-piscem": null,
                "--use-selective-alignment": null,
            },
        },
    },

##########################################################################################################
// External Commands: The external linux commands that will be run during the execution of the workflow

// This section records the shell commands that will be called during the execution of the workflow.
// Each subfield should have an unique name and contain the complete information for involing a linux command.
#########################################################################################################
    "External Commands": {
        // This command is used for converting the 
        // reference feature barcodes' TSV file into FASTA file
        // before building the index
        "HTO ref gunzip": {
            "Step": 3,
            "Program Name": "gunzip",
            "Active": true,
            "Arguments": ["-c","TBD",">","TBD"],
        },

        // This command is used for converting the 
        // reference feature barcodes' TSV file into FASTA file
        // before building the index
        "ADT ref gunzip": {
            "Step": 4,
            "Program Name": "gunzip",
            "Active": true,
            "Arguments": ["-c","TBD",">","TBD"],
        },


        // This command is used for converting the 
        // reference feature barcodes' TSV file into FASTA file
        // before building the index
        "HTO reference CSV to t2g": {
            "Step": 5,
            "Program Name": "awk",
            "Active": true,
            "Arguments": ["-F","','","'NR>1 {sub(/ /,\"_\",$1);print $1\"\\t\"$1}'","TBD",">","TBD"],
        },

        // This command is used for converting the 
        // reference feature barcodes' TSV file into FASTA file
        // before building the index
        "ADT reference CSV to t2g": {
            "Step": 6,
            "Program Name": "awk",
            "Active": true,
            "Arguments": ["-F","','","'NR>1 {sub(/ /,\"_\",$1);print $1\"\\t\"$1}'","TBD",">","TBD"],
        },

        // This command is used for converting the 
        // reference feature barcodes' TSV file into FASTA file
        // before building the index
        "HTO reference CSV to FASTA": {
            "Step": 7,
            "Program Name": "awk",
            "Active": true,
            "Arguments": ["-F","','","'NR>1 {sub(/ /,\"_\",$1);print \">\"$1\"\\n\"$4}'","TBD",">","TBD"]
        },
        
        // This command is used for converting the 
        // reference feature barcodes' TSV file into FASTA file
        // before building the index
        "ADT reference CSV to FASTA": {
            "Step": 8,
            "Program Name": "awk",
            "Active": true,
            "Arguments": ["-F","','","'NR>1 {sub(/ /,\"_\",$1);print \">\"$1\"\\n\"$4}'","TBD",">","TBD"]
        },
    },
};

##########################################################################################################
// PLEASE DO NOT CHANGE ANYTHING BELOW THIS LINE
// PLEASE DO NOT CHANGE ANYTHING BELOW THIS LINE
// PLEASE DO NOT CHANGE ANYTHING BELOW THIS LINE
// PLEASE DO NOT CHANGE ANYTHING BELOW THIS LINE
// The content below is used for parsing the config file in simpleaf internally.
#########################################################################################################

local utils = std.extVar("__utils");
local output = std.extVar("__output");

// 1. if the reference csv file is provided for ADT and/or HTO, then file 
// 1. if --ref-seq is in both HTO and ADT, turn off awk calls for converting csv to t2g
// 2. if --t2g-map is in both HTO and ADT, turn off awk calls 
local activate_ext_calls(workflow, output_path, fb_ref_path) = 
    // check the existence of cell multiplexing experiment
    local hto = utils.get(workflow, "HTO", use_default = true);
    // check the existence of simpleaf index command
    local hto_index = if hto == null then null else utils.get(hto, "simpleaf_index", use_default = true);
    local hto_quant = if hto == null then null else utils.get(hto, "simpleaf_quant", use_default = true);
    // check the existence of `--ref-seq`
    local hto_index_refseq = if hto_index == null then null else utils.get(hto, "--ref-seq", use_default = true);
    local hto_quant_t2g = if hto_index == null then null else utils.get(hto, "--t2g-map", use_default = true);
    local hto_ref_csv_path = output_path + "/hto_reference.csv";
    local hto_fasta_path = output_path + "/hto_reference_barcode.fasta";
    local hto_t2g_path = output_path + "/hto_t2g.tsv";

    // check the existence of cell surface protein barcoding experiment
    local adt = utils.get(workflow, "ADT", use_default = true);
    // check the existence of simpleaf index command
    local adt_index = if adt == null then null else utils.get(adt, "simpleaf_index", use_default = true);
    local adt_quant = if adt == null then null else utils.get(adt, "simpleaf_quant", use_default = true);
    // check the existence of `--ref-seq`
    local adt_index_refseq = if adt_index == null then null else utils.get(adt, "--ref-seq", use_default = true);
    local adt_quant_t2g = if adt_index == null then null else utils.get(adt, "--t2g-map", use_default = true);
    local adt_ref_csv_path = output_path + "/adt_reference_barcode.csv";
    local adt_fasta_path = output_path + "/adt_reference_barcode.fasta";
    local adt_t2g_path = output_path + "/adt_t2g.tsv";

    {
        // Update HTO ref-seq as the output of awk command
        [if hto != null then "HTO"] +: {
            [if hto_index != null then "simpleaf_index"]+: {
                [if hto_index_refseq == null && fb_ref_path.hto != null then "--ref-seq"]: hto_fasta_path,
            },

            [if hto_quant != null then "simpleaf_quant"]+: {
                [if hto_quant_t2g == null && fb_ref_path.hto != null then "--t2g-map"]: hto_t2g_path,
            }
        },

        // Update ADT ref-seq as the output of awk command
        [if adt != null then "ADT"] +: {
            [if adt_index != null then "simpleaf_index"]+: {
                [if adt_index_refseq == null then "--ref-seq"]: adt_fasta_path,
            },

            [if adt_quant != null then "simpleaf_quant"]+: {
                [if adt_quant_t2g == null then "--t2g-map"]: adt_t2g_path,
            }
        },

        // Add output file to awk commands.
        "External Commands" +: {
            "HTO ref gunzip" +: {
                "Arguments": ["-c",fb_ref_path.hto,">",hto_ref_csv_path],
            },

            // This command is used for converting the 
            // reference feature barcodes' TSV file into FASTA file
            // before building the index

            "ADT ref gunzip" +: {
                "Arguments": ["-c",fb_ref_path.adt,">",adt_ref_csv_path],
            },
            // This command is used for converting the 
            // reference feature barcodes' TSV file into FASTA file
            // before building the index
            "HTO reference CSV to t2g" +: {
                    "Arguments": [
                        "-F",
                        "','",
                        "'NR>1 {sub(/ /,\"_\",$1);print $1\"\\t\"$1}'",
                        if fb_ref_path.hto != null then
                            if std.endsWith(fb_ref_path.hto, "gz") then 
                                hto_ref_csv_path 
                            else 
                                fb_ref_path.hto
                        else
                            hto_ref_csv_path,
                        ">",
                        hto_t2g_path
                    ],
            },

            // This command is used for converting the 
            // reference feature barcodes' TSV file into FASTA file
            // before building the index
            "ADT reference CSV to t2g" +: {
                "Arguments": [
                    "-F",
                    "','",
                    "'NR>1 {sub(/ /,\"_\",$1);print $1\"\\t\"$1}'",
                        if fb_ref_path.adt != null then
                            if std.endsWith(fb_ref_path.adt, "gz") then 
                                adt_ref_csv_path 
                            else 
                                fb_ref_path.adt
                        else
                            adt_ref_csv_path,
                    ">",
                    adt_t2g_path],
            },

            // This command is used for converting the 
            // reference feature barcodes' TSV file into FASTA file
            // before building the index
            "HTO reference CSV to FASTA" +: {
                "Arguments": [
                    "-F",
                    "','",
                    "'NR>1 {sub(/ /,\"_\",$1);print \">\"$1\"\\n\"$4}'",
                        if fb_ref_path.hto != null then
                            if std.endsWith(fb_ref_path.hto, "gz") then 
                                hto_ref_csv_path 
                            else 
                                fb_ref_path.hto
                        else
                            hto_ref_csv_path,
                    ">",
                    hto_fasta_path,
                ],
            },

            // This command is used for converting the 
            // reference feature barcodes' TSV file into FASTA file
            // before building the index
            "ADT reference CSV to FASTA" +: {
                "Arguments": [
                    "-F",
                    "','",
                    "'NR>1 {sub(/ /,\"_\",$1);print \">\"$1\"\\n\"$4}'",
                        if fb_ref_path.adt != null then
                            if std.endsWith(fb_ref_path.adt, "gz") then 
                                adt_ref_csv_path 
                            else 
                                fb_ref_path.adt
                        else
                            adt_ref_csv_path,
                    ">",
                    adt_fasta_path],
            },

        },
    };

local get_fb_ref_path(workflow) = 
    // check the existence of cell multiplexing experiment
    local hto = utils.get(workflow["Recommended Configuration"], "HTO", use_default = true);
    // check the existence of simpleaf index command
    local hto_index = utils.get(hto, "simpleaf_index", use_default = true);
    // check the existence of reference file
    local hto_ref_path = utils.get(hto_index, "HTO reference barcode CSV file path", use_default = true);
    // check the existence of cell surface barcoding experiment
    local adt = utils.get(workflow["Recommended Configuration"], "ADT", use_default = true);
    // check the existence of simpleaf index command
    local adt_index = utils.get(adt, "simpleaf_index", use_default = true);
    // check the existence of reference file
    local adt_ref_path = utils.get(adt_index, "ADT reference barcode CSV file path", use_default = true);

    // 
    {
        "hto": hto_ref_path,
        "adt": adt_ref_path
    }
;

// This function assigns the cell barcde list (rownames) reporeted in the gene count matrix
// generated using RNA reads as the explicit permitlist for surface protein and cell multiplexing reads.
// TODO: rna to ADT batcode mapping https://github.com/COMBINE-lab/salmon/discussions/576#discussioncomment-235459
local add_explicit_pl(o) =
    // check the existence of cell surface protein barcoding experiment
    local adt = utils.get(o, "ADT", use_default = true);
    // check the existence of simpleaf index command
    local adt_quant = utils.get(adt, "simpleaf_quant", use_default = true);

    // check the existence of cell multiplexing barcoding experiment
    local hto = utils.get(o, "HTO", use_default = true);
    // check the existence of simpleaf index command
    local hto_quant = utils.get(hto, "simpleaf_quant", use_default = true);

    local rna = utils.get(o, "RNA", use_default = true);
    local rna_quant = utils.get(rna, "simpleaf_quant", use_default = true);
    local rna_quant_output = utils.get(rna_quant, "--output", use_default = true);
    local rna_quant_bc_file = if rna_quant_output == null then null else rna_quant_output + "/af_quant/alevin/quants_mat_rows.txt";
    {
        // assign explicit pl for ADT 
        [
            if adt_quant != null &&  rna_quant_bc_file != null then
                if!std.objectHas(adt_quant, "--knee") &&
                    !std.objectHas(adt_quant, "--explicit-pl") &&
                    !std.objectHas(adt_quant, "--forced-cells") &&
                    !std.objectHas(adt_quant, "--expect-cells") &&
                    !std.objectHas(adt_quant, "--unfiltered-pl")
                then
                    "ADT"
                else
                    null
            else
                null
        ]+: 
        {
            "simpleaf_quant"+: {
                "--explicit-pl": rna_quant_bc_file
            }
        },

        // assign explicit pl for HTO
        [
            if hto_quant != null && rna_quant_bc_file != null then
                if !std.objectHas(hto_quant, "--knee") &&
                    !std.objectHas(hto_quant, "--explicit-pl") &&
                    !std.objectHas(hto_quant, "--forced-cells") &&
                    !std.objectHas(hto_quant, "--expect-cells")&&
                    !std.objectHas(hto_quant, "--unfiltered-pl")
                then
                    "HTO"
                else
                    null
            else
                null
        ]+: 
        {
            "simpleaf_quant"+: {
                "--explicit-pl": rna_quant_bc_file
            }
        },
    };

// we process some fields to get required information
local valid_output = utils.get_output(workflow);
local fb_ref_path = get_fb_ref_path(workflow);

local workflow1 = utils.combine_main_sections(workflow);
local workflow2 = utils.add_meta_args(workflow1);

// post processing. 
// decide if running external program calls.
local workflow3 = workflow2 + activate_ext_calls(workflow2, valid_output, fb_ref_path);
local workflow4 = utils.add_index_dir_for_simpleaf_index_quant_combo(workflow3) + add_explicit_pl(workflow3);
workflow4
