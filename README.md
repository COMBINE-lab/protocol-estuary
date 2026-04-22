# protocol-estuary

This repository is a library of published [`simpleaf workflow`](https://simpleaf.readthedocs.io/en/latest/workflow.html) templates for easing the commonly and frequently used single-cell data processing pipelines using alevin-fry ecosystem of tools. 

Using the power of [Jsonnet](https://jsonnet.org/), each workflow template published here can be converted to a valid workflow description after filling some required information. For details, please check this the [GitHub repository](https://github.com/COMBINE-lab/simpleaf) and [documentation](https://simpleaf.readthedocs.io/en/latest/index.html).

## Prerequisites

On some systems the default open-file limit is too low for piscem indexing.
Before running any workflow that builds an index, increase the limit in your shell:

```bash
ulimit -n 2048
```

## Usage

One can fetch individual workflows using the [`simpleaf workflow get`](https://simpleaf.readthedocs.io/en/latest/workflow-get.html) command.
To execute a workflow, one can simply fill required information in its template and pass the template to [`simpleaf workflow run`](https://simpleaf.readthedocs.io/en/latest/workflow-run.html).

## Contribution
Our dedicated team is actively developing and publishing new workflow templates into this repository. If you would like to share the workflow template you desired, you are more than welcome to make pull requests and tell us how cool your templates are!

