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

    if patch then
        workflow + makeMergeable(json)
        // std.mergePatch(workflow, json)
    else
        workflow
