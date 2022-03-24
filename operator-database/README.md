# Database Operator

See below for instructions how to set up and run the database operator as well as the used commands for the development of it.

### Setup and Usage

The instructions below assume that you use the managed Kubernetes service on the IBM Cloud. You can also use any other Kubernetes service or OpenShift.

Get the code:

```
$ https://github.com/ibm/operator-sample-go.git
$ cd operator-database
$ code .
```

Login to Kubernetes:

```
$ ibmcloud login -a cloud.ibm.com -r eu-de -g resource-group-niklas-heidloff7 --sso
$ ibmcloud ks cluster config --cluster xxxxxxx
```

Install custom resource definition:

```
$ kubectl apply -f config/crd/bases/database.sample.third.party_databases.yaml
```

From a terminal in VSCode run this command:

```
$ make install run
```

From a second terminal run this command:

```
$ kubectl apply -f config/samples/database.sample_v1alpha1_database.yaml
```

Delete all resources:

```
$ kubectl delete -f config/samples/database.sample_v1alpha1_database.yaml
$ make uninstall
```

Build and push the image:

```
$ make docker-build docker-push IMG="docker.io/nheidloff/database-operator:v1.0.1"
```

Deploy the operator:

```
$ make deploy IMG="docker.io/nheidloff/database-operator:v1.0.1"
```

Undeploy the operator:

```
$ make undeploy IMG="docker.io/nheidloff/database-operator:v1.0.1"
```