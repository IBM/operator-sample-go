# Setup and Deployment via Operator Lifecycle Manager

Follow the same steps as above in the section [Setup and manual Deployment](SetupManualDeployment.md) up to the step 'Deploy Operator'.

Install the Operator Lifecycle Manager (OLM):

```
$ operator-sdk olm install latest 
$ kubectl get all -n olm
```

Build and push the Bundle Image:

```
$ make bundle-build docker-push BUNDLE_IMG="$REGISTRY/$ORG/$BUNDLE_IMAGE" IMG="$REGISTRY/$ORG/$BUNDLE_IMAGE"
```

**Deploy the Operator**

There are two ways to deploy the operator:

1) operator-sdk (all necessary resources are created)
2) kubectl (resources defined in yaml)

*operator-sdk:*

```
$ operator-sdk run bundle "$REGISTRY/$ORG/$BUNDLE_IMAGE" -n operators
```

*kubectl:*

```
$ kubectl apply -f olm/catalogsource.yaml
$ kubectl apply -f olm/subscription.yaml 
$ kubectl get installplans -n operators
$ kubectl -n operators patch installplan install-xxxxx -p '{"spec":{"approved":true}}' --type merge
```

To test the operator, follow the instructions at the bottom of the section [Setup and manual Deployment](SetupManualDeployment.md).

Verify Installation:

```
$ kubectl get all -n operators
$ kubectl get catalogsource operator-application-catalog -n operators -oyaml
$ kubectl get subscriptions operator-application-v0-0-1-sub -n operators -oyaml
$ kubectl get csv operator-application.v0.0.1 -n operators -oyaml
$ kubectl get installplans -n operators
$ kubectl get installplans install-xxxxx -n operators -oyaml
$ kubectl get operators operator-application.operators -n operators -oyaml
```

Delete Resources (operator-sdk):

```
$ kubectl delete -f config/samples/application.sample_v1alpha1_application.yaml
$ operator-sdk cleanup operator-application -n operators --delete-all
$ kubectl apply -f ../operator-database/config/crd/bases/database.sample.third.party_databases.yaml
$ operator-sdk olm uninstall
```

Delete Resources (kubectl):

```
$ kubectl delete -f config/samples/application.sample_v1alpha1_application.yaml
$ kubectl delete -f olm/catalogsource.yaml
$ kubectl delete -f olm/subscription.yaml
$ operator-sdk olm uninstall
```