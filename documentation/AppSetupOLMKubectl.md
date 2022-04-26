# Application Operator - Setup and Deployment via Operator Lifecycle Manager and kubectl

First install the [prerequistes](Prerequisites.md)!

### Navigate to operator-application

```
$ cd operator-application
```

### Deploy catalog source and subscription

```
$ kubectl apply -f olm/catalogsource.yaml
$ kubectl apply -f olm/subscription.yaml 
$ kubectl get installplans -n operators
```

If the install plan requires manual approval, use this command:

```
$ kubectl -n operators patch installplan install-xxxxx -p '{"spec":{"approved":true}}' --type merge
```

### Verify the setup

```
$ kubectl get all -n operators
$ kubectl get catalogsource operator-application-catalog -n operators -oyaml
$ kubectl get subscriptions operator-application-v0-0-1-sub -n operators -oyaml
$ kubectl get csv operator-application.v0.0.1 -n operators -oyaml
$ kubectl get installplans -n operators
$ kubectl get installplans install-xxxxx -n operators -oyaml
$ kubectl get operators operator-application.operators -n operators -oyaml
$ kubectl apply -f config/samples/application.sample_v1beta1_application.yaml
$ kubectl get applications.application.sample.ibm.com/application -n application-beta -oyaml
$ kubectl exec -n application-beta $(kubectl get pods -n application-beta | awk '/application-deployment-microservice/ {print $1;exit}') --container application-microservice -- curl http://localhost:8081/hello
$ kubectl logs -n operators $(kubectl get pods -n operators | awk '/operator-application-controller-manager/ {print $1;exit}') -c manager
```

### Delete all resources

```
$ kubectl delete -f config/samples/application.sample_v1beta1_application.yaml
$ kubectl delete -f olm/subscription.yaml
$ kubectl delete -f olm/catalogsource.yaml
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

Define "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_CATALOG" in olm/catalogsource.yaml and invoke these commands.

```
$ kubectl apply -f olm/catalogsource.yaml
$ kubectl apply -f olm/subscription.yaml 
$ kubectl get installplans -n operators
```
