{
    # function ref_type:
    ref_type(type,arguments = {}) ::
        {
            type :: type,
            arguments :: arguments,
        } +
        if type == "splici" || type == "spliced+intronic" then
            {   
                "--ref-type" : "splici",
                "--fasta" : $.get(arguments, "fasta"),
                "--gtf" : $.get(arguments, "gtf"),
                "--rlen" : $.get(arguments, "rlen", true, 91),
            } 
        else if type == "spliceu" || type == "spliced+unspliced" then
            {
                "--ref-type" : "spliceu",
                "--fasta" : $.get(arguments, "fasta"),
                "--gtf" : $.get(arguments, "gtf"),
            } 
        else if type == "direct_ref" then
            {
                "--ref-seq" : $.get(arguments, "ref_seq"),
            } 
        else if type == "existing_index" then
            {
                "index" :: $.get(arguments, "index"),
                "t2g_map" :: $.get(arguments, "t2g_map"),
            }
        else
            error "Unknown reference type: %s" % type
    ,

    // create a simpleaf index record
    // input: 
    // 1. the output of function ref_type,
    // 2. the arguments of the simpleaf index command
    // 3. the output directory
    // This function create a simpleaf index record
    // There are two hidden fields: index and t2g_map.
    simpleaf_index(ref_type, arguments = {}, output=".") ::
        if ref_type == "existing_mappings" then
            {
                type :: ref_type,
                arguments :: arguments,
            }
        else
            local type = $.get(ref_type, "type");
            // ref type and arguments
            ref_type +
            // system fields
            {   
                output :: output, 
                "program-name" : "simpleaf index",
                active : $.get(arguments, "active", true, type == "existing_index"),
                step : $.get(arguments, "step", self.active, 0),
                "--output" : output,
            } +
            if type != "existing_index" then 
                {
                    local o = output + "/simpleaf_index/index",
                    "index" :: o,
                    "t2g_map" :: o + "/t2g%s.tsv" % if type == "direct_ref" then "" else "_3col",
                } else {} +
            $.get(arguments, "optional_arguments", true, {})
    ,

    // set simpleaf quant parameter realted to mapping
    map_type(type, arguments, simpleaf_index = {}) ::
        {
            type :: type,
            arguments :: arguments,
        } +
        if type == "map_reads" then
            {
                "--index" : $.get(simpleaf_index, "index"),
                "--t2g-map": $.get(simpleaf_index, "t2g_map"),
                "--reads1" : $.get(arguments, "reads1"),
                "--reads2" : $.get(arguments, "reads2"),
            } +
        else if type == "existing_mappings" then
            {
                "--map-dir" : $.get(arguments, "map_dir"),
                "--t2g-map" : $.get(arguments, "t2g_map"),
            } 
        else
            error "Unknown mapping type: %s" % type
    ,
    cell_filtering_type(type, argument = true) ::
        {
            type :: type,
            argument :: argument,
        } +
        if type == "unfiltered_pl" then
            {
                "--unfiltered-pl" : argument,
            } 
        else if type == "knee" then
            {
                "--knee" : argument,
            } 
        else if type == "forced" then
            {
                "--forced-cells" : argument,
            } 
        else if type == "expect" then
            {
                "--expect-cells" : argument,
            } 
        else if type == "explicit_pl" then
            {
                "--explicit-pl" : argument,
            } 
        else
            error "Unknown cell filtering type: %s" % type
    ,

    // create a simpleaf quant record
    simpleaf_quant(map_type, cell_filtering_type, arguments, output=".") ::
        local map = $.get(map_type, "type");
        local filt = $.get(cell_filtering_type, "type");

        // ref type and arguments
        map_type +
        cell_filtering_type +
        // system fields
        {   
            output :: output, 
            "program-name" : "simpleaf quant",
            active : $.get(arguments, "active", true, true),
            step : $.get(arguments, "step", self.active, 0),
            "--output" : output,
        } +
        $.get(arguments, "optional_arguments", true, {})

    get(o, f, use_default = false, default = null)::
        if std.isObject(o) then
            if std.objectHas(o, f) then
                o[f]
            else if use_default then
                default
            else
                error "The object does't have queried field  %s" % f
        else if use_default then
            default
        else
            error "Cannot get fields from a value: '%s'. " % o
    ,


    SimpleafPrograms::
    {
        'simpleaf index': {
            // This is used for deciding by which order the commands are run
            "step": null,
            "program-name": 'simpleaf index',
            "active": null,

            // output directory
            "--output": null,

            // direct ref
            '--ref-seq': null,

            // expanded ref fasta and gtf
            '--fasta': null,
            '--gtf': null,

            // splici: 
            '--rlen': null,

            // optional
            '--spliced': null,
            '--unspliced': null,
            '--threads': null,
            '--dedup': null,
            '--sparse': null,
            '--kmer-length': null,
            '--overwrite': null,
            '--use-piscem': null,
            '--ref-type': null,
            '--minimizer-length': null,
            '--keep-duplicates': null
        },
        'simpleaf quant': {
            // This is used for deciding by which order the commands are run
            "step": null,
            "program-name": 'simpleaf quant',
            "active": null,

            // Options
            '--chemistry': null,
            '--output': null,
            '--threads': null,

            // permit-list
            '--knee': null,
            '--unfiltered-pl': null,
            '--forced-cells': null,
            '--explicit-pl': null,
            '--expect-cells': null,
            '--expected-ori': "fw",
            '--min-reads': null,

            // UMI resolution
            '--resolution': "cr-like",
            '--t2g-map': null,

            // mapping
            '--index': null,
            '--reads1': null,
            '--reads2': null,
            '--use-piscem': null,
            '--use-selective-alignment': null,
            '--map-dir': null
        },
    }
}