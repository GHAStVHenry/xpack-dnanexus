# XPACK-DNANEXUS

DNAnexus extension package for Nextflow (XPACK-DNANEXUS)

## Introduction 

The DNAnexus extension package is a plugin provided by [Seqera Labs](https://www.seqera.io/) that enables the deployment of 
[Nextflow](https://www.nextflow.io/) pipelines on the [DNAnexus](https://www.dnanexus.com/) cloud platform. 

The plugin requires a license key to be used. If you are interested, please contact us for an evaluation license at [sales@seqera.io](maiilto:sales@seqera.io).

NOTE: The plugin is still in beta version and some Nextflow functionalities are limited. See below for the known problems and limitations.  

## Requirements 

* DNAnexus command line tools aka dx-toolkit. See [here](https://documentation.dnanexus.com/getting-started/tutorials/cli-quickstart) 
for details.
* Nextflow runtime version 21.09.0-edge or later. 
* Valid license for DNAnexus extension package for Nextflow.  
* [Make](https://www.gnu.org/software/make) tool (only for the project bundling). 

## Get started 

In order to deploy the execution of a Nextflow pipeline in DNAnexus you will need to create 
a DNAnexus applet bundling the Nextflow runtime along the DNAnexus extension plugin and, optionally, 
the pipeline scripts.

In alternative to bundling the pipeline in the DNAnexus applet, it can be pulled from a Git repository 
as is usually done by Nextflow. 

The `Makefile` included in this repository automates the creation of the DNAnexus applet for Nextflow using the following steps: 

#### 0. Login in your DNAnexus workspace 

```
dx login
```

#### 1. Clone this repository in your computer using the following command

``` 
git clone https://github.com/seqeralabs/xpack-dnanexus
cd xpack-dnanexus
```

#### 2. Create the DNAnexus bundle including the Nextflow runtime 

```
make dx-pack
```

The above command creates the bundle skeleton in the directory `build/nextflow-dx`.  

#### 3. Modify the app metadata (optional)

DNAnexus app requires a file named `dxapp.json` to configure the application deployment 
and parameters. 

A predefined app metadata file with the settings required for the Nextflow execution 
is available in this repository at the path [app/dxapp.json](app/dxapp.json). Modify it according your 
requirements. 

See the [DNAnexus documentation](
https://documentation.dnanexus.com/developer/apps/app-metadata) for further details.


#### 4. Build the DNAnexus applet

``` 
make dx-build
```

The above command build the DNAnexus applet for Nextflow with the name `nextflow-dx` ready to be executed. 

#### 5. Upload license file to DNAnexus

The best practice to store XPACK license and any other credentials files is to create a dedicated DNAnexus project and upload and store safely those files. Once this project is created, grab the project unique ID and define the following environment variable.

```
export DX_CREDS_PROJECT=project-123456789
```

In the above snippet replace `project-123456789` with your DNAnexus project where 
the license file was uploaded. 

#### 6. Example runs

You can find below some examples on how to deploy the execution of Nextflow with the applet built following the above guide.

Those examples assume the license file has been given the name `xpack-license.txt` 
and uploaded into the DNAnexus project referenced by the environment 
variable `DX_CREDS_PROJECT`.


##### Launching classic NF Hello world app 

    dx run nextflow-dx \
      --watch \
      --delay-workspace-destruction \
      --input-json "$(envsubst < examples/hello.json)" 

The above snippet runs the Nextflow [hello](https://github.com/nextflow-io/hello) pipeline.

The Nextflow log file will be uploaded in your DNAnexus project root. You can access with the following 
command:

```
dx cat nextflow.log
```
  
##### Launching simple RNAseq pipeline using container execution 

    dx run nextflow-dx \
        --watch \
        --delay-workspace-destruction \
        --input-json "$(envsubst < examples/simple-rnaseq.json)"
    
The above snippet the rnaseq-nf pipeline at [this link](https://github.com/nextflow-io/rnaseq-nf).

The `args` input field is used to specify the Nextflow command line option `-profile` that selects the `docker` profile enabling the use of Docker container.

Note pipeline results are stored in the local `results` directory in the VM running the Nextflow app. 

To save the result in the DNAnexus project storage, add to the `args` attribute in the [examples/simple-rnaseq.json](examples/simple-rnaseq.json) file, the option `--outdir dx://<YOUR PROJECT ID>:/some/output/dir`, replacing the placeholder `<YOUR PROJECT ID>` with the project id that can be found using this oneliner:

```
dx env | grep project | cut -f 2
```

NOTE: The `dx://` pseudo-protocol is used by Nextflow to identify file paths 
in the DNAnexus storage. 

##### Launching nf-core RNAseq pipeline 

    dx run nextflow-dx \
        --watch \
        --delay-workspace-destruction \
        --instance-type mem3_ssd3_x12 \
        --input-json "$(envsubst < examples/nfcore-rnaseq.json)"

The above example launch shows how to run the exection of the [nf-core/rnaseq](https://github.com/nf-core/rnaseq) pipeline using the `test` profile  

## Pipeline scratch and output files

Nextflow stores the tasks temporary files (i.e. the pipeline *work directory*) 
in the temporary storage container assigned by DNAnexus when lunching the pipeline 
execution. Note: make sure to enable the *delay workspace destruction* feature 
if you want to be able to resume the pipeline execution in a successive execution.

Moreover input files are stored into a file system other than the DNAnexus storage, 
and *staged* (ie. copied) into a temporary folder in the current DNAnexus project
at the path `$DX_PROJECT_CONTEXT_ID:/.nextlow/stage`. 

## Resume pipeline executions

The ability to resume pipeline executions is a core Nextflow 
feature that allows continuing a run of previously executed pipeline.

When using the DNAnexus executor, the pipeline resume is possible with the following caveats:

* The executions are in the same project container.
* The *delay workspace destruction* DNAnexus feature was enabled for the run to be resumed and the data is still available.
* The *resume ID* of the execution to be resumed is provided when launching the new pipeline run using the `--input resume_id=<RESUME ID>` command line option. 


The resume ID is printed in the execution log header. For example:

        =============================================================
        === NF work-dir : container-1234567890:/scratch/
        === NF Resume ID: 45ed7ad7-a327-4b64-8c0f-e5d6360b39e7
        === NF log file : project-1234567890:nextflow-xxxx-yyyy.log
        === NF cache    : project-1234567890:/.nextflow/cache/45ed7ad7-a327-4b64-8c0f-e5d6360b39e7
        =============================================================


Copy the resume ID from the previous execution and provide it in the launch command line
as shown below:

    dx run nextflow-dx \
        --watch \
        --delay-workspace-destruction \
        --input-json "$(envsubst < examples/hello.json)" 
        --input resume_id=45ed7ad7-a327-4b64-8c0f-e5d6360b39e7


## Use of Git private repository

The access of Git private repository is supported using the usual
Nextflow [scm](https://www.nextflow.io/docs/latest/sharing.html?#scm-configuration-file) file holding the repository access credentials.

Upload *scm* file into a DNAnexus project where the pipeline is expected to run, then
specify the file path an an input parameter of the Nextflow app using the `scm_file`
parameter e.g. `project-123456789:/my-scm.txt`.

## Use of Docker private registry

The access of Docker images hosted on private registry is supported providing the
registry credentials via JSON file formatted as shown below:

```
{
  "user": "<YOUR USER NAME>",
  "password": "<YOUR PASSWORD>",
  "registry": "docker.io"
}
```

Upload the credentials into a DNAnexus project where the pipeline is expected to run,  
then specify the file path an an input parameter of the Nextflow app using the `docker_creds_file` parameter e.g. `project-123456789:/my-docker-creds.json`.


## Latest changes
- Version `1.0.0-beta.4` adds the support for Nextflow resume feature.
- Version `1.0.0-beta.3` adds the support for Docker private registry. Moreover
  it fixes the support for DNAnexus Azure region.
- As of version `1.0.0-beta.2` directives [cpus](https://www.nextflow.io/docs/latest/process.html#cpus), [memory](https://www.nextflow.io/docs/latest/process.html#memory), [disk](https://www.nextflow.io/docs/latest/process.html#disk) and [accelerator](https://www.nextflow.io/docs/latest/process.html#accelerator)
  are supported. When specified Nextflow look up for a machine type able to 
  satisfy the requested resources. The `machineType` directive has in any case 
  precedence, when specified any `cpus`, `memory`, `disk` and `accelerator`
  is ignored. 

## Known problems and limitations

* When the pipeline execution terminates abruptly the Nextflow log file is not uploaded the target project storage.
* Some [Biocontainers](https://biocontainers.pro/) may not work properly.  

## Copyright 

Seqera Labs, All rights reserved.  
