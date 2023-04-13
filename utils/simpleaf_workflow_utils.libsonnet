{
    // input: two boolean
    // output: logical or
    logical_or(a,b)::
        a || b
    ,

    // input: two boolean
    // output: logical and
    logical_and(a,b)::
        a && b
    ,

    // this function returns the querying field of the object if it exiests,
    // otherwise, it returns an error  
    // input: an object, a field name
    // output: the field of the object if exist
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

    // This function checks if there are simpleaf arguments in the object
    // according to the internal arg library we if there are, returns an error  
    // input: an object
    // output: if all args are valid, then outputs the object itself
    //          else,  return an error
    check_invalid_args(o, name = "")::
    {
        local field = $.get(o, field_name),
        [field_name]: 
            // skip meta info and root layer values
            if field_name == "meta_info" || !std.isObject(field) then
                field
            // if we see Step, then this field should be a command record
            else if std.objectHas(field, "Step") then
                // there should be a Program Name field
                if std.objectHas(field, "Program Name") then
                    local program_name = $.get(field, "Program Name"); 
                    // check if it is a simpleaf command
                    if std.objectHas($.SimpleafPrograms, program_name) then
                        if std.foldl(
                            $.logical_and, 
                            // here we check if each arg in this command record 
                            // is a valid argument
                            std.map(function(x, arg_obj = $.get($.SimpleafPrograms, program_name))
                                if std.objectHas(arg_obj, x) then 
                                    true
                                else
                                    error "Found invalid simpleaf %s arguments %s in %s in the provided JSON file; Cannot proceed." % 
                                            [field_name, x, name + field_name],
                                std.objectFields(field)), 
                            init=true
                        ) then 
                            field
                        else
                            error "invalid args"
                    else
                        field
                else
                    error "Found record with Step but no  Program Name: %s; Cannot proceed." % name + field_name
            else
                $.check_invalid_args(field,  name + field_name + " -> ")
        for field_name in std.objectFields(o)
    },

    // This function checks if there is there is any field with a null value
    // in the final object 
    // input: an object
    // output: if there is no null value, then return the object
    //          else return an error
    check_missing_args(o, name = ""):: {
        local field = $.get(o, field_name),
        [field_name]: 
            if field == null then
                error "The '%s' field in %s has a null value in the final workflow; Cannot proceed." % [field_name, name + field_name]
            else if std.isObject(field) then
                $.check_missing_args(field, name + field_name + " -> ")
            else field
        for field_name in std.objectFields(o)
    },

    //  this function filters the args that has a null value
    // input: an object
    // output: the fields that has a null value
    get_missing_args(o):: 
    {
        local field = $.get(o, field_name),
        [
            local field = $.get(o, field_name);
            if field == null || 
                    std.isObject(field) 
            then 
                field_name
        ]: 
            if std.isObject(field) then
                $.get_missing_args(field)
            else
                field
        for field_name in std.objectFields(o)
    },

    // get the valid output dir
    // input: a top level arg called output and a user provided arg object
    
    get_output(o)::
        local meta_info = $.get(o, "meta_info", use_default=true);
        local config = $.get(meta_info, "output", use_default=true);
        if config == null then
            local cmd = std.extVar("output");
            cmd + "/workflow_output"
        else
            config
    ,

    // internal function for adding `--output` args to simpleaf commands
    add_outdir_sub(o, output, name):: 
        {
            local field = $.get(o, field_name),
            [field_name]:
                if std.isObject(field) then
                    // if it is a simpleaf command record, then we add --output if doesn't exist
                    if  std.objectHas(field, "Step") then
                        if !std.objectHas(field, "Program Name") then
                            error "Found a command record with no 'Program Name' field: %s; Cannot proceed." % name + field_name
                        else
                            local program_name = $.get(field, "Program Name");
                            local program_args = $.get($.SimpleafPrograms, program_name, use_default=true);
                            if program_args != null then
                                if std.objectHas(program_args, "--output") then
                                    // make sure the program
                                    if $.get(field, "--output", use_default=true) == null then
                                        // doesn't need any more 
                                        field + {"--output": output + "/" + field_name}
                                    else
                                        field
                                else 
                                    field
                            else
                                field
                    else
                        $.add_outdir_sub(field, "%s/%s" % [output, field_name],  name + field_name + " -> ")
                else
                    field
            for field_name in std.objectFields(o)
        }
    ,

    // the user provides a output directory, we will create subdirs to store the results
    // from simpleaf commands (just want to make the output dir less messy)
    // input: an output directory, and a workflow object
    add_outdir(o, output)::
        $.add_outdir_sub(o, output, "") + 
            {meta_info+: {output: output}}
    ,

    // this tells jsonnet to update the object fields (using :+ instead of :) instead of overwriting them
    // not used anymore
    // input: an object contains simpleaf program arg objects
    // output: make everything in the object overriding (+:) 

    // this add the t2g file generated by simpleaf to --t2g-map
    // only expanded ref indices can do this
    // input: an workflow object
    // output: and overriding object contains 
    // the t2g file links in all quant command objects
    // NOTE: Not required anymore, as simpleaf will take care of this.
    override_t2g_if_needed(o):: {
        local field = $.get(o, field_name),
        [field_name] +: 
            if std.objectHas(field, "index") && std.objectHas(field, "quant") then
                local field_index_o = $.get(field, "index");
                if std.objectHas(field_index_o, "--fasta") && 
                    std.objectHas(field_index_o, "--gtf") &&
                    !std.objectHas(field_index_o, "--ref-seq")  
                then
                    {"quant" +: {"--t2g-map": $.get(field_index_o, "--output") + "/index/t2g_3col.tsv"}}
                else {}
            else if std.objectHas(field, "index") || std.objectHas(field, "quant") then
                {}
            else if std.isObject(field) then
                {}
            else
                $.override_t2g_if_needed(field)
        for field_name in std.objectFields(o)
    },

    // update the workflow template using user provided args
    // input: an workflow object, and a user provided arg object. 
    //          These two should have the same structure,
    //          Otherwise the result will be the combination of these two

    // TODO: might required for essential mode (output only essential args)
    update_workflow(o, patch)::
    // if the input is an object in both original and patch
    // traverse the union of their field name
    if std.isObject(o) && std.isObject(patch) then 
    {
        [field_name]: 
            // if it is a object in both
            // we keep traversing,
            if std.objectHas(o, field_name) && std.objectHas(patch, field_name) then
                // keep traversing
                $.update_workflow($.get(o, field_name), 
                                        $.get(patch, field_name)
                                    )
            // if this object is only in original, then we return original field
            else if std.objectHas(patch, field_name) then
                $.get(patch, field_name)
            // if this object is only in patch, we return patch field
            else if std.objectHas(o, field_name) then
                $.get(o, field_name)
        // we traverse all fields in both objects,
        // so that we will not ignore the args that 
        // appear only in one object
        for field_name in std.set(std.objectFields(o) + std.objectFields(patch))
    } else if patch != null then
        patch
    else
        o
    ,

    // This function recursively search the field with a given field name and 
    // returns a nested array. The result must be flatten before user
    recursive_search(o, target_name):: 
        std.prune([
            local field = o[field_name];
            if field_name == target_name then
            field
            else if std.isObject(field) then
            $.recursive_search(field, target_name)
            else null
        for field_name in std.objectFields(o)
        ])
    ,

    // THis is a helper funcion for flatting a nested array.
    // There must exist only one single value in all nested array 
    flat_arr(arr, target_name, path):: 
    if std.length(arr) == 0 then
        null
    else if std.length(arr) > 1 then
        error "The argument %s is provided multiple times in %s" % [target_name, path]
    else if std.isArray(arr[0])
    then
        $.flat_arr(arr[0], target_name, path)
    else
        arr[0]
    ,

    // THis function recursively get the value of a given field name.
    // The field name must appear in only once in all nested fields.
    recursive_get(o, target_name, path)::
        $.flat_arr($.recursive_search(o, target_name), target_name, path)
    ,

    // 2. we parse cell filtering methods
    flat_arg_groups(o, path = ""):: 
    if o == null then 
        {}
    else {
            local field = $.get(o, field_name),
            [field_name] +:
                if std.isObject(field) then
                    // if it is a simpleaf command record, then we add --output if doesn't exist
                    if std.objectHas(field, "Step") then
                        if !std.objectHas(field, "Program Name") then
                            error "Found a command record with no 'Program Name' field: %s; Cannot proceed." % path
                        else
                            local program_name = $.get(field, "Program Name");
                            // if we see "simpleaf index" then we process it
                            if std.objectHas($.SimpleafPrograms, program_name) then
                                // then find the correspondence of the possible 
                                // args in user defined outputs
                                std.prune({   
                                    [arg_name] : $.recursive_get(field, arg_name, path)
                                    for arg_name in std.objectFields($.get($.SimpleafPrograms, program_name))
                                })
                                // else we keep searching
                                else
                                    field
                    else
                        $.flat_arg_groups(field, path + field_name + " -> ")
                else
                    field
        for field_name in std.objectFields(o)
    },

    // This function combines the arguments in required and optional sections
    // If fir a specific simpleaf command, an argument appears in both required and optional sections, 
    // Then the value provided in the required section will be used 
    combine_main_sections(o):: 
        local oc = "Optional Configuration";
        local rc = "Recommended Configuration";
        local ec = "External Commands";
        local mi = "meta_info";
        // assemble the workflow
        std.prune({[ec]: $.get(o, ec, use_default=true)} +
            $.flat_arg_groups($.get(o, oc, use_default=true)) + 
            $.flat_arg_groups($.get(o, rc, use_default=true)) + 
            {[mi]: $.get(o, mi, use_default=true)})
    ,

    // This function returns only the missing arguments in the 
    // Recommended Configuration section.
    // Those arguments are the essential config for å workflow
    write_recommended_args(o):: 
        $.get_missing_args(
            {
                [field_name]: $.get(o, field_name)
                for field_name in std.objectFields(o)
                if field_name == "Recommended Configuration"
            }
    ),

    add_meta_args_sub(o, threads, use_piscem, output, name)::
    {
            local field = $.get(o, field_name),
            [field_name]:
                if std.isObject(field) then
                    // if it is a simpleaf command record, then we add --output if doesn't exist
                    if  std.objectHas(field, "Step") then
                        if !std.objectHas(field, "Program Name") then
                            error "Found a command record with no 'Program Name' field: %s; Cannot proceed." % name + field_name
                        else
                            local program_name = $.get(field, "Program Name");
                            local program_args = $.get($.SimpleafPrograms, program_name, use_default=true);
                            if program_args != null then
                                field + std.prune({
                                    // add threads and avoid modifying it if --threads was provided  
                                    [if std.objectHas(program_args, "--threads") && threads != null then "--threads"]:
                                        local given_threads = $.get(field, "--threads", use_default=true);
                                        if given_threads == null then
                                            threads
                                        else
                                            given_threads
                                    ,
                                    // add output and avoid modifying it if --output was provided  
                                    [if std.objectHas(program_args, "--output") && output != null then "--output"]:
                                        local given_output = $.get(field, "--output", use_default=true);
                                        if given_output != null then
                                            given_output
                                        else
                                            output + "/" + field_name
                                    ,

                                    // // TODO: abundon this chunk when piscem bug is fixed
                                    // // currently piscem has an bug: it will fail if setting custom kmer length.
                                    // // So, here I check if --kmer-length flag is set. 
                                    // // If it is set, then no piscem. Otherwise, we can call piscem if asked
                                    // // If this bug is fixed, then we can turn to the logics implmented below
                                    [
                                        if std.objectHas(program_args, "--use-piscem") && use_piscem then 
                                            "--use-piscem"
                                    ]: ""
                                    ,
                                    [
                                        if program_name == "simpleaf index" &&
                                            use_piscem 
                                        then
                                            "--overwrite"
                                    ]: "",

                                    // TODO: ask Julio if we have some simple formula to set minimizer length according to kmer length 
                                    // In piscem, minimizer length must be smaller than kmer length
                                    // however, salmon doesn't use minimizer, so it doesn't have this restriction
                                    // As we want to switch between salmon and piscem, when using piscem, we have to manually set minimizer length 
                                    // if the kmer-length is no larger than the default minimizer length (19).
                                    [
                                    // get kmer and minimizer length from workflow 
                                    local given_kmer_length = $.get(field, "--kmer-length", use_default=true);
                                    local given_minimizer_length = $.get(field, "--minimizer-length", use_default=true);
                                    
                                    // set the criteria
                                    if program_name == "simpleaf index" && use_piscem then
                                        if given_kmer_length != null && given_minimizer_length == null then
                                            // default minimizer-length is 19, make sure the provided kmer-length is greater than that
                                            if std.parseInt(given_kmer_length) < 20 then
                                                "--minimizer-length"
                                    ]:
                                        // the same var defined above cannot be recognized in this scope
                                        local given_kmer_length = $.get(field, "--kmer-length", use_default=true, default=31);
                                        // 1.8 is used here because by using this, passing 31 here will get 19
                                        std.toString(std.ceil(std.parseInt(given_kmer_length)/1.8)+1)
                                })
                            else
                                field
                    else
                        $.add_meta_args_sub(field, threads, use_piscem, "%s/%s" % [output, field_name], name + field_name + " -> ")
                else
                    field
        for field_name in std.objectFields(o)
    }
    ,

    add_meta_args(o)::
        local output = $.get_output(o);
        local mi = $.get(o, "meta_info", use_default=true);
        local threads = $.get(mi, "threads", use_default=true);
        local use_piscem = $.get(mi, "use-piscem", use_default=true, default = false);

        $.add_meta_args_sub(o, threads, use_piscem, output, "") + 
            {meta_info+: {output: output}}
    ,

    // internal function for adding `--output` args to simpleaf commands
    // this function only works for the experiment who has both simpleaf_index and simpleaf_quant
    // records
    add_index_dir_for_simpleaf_index_quant_combo(o)::

        if std.isObject(o) then
            // check if it has a record called `simpleaf_index`
            if  std.objectHas(o, "simpleaf_index") then
                // check if it also has simpleaf_qunt
                if std.objectHas(o, "simpleaf_quant") then
                    // define variables
                    local index = $.get(o, "simpleaf_index");
                    local quant = $.get(o, "simpleaf_quant");
                    local index_output = $.get(index, "--output", use_default=true);
                    local index_t2g = $.get(index, "--output", use_default=true);

                    // if this record doesn't have --index and --map-dir then we can add --index 
                    if !std.objectHas(quant, "--index") && !std.objectHas(quant, "--map-dir") then
                        // if the index command has a valid --output, then use it has the index in the quant 
                        if index_output != null then
                            o + {"simpleaf_quant"+: {"--index": index_output+"/index"}}
                        else
                            o
                    else
                        o
                else o
            else
                {
                        local field = $.get(o, field_name),
                        [field_name]: $.add_index_dir_for_simpleaf_index_quant_combo(field)
                    for field_name in std.objectFields(o)
                }
        else
            o
    ,




    // the object contains all valid arguments of simpleaf programs.
    // They all have a null value.
    SimpleafPrograms::
    {
        'simpleaf index': {
            // This is used for deciding by which order the commands are run
            "Step": null,
            "Program Name": 'simpleaf index',
            "Active": null,

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
            "Step": null,
            "Program Name": 'simpleaf quant',
            "Active": null,

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


