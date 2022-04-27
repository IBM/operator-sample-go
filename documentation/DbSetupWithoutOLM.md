# Database Operator - Operator deployed without OLM

🔴 IMPORTANT: First install the [prerequistes](Prerequisites.md)! If you don't do it, it won't work :)

### Deploy database operator

```
$ cd operator-database
$ source ../versions.env
$ make deploy IMG="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"
$ kubectl apply -f config/rbac/role_patch.yaml 
$ kubectl apply -f config/rbac/role_binding_patch.yaml 
```

From a terminal run this command:

```
$ kubectl apply -f config/samples/database.sample_v1alpha1_database.yaml
```

### Delete all resources

```
$ kubectl delete -f config/samples/database.sample_v1alpha1_database.yaml
$ make undeploy IMG="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"
```

### Build and push new image

Change 'REGISTRY', 'ORG' and image version in versions.env.

```
$ code ../versions.env
$ source ../versions.env
$ podman build -t "$REGISTRY/$ORG/$IMAGE_DATABASE" .
$ podman push "$REGISTRY/$ORG/$IMAGE_DATABASE"
```
