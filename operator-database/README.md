# Database Operator

See below for instructions how to set up and run the database operator either locally or on Kubernetes.

Install [prerequisites](../documentation/Prerequisites.md).

**Run operator locally**

From a terminal run this command:

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

**Run operator on Kubernetes**

Deploy the operator:

```
$ make deploy IMG="docker.io/nheidloff/database-operator:v1.0.3"
```

From a terminal run this command:

```
$ kubectl apply -f config/samples/database.sample_v1alpha1_database.yaml
```

Delete all resources:

```
$ kubectl delete -f config/samples/database.sample_v1alpha1_database.yaml
$ make undeploy IMG="docker.io/nheidloff/database-operator:v1.0.3"
```