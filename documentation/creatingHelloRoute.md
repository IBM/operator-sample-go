# Creating Route in Openshift 
This guide refers to creating a simple route in Openshift that expose ''application-service-microservice'' in application-beta namespace to a public endpoint.  Before you can create and test the route, you must have deployed the Application and DatabaseCluster Custom Resources.

```
cd operator-database
oc apply -f config/samples/database.sample_v1alpha1_databasecluster.yaml
```
```
cd operator-application
oc apply -f config/samples/application.sample_v1beta1_application.yaml
```

## Steps
- Login to Openshift console
- Go to the Networking section in left navigation 
- Select Routes
- Click on Create Route button
- Add Following details
   + Name of the route "hello"
   + add the path "/hello"
   + Select Service "application-service-microservice"
   + Select Target Port 8081 -> 8081 (TCP)
   + Click on Create

Now browse to the Location Link provided in the Routes List to browse Public Endpoint of Hello Api.  It sometimes takes a couple of requests before the application responds.  The results should be similar to the following in browser:-

```
Hello World and hello Adam
```

The Route will continue to work even if the application is deleted and later re-created (by the Application operator)
