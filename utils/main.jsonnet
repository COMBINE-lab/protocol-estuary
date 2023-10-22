function(template,patch=false,json={})
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
        template + makeMergeable(json)
    else
        std.mergePatch(template, json)
    ;
    std.prune({
        meta_info : manifest.meta_info,
        template : manifest.template,
    })
