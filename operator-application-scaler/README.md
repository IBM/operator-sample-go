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

```
$ kubectl apply -f kubernetes/role.yaml
$ kubectl apply -f kubernetes/cronjob.yaml
$ kubectl create job --from=cronjob/application-scaler manuallytriggered -n operator-application-system
$ kubectl logs -n operator-application-system $(kubectl get pods -n operator-application-system | awk '/manuallytriggered/ {print $1;exit}')
```
