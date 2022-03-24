# Setup and manual Deployment

Install [prerequistes](Prerequisites.md).

Install cert-manager:

[cert-manager](https://github.com/cert-manager/cert-manager) is needed for webhooks.

```
$ kubectl apply -f https://github.com/jetstack/cert-manager/releases/latest/download/cert-manager.yaml
```

Deploy database operator:

Before running the application operator, the database operator needs to be deployed since it is defined as dependency.

```
$ cd ../operator-database
$ make deploy IMG="docker.io/nheidloff/database-operator:v1.0.2"
$ cd ../operator-application
```

Build and push the application operator image:

```
$ make generate manifests
$ docker login $REGISTRY
$ make docker-build docker-push IMG="$REGISTRY/$ORG/$IMAGE"
```

Deploy the operator:

```
$ make deploy IMG="$REGISTRY/$ORG/$IMAGE"
```

Create an application resource: 

```
$ kubectl apply -f config/samples/application.sample_v1beta1_application.yaml
```

Verify the setup:

```
$ kubectl get all -n operator-application-system
$ kubectl get applications.application.sample.ibm.com/application -n application-beta -oyaml
$ kubectl exec -n application-beta $(kubectl get pods -n application-beta | awk '/application-deployment-microservice/ {print $1;exit}') --container application-microservice -- curl http://localhost:8081/hello
$ kubectl logs -n operator-application-system $(kubectl get pods -n operator-application-system | awk '/operator-application-controller-manager/ {print $1;exit}') -c manager
```

Delete all resources:

```
$ kubectl delete -f config/samples/application.sample_v1beta1_application.yaml
$ make undeploy IMG="$REGISTRY/$ORG/$IMAGE"
```