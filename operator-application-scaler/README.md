# Application Operator Scaler

To run the Go backup application locally, run these commands:

```
$ git clone https://github.com/ibm/operator-sample-go.git
$ cd operator-application-scaler
$ go run main.go
```

To deploy the scaler application as Kubernetes job, build and push the image and change the reference in kubernetes/cronjob.yaml:

```
$ cd operator-application-scaler
$ code ../versions.env
$ source ../versions.env
$ podman build -f Dockerfile -t "$REGISTRY/$ORG/$IMAGE_APPLICATION_SCALER" .
$ podman push "$REGISTRY/$ORG/$IMAGE_APPLICATION_SCALER"
```

Run backup application manually via CronJob:

Change the image version in cronjob.yaml and run the application operator in the operator-application-system namespace. To trigger the auto scalability feature, invoke the /hello endpoint more than five times.

```
$ kubectl apply -f ../operator-application/config/samples/application.sample_v1beta1_application.yaml
$ kubectl apply -f kubernetes/role.yaml
$ kubectl apply -f kubernetes/cronjob.yaml
$ kubectl create job --from=cronjob/application-scaler manuallytriggered -n operator-application-system
$ kubectl logs -n operator-application-system $(kubectl get pods -n operator-application-system | awk '/manuallytriggered/ {print $1;exit}')
$ kubectl exec -n application-beta $(kubectl get pods -n application-beta | awk '/application-deployment-microservice/ {print $1;exit}') --container application-microservice -- curl http://localhost:8081/hello
```
