# Setup Options and Prerequisites

See below for instructions how to set up and run the application operator as well as the used commands for the development of it.

The following instructions assume that you use the managed Kubernetes service on the IBM Cloud. You can also use any other Kubernetes service or OpenShift.

There are three ways to run the operator:

1) [Local Go Operator](SetupLocal.md) 
2) [Kubernetes Operator manually deployed](SetupManualDeployment.md)
3) [Kubernetes Operator deployed via OLM](SetupDeploymentViaOLM.md)
    * via operator-sdk
    * via kubectl

### Prerequisites

* [operator-sdk](https://sdk.operatorframework.io/docs/installation/) (comes with Golang)
* git
* kubectl
* docker
* [ibmcloud](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli) (if IBM Cloud is used)

*Operator SDK*

The repo has been tested with operator-sdk v1.18.1. Note that there is an issue with this version. It doesn't download the tools in the 'bin' directory. You need to use an older version, init a new temporary new project and copy the files.

*Image Registry*

```
$ export REGISTRY='docker.io'
$ export ORG='nheidloff'
$ export IMAGE='application-controller:v31'
$ export BUNDLE_IMAGE="application-controller-bundle:v16"
$ export CATALOG_IMAGE="application-controller-catalog:v1"
```

### Commands for initial Development

Commands for the project creation:

```
$ operator-sdk init --domain ibm.com --repo github.com/nheidloff/operator-sample-go/operator-application
$ operator-sdk create api --group application.sample --version v1alpha1 --kind Application --resource --controller
$ make generate
$ make manifests
```

Commands for the bundle creation:

```
$ make bundle IMG="$REGISTRY/$ORG/$IMAGE"
```

Commands for the webhook creations:

```
$ operator-sdk create webhook --group application.sample --version v1alpha1 --kind Application --defaulting --programmatic-validation --conversion
$ make manifests
$ make install
$ make run ENABLE_WEBHOOKS=false
```

Command for the catalog creation:

```
$ make catalog-build docker-push CATALOG_IMG="$REGISTRY/$ORG/$CATALOG_IMAGE" BUNDLE_IMGS="$REGISTRY/$ORG/$BUNDLE_IMAGE" IMG="$REGISTRY/$ORG/$CATALOG_IMAGE"
```