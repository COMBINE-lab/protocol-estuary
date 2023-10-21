function(workflow,patch=false,json={})
    if patch then
        std.mergePatch(workflow, json)
    else
        workflow + json
