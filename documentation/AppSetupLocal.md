# Application Operator - Setup and local Usage

🔴 IMPORTANT: First install the [prerequistes](Prerequisites.md)! If you don't do it, it won't work :)

### Create database resource

```
$ cd operator-application
$ kubectl create namespace database
$ kubectl apply -f ../operator-database/config/crd/bases/database.sample.third.party_databases.yaml
```

### Run operator locally

From a terminal run this command:

```
$ cd operator-application
$ make install run ENABLE_WEBHOOKS=false
```

From another terminal run this command:

```
$ kubectl apply -f config/samples/application.sample_v1beta1_application.yaml
```

Debug the operator (without webhooks):

To debug, press F5 (Run - Start Debugging) instead of 'make install run'. The directory 'operator-application' needs to be root in VSCode.

### Verify the setup

```
$ kubectl get applications.application.sample.ibm.com/application -n application-beta -oyaml
$ kubectl exec -n application-beta $(kubectl get pods -n application-beta | awk '/application-deployment-microservice/ {print $1;exit}') --container application-microservice -- curl -s http://localhost:8081/hello
```

### Delete all resources

```
$ kubectl delete -f config/samples/application.sample_v1beta1_application.yaml
$ make uninstall
```