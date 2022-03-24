# operator-database

See below for instructions how to set up and run the database operator as well as the used commands for the development of it.

### Setup and Usage

The instructions below assume that you use the managed Kubernetes service on the IBM Cloud. You can also use any other Kubernetes service or OpenShift.

Get the code:

```
$ https://github.com/nheidloff/operator-sample-go.git
$ cd operator-database
$ code .
```

Login to Kubernetes:

```
$ ibmcloud login -a cloud.ibm.com -r eu-de -g resource-group-niklas-heidloff7 --sso
$ ibmcloud ks cluster config --cluster xxxxxxx
```

Configure Kubernetes:

```
$ kubectl create ns database
$ kubectl config set-context --current --namespace=database
$ kubectl apply -f ../operator-database/config/crd/bases/database.sample.third.party_databases.yaml
```

From a terminal in VSCode run these commands:

```
$ make install run
$ kubectl apply -f config/samples/database.sample_v1alpha1_database.yaml -n database 
```

You can now see the custom resource in the Kubernetes dashboard or by using kubectl.

All resources can be deleted:

```
$ kubectl delete -f config/samples/database.sample_v1alpha1_database.yaml -n database
```

### Development Commands

Commands used for the project creation:

```
$ operator-sdk init --domain third.party --repo github.com/nheidloff/operator-sample-go/operator-database
$ operator-sdk create api --group database.sample --version v1alpha1 --kind Database --resource --controller
$ make generate
$ make manifests
```