# Database Operator - Operator deployed with OLM

🔴 IMPORTANT: First install the [prerequistes](Prerequisites.md)! If you don't do it, it won't work :)

🔴 IMPORTANT: Webhooks and Prometheus doesn't work in this configuration yet.

### Deploy catalog source and subscription

```
$ cd operator-database
```

For Kubernetes:

```
$ kubectl apply -f olm/catalogsource.yaml
$ kubectl apply -f olm/subscription.yaml 
```

For OpenShift:

```
$ kubectl apply -f olm/catalogsource-openshift.yaml
$ kubectl apply -f olm/subscription-openshift.yaml 
```

### Verify the setup

For Kubernetes:

```
$ export NAMESPACE=operators
```

For OpenShift:

```
$ export NAMESPACE=openshift-operators
```

```
$ kubectl get all -n $NAMESPACE
$ kubectl get catalogsource operator-database-catalog -n $NAMESPACE -oyaml
$ kubectl get subscriptions operator-database-v0-0-1-sub -n $NAMESPACE -oyaml
$ kubectl get csv operator-database.v0.0.1 -n $NAMESPACE -oyaml
$ kubectl get installplans -n $NAMESPACE
$ kubectl get installplans install-xxxxx -n $NAMESPACE -oyaml
$ kubectl get operators operator-database.$NAMESPACE -n $NAMESPACE -oyaml
$ kubectl create ns database   
$ kubectl apply -f config/samples/database.sample_v1alpha1_database.yaml
$ kubectl get databases/database -n database -oyaml
$ kubectl get databases.database.sample.third.party/database -n database -oyaml
```

### Delete all resources

```
$ kubectl delete -f config/samples/database.sample_v1alpha1_database.yaml
$ kubectl delete -f olm/subscription.yaml
$ kubectl delete -f olm/catalogsource.yaml
$ kubectl delete -f olm/subscription-openshift.yaml
$ kubectl delete -f olm/catalogsource-openshift.yaml
```

### Build and push new operator image

Change 'REGISTRY', 'ORG' and image version in versions.env.

```
$ code ../versions.env
$ source ../versions.env
$ podman build -t "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR" .
$ podman push "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"
```

### Build and push new bundle image

Change 'REGISTRY', 'ORG' and image version in versions.env.

```
$ source ../versions.env
$ make bundle IMG="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"
$ podman build -f bundle.Dockerfile -t "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE" .
$ podman push "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE"
```

### Build and push new catalog image

Change 'REGISTRY', 'ORG' and image version in versions.env.

```
$ ./bin/opm index add --build-tool podman --mode semver --tag "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_CATALOG" --bundles "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE"
$ podman push "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_CATALOG"
```

Define "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_CATALOG" in olm/catalogsource.yaml and/or olm/catalogsource-openshift.yaml and invoke the commands above to apply catalog source and subscription.

### Alternative

The Operator SDK provides a way to deploy the operator without a catalog.

```
$ operator-sdk run bundle "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE" -n operators
or for OpenShift:
$ operator-sdk run bundle "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE" -n openshift-operators
```