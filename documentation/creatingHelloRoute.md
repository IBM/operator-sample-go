# Creating Route in Openshift 
This guide refers to creating a simple route in Openshift that expose ''application-service-microservice'' in application-beta namespace to a public endpoint.

## Steps
- Login to Openshift Operator Hub
- Go to the Networking section in left navigation 
- Select Routes
- Click on Create Route button
- Add Following details
   + Name of the route "Hello"
   + Hostname "The Ingress Domain or Subdomain of Openshift Cluster in FQDN Format"
   + add the path "/hello"
   + Select Service "application-service-microservice"
   + Select Target Port 8081 -> 8081 (TCP)
   + To Secure the "Public Endpoint Link" Check the Secure Route Box (Ignore if you don't have Certificate Files i.e. Certifcate, Certificate Authority, and Private Key)
      + Add Respective Certificate and Private Key Files by Coping the Contents into the Box Specified.
    + Click on Create

Done!!! its as simple as it seems. Now browse to the Location Link provided in the Routes List to browse Public Endpoint of Hello Api.

The Results should be similar to the following in browser:-

```
Hello World and hello Adam
```