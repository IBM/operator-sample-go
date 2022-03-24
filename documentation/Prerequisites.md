# Prerequisites

* [operator-sdk](https://sdk.operatorframework.io/docs/installation/) (comes with Golang)
* git
* kubectl
* docker
* [ibmcloud](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli) (if IBM Cloud is used)

*Operator SDK*

The repo has been tested with operator-sdk v1.18.1. Note that there is an issue with this version. It doesn't download the tools in the 'bin' directory. You need to use an older version, init a new temporary new project and copy the files.

*Image Registry*

Replace REGISTRY and ORG with your registry account.

```
$ export REGISTRY='docker.io'
$ export ORG='nheidloff'
$ export IMAGE='application-operator:v2.0.0'
$ export BUNDLE_IMAGE="application-operator-bundle:v2.0.0"
$ export CATALOG_IMAGE="application-operator-catalog:v2.0.0"
```

*Kubernetes*

The instructions assume that you use the managed Kubernetes service on the IBM Cloud. You can also use any other Kubernetes service or OpenShift.