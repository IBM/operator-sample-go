# Prerequisites

### 1. Required CLIs

1. [operator-sdk](https://sdk.operatorframework.io/docs/installation/) (comes with Golang)
2. git
3. kubectl
4. podman
5. Only if IBM Cloud is used: [ibmcloud](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli)

### 1.1. Operator SDK

🔴 IMPORTANT: The repo has been tested with operator-sdk v1.18.1. Note that there is an issue with this version. It doesn't download the tools in the 'bin' directory. You need to use the older version v1.18.0 first, init a new temporary new project and copy the downloaded four files from the 'bin' directoy into the 'bin' subdirectories of both operators. After this update to v1.18.1.

### 2. Repo

```
$ git clone https://github.com/nheidloff/operator-sample-go.git
$ cd operator-sample-go
$ code .
```

### 3. Kubernetes Cluster

The instructions assume that you use the managed Kubernetes service on the IBM Cloud. You can also use any other Kubernetes service or OpenShift.

You need to log in to Kubernetes, for example:

```
$ ibmcloud login -a cloud.ibm.com -r eu-de -g resource-group-niklas-heidloff7 --sso
$ ibmcloud ks cluster config --cluster xxxxxxx
$ kubectl get all
```

### 4. Required Kubernetes Components

1. cert-manager
   * "kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.2/cert-manager.yaml"
   * [cert-manager](https://github.com/cert-manager/cert-manager) is needed for webhooks
2. OLM (Operator Lifecycle Manager)
   * "operator-sdk olm install --version v0.20.0"
3. Prometheus
   * "kubectl apply -f ../prometheus/operator/"
   * "kubectl apply -f ../prometheus/prometheus/"

### 5. Image Registry

Replace REGISTRY and ORG with your registry account. When creating new image versions later, change the versions in versions.env. 

```
$ export REGISTRY='docker.io'
$ export ORG='nheidloff'
$ podman login $REGISTRY
$ source versions.env
```