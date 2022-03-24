# Setup and Deployment via Operator Lifecycle Manager

Follow the same steps described in [Setup and manual Deployment](SetupManualDeployment.md) up to the step 'Deploy Operator'.

Install the Operator Lifecycle Manager (OLM):

```
$ operator-sdk olm install latest 
$ kubectl get all -n olm
```

Build and push the Bundle Image:

```
$ make generate manifests
$ make bundle IMG="$REGISTRY/$ORG/$IMAGE"
$ make bundle-build docker-push BUNDLE_IMG="$REGISTRY/$ORG/$BUNDLE_IMAGE" IMG="$REGISTRY/$ORG/$BUNDLE_IMAGE"
```

**Deploy the operator**

There are two ways to deploy the operator:

1) operator-sdk
2) kubectl

*1. Deploy via operator-sdk:*

```
$ operator-sdk run bundle "$REGISTRY/$ORG/$BUNDLE_IMAGE" -n operators
```

*2. Deploy via kubectl:*

```
$ kubectl apply -f olm/catalogsource.yaml
$ kubectl apply -f olm/subscription.yaml 
$ kubectl get installplans -n operators
$ kubectl -n operators patch installplan install-xxxxx -p '{"spec":{"approved":true}}' --type merge
```

**Verify the setup**

In both cases the setup can be verified via these commands:

```
$ kubectl get all -n operators
$ kubectl get catalogsource operator-application-catalog -n operators -oyaml
$ kubectl get subscriptions operator-application-v0-0-1-sub -n operators -oyaml
$ kubectl get csv operator-application.v0.0.1 -n operators -oyaml
$ kubectl get installplans -n operators
$ kubectl get installplans install-xxxxx -n operators -oyaml
$ kubectl get operators operator-application.operators -n operators -oyaml
```

In both cases an application resource can be created via this command: 

```
$ kubectl apply -f config/samples/application.sample_v1beta1_application.yaml
$ kubectl get applications.application.sample.ibm.com/application -n application-beta -oyaml
$ kubectl exec -n application-beta $(kubectl get pods -n application-beta | awk '/application-deployment-microservice/ {print $1;exit}') --container application-microservice -- curl http://localhost:8081/hello
$ kubectl logs -n operators $(kubectl get pods -n operators | awk '/operator-application-controller-manager/ {print $1;exit}') -c manager
```

**Delete all resources**

*1. Delete all resources (operator-sdk):*

```
$ kubectl delete -f config/samples/application.sample_v1beta1_application.yaml
$ operator-sdk cleanup operator-application -n operators --delete-all
$ kubectl apply -f ../operator-database/config/crd/bases/database.sample.third.party_databases.yaml
$ operator-sdk olm uninstall
```

*2. Delete all resources (kubectl):*

```
$ kubectl delete -f config/samples/application.sample_v1beta1_application.yaml
$ kubectl delete -f olm/catalogsource.yaml
$ kubectl delete -f olm/subscription.yaml
$ operator-sdk olm uninstall
```