function(workflow,patch,json={})
    if patch then
        std.mergePatch(workflow, patch)
    else
        workflow + patch
