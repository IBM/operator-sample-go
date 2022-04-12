# Database Operator

See below for instructions how to set up and run the database operator either locally or on Kubernetes.

Install [prerequisites](../documentation/Prerequisites.md).

### Run operator locally

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

### Run operator on Kubernetes

Deploy the operator:

```
$ source ../versions.env
$ make deploy IMG="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"
$ kubectl apply -f config/rbac/role_patch.yaml 
$ kubectl apply -f config/rbac/role_binding_patch.yaml 
```

From a terminal run this command:

```
$ kubectl apply -f config/samples/database.sample_v1alpha1_database.yaml
```

Delete all resources:

```
$ kubectl delete -f config/samples/database.sample_v1alpha1_database.yaml
$ make undeploy IMG="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"
```

### Build new Image

```
$ code ../versions.env
$ source ../versions.env
$ podman build -t "$REGISTRY/$ORG/$IMAGE_DATABASE" .
$ podman push "$REGISTRY/$ORG/$IMAGE_DATABASE"
```
