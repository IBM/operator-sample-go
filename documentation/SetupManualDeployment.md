# Setup and manual Deployment

First install [prerequistes](Prerequisites.md)!

### Deploy database operator

Before running the application operator, the database operator needs to be deployed since it is defined as dependency. Follow the [instructions](../operator-database/README.md#run-operator-on-kubernetes) in the documentation.

### Navigate to operator-application

```
$ cd operator-application
```

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

### Test the conversions between v1alpha1 and v1beta1

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

### Prometheus Metrics

For OpenShift only:

```
$ oc label namespace application-beta openshift.io/cluster-monitoring="true"
$ kubectl apply -f prometheus
TODO: same for operator-application
```

Open Prometheus daschboard:

```
$ kubectl port-forward service/prometheus-operated -n monitoring 9090
or for OpenShift:
$ kubectl port-forward service/prometheus-operated -n openshift-monitoring 9090
```

```
$ open http://localhost:9090/graph
```

Search for 'reconcile_launched_total' and 'application_net_heidloff_GreetingResource_countHelloEndpointInvoked_total'.
