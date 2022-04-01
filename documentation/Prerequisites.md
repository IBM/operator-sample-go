# Prerequisites

**1. CLIs**

* [operator-sdk](https://sdk.operatorframework.io/docs/installation/) (comes with Golang)
* git
* kubectl
* podman
* [ibmcloud](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli) (if IBM Cloud is used)

**2. Operator SDK**

🔴 IMPORTANT: The repo has been tested with operator-sdk v1.18.1. Note that there is an issue with this version. It doesn't download the tools in the 'bin' directory. You need to use the older version v1.18.0 first, init a new temporary new project and copy the downloaded four files from the 'bin' directoy into the 'bin' subdirectories of both operators. After this update to v1.18.1.

**3. Image Registry**

Replace REGISTRY and ORG with your registry account and change the versions.

```
$ export REGISTRY='docker.io'
$ export ORG='nheidloff'
$ export IMAGE='application-operator:v2.0.0'
$ export BUNDLE_IMAGE="application-operator-bundle:v2.0.0"
$ export CATALOG_IMAGE="application-operator-catalog:v2.0.0"
```

**4. Kubernetes**

The instructions assume that you use the managed Kubernetes service on the IBM Cloud. You can also use any other Kubernetes service or OpenShift.

You need to log in to Kubernetes, for example:

```
$ ibmcloud login -a cloud.ibm.com -r eu-de -g resource-group-niklas-heidloff7 --sso
$ ibmcloud ks cluster config --cluster xxxxxxx
$ kubectl get all
```

**5. Repo**

```
$ git clone https://github.com/nheidloff/operator-sample-go.git
$ cd operator-sample-go
$ code .
```
