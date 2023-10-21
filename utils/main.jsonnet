function(workflow,patch=false,json={})
    if patch then
        std.mergePatch(workflow, patch)
    else
        workflow + json
