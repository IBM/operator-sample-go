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
$ kubectl apply -f config/samples/database.sample_v1alpha1_databasecluster.yaml
$ kubectl get databases/database -n database -oyaml
$ kubectl get databases.database.sample.third.party/database -n database -oyaml
```

### Delete all resources

```
$ kubectl delete -f config/samples/database.sample_v1alpha1_databasecluster.yaml
$ kubectl delete -f config/samples/database.sample_v1alpha1_database.yaml
$ kubectl delete -f olm/subscription.yaml
$ kubectl delete -f olm/catalogsource.yaml
$ kubectl delete -f olm/subscription-openshift.yaml
$ kubectl delete -f olm/catalogsource-openshift.yaml
```

### Build and push new operator image

Create versions_local.env and change 'REGISTRY', 'ORG' and image version.

```
$ source ../versions_local.env
$ podman build -t "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR" .
$ podman push "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"
```

### Build and push new bundle image

Create versions_local.env and change 'REGISTRY', 'ORG' and image version.

```
$ source ../versions_local.env
$ make bundle IMG="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"
$ podman build -f bundle.Dockerfile -t "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE" .
$ podman push "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE"
```

### Build and push new catalog image

 ### Setup of the needed executable bin files
 
   Setup of the needed bin files (controller-gen, kustomize, opm, setup-envtest) for the operator-sdk projects. The script will create a temp operator sdk project, to create a the bin file and delete that temp project when it was finished.
   
   ```
   sh scripts/check-binfiles-for-operator-sdk-projects.sh
   ```
 
 Note: You need to interact with the script, because when you create the first time a bundle. These are the temp values you can use for the script execution. These are the example values: 'Display name : myproblemfix', Description : myproblemfix, Provider's name: myproblemfix, Any relevant URL:, Comma-separated keywords : myproblemfix Comma-separated maintainers: myproblemfix@myproblemfix.net.
Create versions_local.env and change 'REGISTRY', 'ORG' and image version.

Example output:
```
***  Bin folder status: operator-database
controller-gen  kustomize       opm             setup-envtest
***  Bin folder status: operator-database
controller-gen  kustomize       opm             setup-envtest
```

```
$ source ../versions_local.env
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
