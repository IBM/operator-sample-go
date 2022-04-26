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

Any newer Kubernetes cluster should work. The Operator SDK version v1.18.1 has been [tested](https://github.com/kubernetes/client-go#versioning) with Kubernetes v1.23. You can also use OpenShift. We have mostly tested the two operators with IBM Cloud Kubernetes Service and IBM Red Hat OpenShift on IBM Cloud.

Log in to Kubernetes or OpenShift, for example:

```
$ ibmcloud login -a cloud.ibm.com -r eu-de -g resource-group-niklas-heidloff7 --sso
$ ibmcloud ks cluster config --cluster xxxxxxx
$ kubectl get all
```

```
$ oc login --token=sha256~xxxxx --server=https://c106-e.us-south.containers.cloud.ibm.com:32335
$ kubectl get all
```

### 4. Required Kubernetes Components

4.1. cert-manager
   
* Needed for Kubernetes AND OpenShift
* "kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.2/cert-manager.yaml"
* Or "https://operatorhub.io/operator/cert-manager"

4.2. OLM (Operator Lifecycle Manager)

* Only needed for Kubernetes (included in OpenShift)
* Operator SDK: "operator-sdk olm install --version v0.20.0"
* Or via download: "curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.20.0/install.sh | bash -s v0.20.0"

4.3. Prometheus

* Only needed for Kubernetes (included in OpenShift)  
* Operator: "kubectl apply -f prometheus/operator/"
* Prometheus: "kubectl apply -f prometheus/prometheus/"

### 5. Image Registry

If you want to run the samples without modifications, nothing needs to be changed.

If you want to change them, replace REGISTRY and ORG with your registry account and change the version numbers in versions.env. 

```
$ code versions.env
$ podman login $REGISTRY
$ source versions.env
```
