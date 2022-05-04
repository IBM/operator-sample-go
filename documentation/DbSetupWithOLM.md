# Database Operator - Operator deployed with OLM

🔴 IMPORTANT: First install the [prerequistes](Prerequisites.md)! If you don't do it, it won't work :)

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
$ kubectl get catalogsource operator-application-catalog -n $NAMESPACE -oyaml
$ kubectl get subscriptions operator-application-v0-0-1-sub -n $NAMESPACE -oyaml
$ kubectl get csv operator-application.v0.0.1 -n $NAMESPACE -oyaml
$ kubectl get installplans -n $NAMESPACE
$ kubectl get installplans install-xxxxx -n $NAMESPACE -oyaml
$ kubectl get $NAMESPACE operator-application.$NAMESPACE -n $NAMESPACE -oyaml
$ kubectl apply -f config/samples/application.sample_v1beta1_application.yaml
$ kubectl get applications.application.sample.ibm.com/application -n application-beta -oyaml
$ kubectl exec -n application-beta $(kubectl get pods -n application-beta | awk '/application-deployment-microservice/ {print $1;exit}') --container application-microservice -- curl http://localhost:8081/hello
$ kubectl logs -n $NAMESPACE $(kubectl get pods -n $NAMESPACE | awk '/operator-application-controller-manager/ {print $1;exit}') -c manager
```

### Delete all resources

```
$ kubectl delete -f config/samples/application.sample_v1beta1_application.yaml
$ kubectl delete -f olm/subscription.yaml
$ kubectl delete -f olm/catalogsource.yaml
$ kubectl delete -f olm/subscription-openshift.yaml
$ kubectl delete -f olm/catalogsource-openshift.yaml
$ operator-sdk olm uninstall
```

### Build and push new bundle image

Change 'REGISTRY', 'ORG' and image version in versions.env.

```
$ source ../versions.env
$ make bundle IMG="$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR"
$ podman build -f bundle.Dockerfile -t "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_BUNDLE" .
$ podman push "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_BUNDLE"
```

### Build and push new catalog image

Change 'REGISTRY', 'ORG' and image version in versions.env.

```
$ ./bin/opm index add --build-tool podman --mode semver --tag "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_CATALOG" --bundles "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_BUNDLE"
$ podman push "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_CATALOG"
```

Define "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_CATALOG" in olm/catalogsource.yaml and/or olm/catalogsource-openshift.yaml and invoke the commands above to apply catalog source and subscription.

### Alternative

The Operator SDK provides a way to deploy the operator without a catalog.

```
$ operator-sdk run bundle "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_BUNDLE" -n operators
or for OpenShift:
$ operator-sdk run bundle "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_BUNDLE" -n openshift-operators
```