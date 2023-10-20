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
                "t2g_map" : $.get(arguments, "t2g_map"),
            } 
        else if type == "existing_index" then
            {
                "index" :: $.get(arguments, "index"),
                "t2g_map" :: $.get(arguments, "t2g_map"),
            }
        else
            error "Unknown reference type: %s" % type
    ,

    splici(fasta, gtf, rlen = 91) ::
        $.ref_type("splici", {fasta: fasta, gtf: gtf, rlen: if rlen == null then 91 else rlen})
    ,
    spliceu(fasta, gtf) ::
        $.ref_type("spliceu", {fasta: fasta, gtf: gtf})
    ,
    direct_ref(ref_seq, t2g_map) ::
        $.ref_type("direct_ref", {ref_seq: ref_seq, t2g_map: t2g_map})
    ,
    existing_index(index, t2g_map) ::
        $.ref_type("existing_index", {index: index, t2g_map: t2g_map})
    ,

    // create a simpleaf index record
    // input: 
    // 1. the output of function ref_type,
    // 2. the arguments of the simpleaf index command
    // 3. the output directory
    // This function create a simpleaf index record
    // There are two hidden fields: index and t2g_map.
    simpleaf_index(step, ref_type, arguments = {}, output="simpleaf_index") ::
        local type = $.get(ref_type, "type");
        {
            type :: ref_type,
            arguments :: arguments,
            output :: output, 
        } +
        // ref type and arguments
        ref_type +
        // system fields
        {   
            "program-name" : "simpleaf index",
            active : $.get(arguments, "active", true, type != "existing_index"),
            step : step,
            "--output" : output,
        } +
        if type != "existing_index" || type != "direct_ref" then 
            {
                local o = output + "/simpleaf_index/index",
                "index" :: o,
                "t2g_map" :: o + "/t2g_3col.tsv",
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
            }
        else if type == "existing_mappings" then
            {
                "--map-dir" : $.get(arguments, "map_dir"),
                "--t2g-map" : $.get(arguments, "t2g_map"),
            } 
        else
            error "Unknown mapping type: %s" % type
    ,

    map_reads(reads1, reads2, simpleaf_index = {}) ::
        $.map_type("map_reads", {reads1: reads1, reads2: reads2}, simpleaf_index)
    ,
    existing_mappings(map_dir, t2g_map) ::
        $.map_type("existing_mappings", {map_dir: map_dir, t2g_map: t2g_map})
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
    unfiltered_pl(permitlist) ::
        $.cell_filtering_type("unfiltered_pl", permitlist)
    ,
    knee() ::
        $.cell_filtering_type("knee")
    ,
    forced_cells(num_cells) ::
        $.cell_filtering_type("forced", num_cells)
    ,
    expect_cells(num_cells) ::
        $.cell_filtering_type("expect", num_cells)
    ,
    explicit_pl(permitlist) ::
        $.cell_filtering_type("explicit_pl", permitlist)
    ,

    // create a simpleaf quant record
    simpleaf_quant(step, map_type, cell_filtering_type, arguments, output="simpleaf_quant") ::
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
            step : step,
            "--output" : output,
        } +
        $.get(arguments, "optional_arguments", true, {})
    ,
    get(o, f, use_default = false, default = null)::
        if std.isObject(o) then
            if std.objectHasAll(o, f) then
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
    minimizer_length(klen) :: std.ceil(klen / 1.8) + 1,

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