# Nextflow for DNAnexus Platform

## What is Nextflow?

Nextflow is a workflow manager that enables scalable and reproducible scientific workflows using software containers.
Learn more at [https://nextflow.io](https://nextflow.io).

## What does this app do?

This app allows the deployment of Nextflow pipelines on the DNAnexus cloud, taking advantage of 
native integration with the platform, and allowing users to manage their data analyses collaboratively 
within the familiar DNAnexus environment.

Note: this app requires an activation license provided by [Seqera Labs](https://www.seqera.io/). 
Contact sales@seqera.io to obtain an evaluation license and more details. 

## What are the input files?

You need to provide the URL of the Git repository where a Nextflow pipeline project is stored 
and any input data as expected by the chosen pipeline project.

Nextflow pipelines can access files stored in DNAnexus projects prefixing the file paths with 
corresponding project ID, e.g. `dx://PROJECT-0123456789:/some/data/file.bam`.

## What are the output files?

The Nextflow app allows you to run new or existing Nextflow pipelines in the DNAnexus cloud. 
The app output files depends on the pipeline you run.

If the pipeline allows the definition of one or more output file paths, prefix them with the 
DNAnexus project ID where the output is expected to be stored e.g. `dx://PROJECT-0123456789:/some/output`.     

## Input parameters

* license: The activation license provided by Seqera Labs
* pipeline_url: The URL of the Git repository of the pipeline to the executed
* args: Nextflow run options and pipeline parameters (optional)
* scm_file: Git repository credentials file (optional)
* docker_creds_file: Docker registries credentials file (optional)
* resume_id: The execution Id of the pipeline run to be resumed as reported in the execution log (optional)
* opts: Nextflow runtime advanced options (optional)  
* debug: Enable launcher script debugging mode (optional)

## Use of Git private repository

The access of Git private repository is supported using the usual
Nextflow [scm](https://www.nextflow.io/docs/latest/sharing.html?#scm-configuration-file) file holding the repository access credentials.

Upload *scm* file into a DNAnexus project where the pipeline is expected to run, then
specify the file path as an input parameter of the Nextflow app using the `scm_file`
parameter e.g. `project-123456789:/my-scm.txt`.

## Use of Docker private registry

The access of Docker images hosted in a private registry is supported by providing the
registry credentials via JSON file formatted as shown below:

```
{
  "user": "<YOUR USER NAME>",
  "password": "<YOUR PASSWORD>",
  "registry": "docker.io"
}
```
