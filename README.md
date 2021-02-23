# docker-packer-ibmcloud
Build a docker container for the IBM Cloud CLI, based on container provided by IBM

## Purpose
Build a container for running `packer` with the IBM Cloud plugin installed as well as the tools required to run an `ansible` provisioner. A `Makefile` is setup to do all the work. And the `Makefile` is highly parameterized via the file `version.sh`.

## Authentication
To use the plugin credentials must be provided. These are credentials
to the classic infrastructure. These must be provided in the file
`.env`. The content should look like:

    SL_API_KEY=c95b3e4430e04d44405bf9f39caa189735cdc2d0ed0d9f8f0f3eba89bccb9784
    SL_USERNAME=<accnt#>_<useremail>


## Parameters
The `version.sh` file should contain the various values that could be expected to change over time. This would include version numbers, SHA codes for verification and source URLs.

## Makefile Targets

    make container
  This target will build the container using the provided `Dockerfile`

    make validate
  This target will run a `packer validate` on the packer tempalte file - `centos.json`. This template will create a CentOS-based machine, install `dnsmasq` and run the ansible playbook to install and enable the Apache web server.

    make build
  Execute the `packer build` on the packer template  `centos.json`

    make no-ansible
  Execute `packer build` on the template file `centos-no-ansible.json` file. This installs `dnsmasq` like the base template, but it does not try to execute the ansible provisioner.

    make run
  This will invoke `docker run` with the container, but change the entry point to `bash` to allow inspection and debugging of the container.
  
