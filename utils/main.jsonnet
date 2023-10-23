function(workflow,patch=false,json={})
    local makeMergeable(o) = {
    [key]+: makeMergeable(o[key])
    for key in std.objectFields(o)
    if std.isObject(o[key])
    } + {
    [key]: o[key]
    for key in std.objectFields(o)
    if !std.isObject(o[key])
    };

    local manifest = if patch then
        workflow + makeMergeable(json)
    else
        workflow
    ;
    std.prune({
        meta_info : manifest.meta_info,
        workflow : manifest.workflow,
    })
