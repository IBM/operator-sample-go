```
sh scripts/install-required-kubernetes-components.sh
kubectl create ns database 
kubectl apply -f operator-database/olm/catalogsource.yaml
kubectl apply -f operator-database/olm/subscription.yaml 
kubectl apply -f operator-application/olm/catalogsource.yaml
kubectl apply -f operator-application/olm/subscription.yaml 
kubectl apply -f operator-application/config/samples/application.sample_v1beta1_application.yaml
kubectl get applications.application.sample.ibm.com/application -n application-beta -oyaml
kubectl exec -n application-beta $(kubectl get pods -n application-beta | awk '/application-deployment-microservice/ {print $1;exit}') --container application-microservice -- curl http://localhost:8081/hello
```

Expected output:

```
status:
  conditions:
  - lastTransitionTime: "2022-05-05T08:00:57Z"
    message: Resource found in k18n
    reason: ResourceFound
    status: "True"
    type: ResourceFound
  - lastTransitionTime: "2022-05-05T08:00:58Z"
    message: All requirements met, attempting install
    reason: AllRequirementsMet
    status: "True"
    type: InstallReady
  - lastTransitionTime: "2022-05-05T08:00:58Z"
    message: The database exists
    reason: DatabaseExists
    status: "True"
    type: DatabaseExists
  - lastTransitionTime: "2022-05-05T08:00:58Z"
    message: Application has been installed
    reason: InstallSucceeded
    status: "True"
    type: Succeeded
  schemaCreated: false
niklasheidloff@Niklass-MacBook-Pro operator-sample-go % kubectl exec -n application-beta $(kubectl get pods -n application-beta | awk '/application-deployment-microservice/ {print $1;exit}') --container application-microservice -- curl http://localhost:8081/hello
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    11  100    11    0     0     64      0 --:--:-- --:--:-- --:--:--    64Hello World
```

To be done: Build images