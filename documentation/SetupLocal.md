# Setup and local Usage

Install [prerequistes](Prerequisites.md).

Navigate to operator-application:

```
$ cd operator-application
```

Create database resource:

```
$ kubectl create namespace database
$ kubectl apply -f ../operator-database/config/crd/bases/database.sample.third.party_databases.yaml
```

From a terminal run this command:

```
$ make install run ENABLE_WEBHOOKS=false
```

From another terminal run this command:

```
$ kubectl apply -f config/samples/application.sample_v1beta1_application.yaml
```

Debug the operator (without webhooks):

To debug, press F5 (Run - Start Debugging) instead of 'make install run'. The directory 'operator-application' needs to be root in VSCode.

Verify the setup:

```
$ kubectl get applications.application.sample.ibm.com/application -n application-beta -oyaml
$ kubectl exec -n application-beta $(kubectl get pods -n application-beta | awk '/application-deployment-microservice/ {print $1;exit}') --container application-microservice -- curl -s http://localhost:8081/hello
```

Delete all resources:

```
$ kubectl delete -f config/samples/application.sample_v1beta1_application.yaml
$ make uninstall
```
