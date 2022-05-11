# Application Operator Scaler

To run the Go backup application locally, run these commands:

```
$ git clone https://github.com/ibm/operator-sample-go.git
$ cd operator-application-scaler
$ go run main.go
```

To deploy the scaler application as Kubernetes job, build and push the image.  The application scaler pod will run in the application-beta namespace.

```
$ cd operator-application-scaler
$ code ../versions_local.env
$ source ../versions_local.env
$ podman build -f Dockerfile -t "$REGISTRY/$ORG/$IMAGE_APPLICATION_SCALER" .
$ podman push "$REGISTRY/$ORG/$IMAGE_APPLICATION_SCALER"
```

Change the image reference in kubernetes/cronjob.yaml, then create the cronjob resource:

```
$ kubectl apply -f cronjob.yaml
```

Additional RBAC permissions are required (if not already set):

```
$ kubectl apply -f ../operator-application/prometheus/prometheus/role-all.yaml
OpenShift only:
$ kubectl apply -f ../operator-application/prometheus/prometheus/role-openshift.yaml
```

Create Appliction CR:
```
$ kubectl apply -f ../operator-application/config/samples/application.sample_v1beta1_application.yaml
```

Run backup application manually via CronJob:
```
$ kubectl create job --from=cronjob/application-scaler manuallytriggered -n operator-beta
$ kubectl logs -n operator-application-system $(kubectl get pods -n operator-beta | awk '/manuallytriggered/ {print $1;exit}')
```

Request the /hello endpoint more than five times to trigger a scale up:
```
$ kubectl exec -n application-beta $(kubectl get pods -n application-beta | awk '/application-deployment-microservice/ {print $1;exit}') --container application-microservice -- curl http://localhost:8081/hello
```
