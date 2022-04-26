# Application Operator - Setup and Deployment via Operator Lifecycle Manager and SDK

First install the [prerequistes](Prerequisites.md)!

### Run the bundle

```
$ cd operator-application
$ operator-sdk run bundle "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_BUNDLE" -n operators
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
$ operator-sdk cleanup operator-application -n operators --delete-all
$ kubectl apply -f ../operator-database/config/crd/bases/database.sample.third.party_databases.yaml
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