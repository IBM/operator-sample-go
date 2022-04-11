# Setup and manual Deployment

Install [prerequistes](Prerequisites.md).

### Install cert-manager

[cert-manager](https://github.com/cert-manager/cert-manager) is needed for webhooks.

```
$ kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.2/cert-manager.yaml
```

### Deploy database operator

Before running the application operator, the database operator needs to be deployed since it is defined as dependency. Follow the [instructions](../operator-database/README.md#run-operator-on-kubernetes) in the documentation.

### Build and push the application operator image

```
$ code ../versions.env
$ source ../versions.env
$ podman build -t "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR" .
$ podman push "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR"
```

### Deploy the operator

```
$ source ../versions.env
$ make deploy IMG="$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR"
```

### Create an application resource

```
$ kubectl apply -f config/samples/application.sample_v1beta1_application.yaml
```

### Verify the setup

```
$ kubectl get all -n operator-application-system
$ kubectl get applications.application.sample.ibm.com/application -n application-beta -oyaml
$ kubectl exec -n application-beta $(kubectl get pods -n application-beta | awk '/application-deployment-microservice/ {print $1;exit}') --container application-microservice -- curl http://localhost:8081/hello
$ kubectl logs -n operator-application-system $(kubectl get pods -n operator-application-system | awk '/operator-application-controller-manager/ {print $1;exit}') -c manager
```

### Delete all resources

```
$ kubectl delete -f config/samples/application.sample_v1beta1_application.yaml
$ make undeploy IMG="$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR"
```

### Optionally: Test the conversions between v1alpha1 and v1beta1

v1alpha1:

```
$ kubectl apply -f config/samples/application.sample_v1alpha1_application.yaml
$ kubectl delete -f config/samples/application.sample_v1alpha1_application.yaml
$ kubectl exec -n application-alpha $(kubectl get pods -n application-alpha | awk '/application-deployment-microservice/ {print $1;exit}') --container application-microservice -- curl http://localhost:8081/hello
$ kubectl get applications.v1alpha1.application.sample.ibm.com/application -n application-alpha -oyaml | grep -A6 -e "spec:" -e "apiVersion: application.sample.ibm.com/" 
$ kubectl get applications.v1beta1.application.sample.ibm.com/application -n application-alpha -oyaml | grep -A6 -e "spec:" -e "apiVersion: application.sample.ibm.com/" 
```

v1beta1:

```
$ kubectl apply -f config/samples/application.sample_v1beta1_application.yaml
$ kubectl delete -f config/samples/application.sample_v1beta1_application.yaml
$ kubectl exec -n application-beta $(kubectl get pods -n application-beta | awk '/application-deployment-microservice/ {print $1;exit}') --container application-microservice -- curl http://localhost:8081/hello
$ kubectl get applications.v1alpha1.application.sample.ibm.com/application -n application-beta -oyaml | grep -A6 -e "spec:" -e "apiVersion: application.sample.ibm.com/" 
$ kubectl get applications.v1beta1.application.sample.ibm.com/application -n application-beta -oyaml | grep -A6 -e "spec:" -e "apiVersion: application.sample.ibm.com/" 
```

### Optionally: Metrics

Install Prometheus:

```
$ operator-sdk olm install latest 
$ kubectl apply -f https://operatorhub.io/install/prometheus.yaml
$ kubectl apply -f ../prometheus/
$ kubectl port-forward service/prometheus-operated -n monitoring 9090
```

Add operator-application to Prometheus:

```
$ make deploy IMG="$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR"
$ kubectl apply -f prometheus/
```

Open Prometheus daschboard:

```
$ open http://localhost:9090
```