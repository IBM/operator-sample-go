# Kubernetes Operator Patterns and Best Practises

This project contains Kubernetes operator samples that demonstrate best practices how to develop operators with [Golang](https://go.dev/), [Operator SDK](https://sdk.operatorframework.io/) including [Kubebuilder](https://github.com/kubernetes-sigs/kubebuilder) and the [Operator Lifecycle Manager Framework](https://operatorframework.io/).

### Brief Overview

The repo contains two operators:
* [Application operator](https://github.com/IBM/operator-sample-go/tree/main/operator-application): Deploys and manages a front-end micro-service application which provides a simple web UI.
* [Database operator](https://github.com/IBM/operator-sample-go/tree/main/operator-database): Deploys and manages a simple database. Used by the front-end application.

Additionally the repo contains four more application components:

* [simple-microservice](https://github.com/IBM/operator-sample-go/tree/main/simple-microservice) - A front end web application, written in Java using Quarkus
* [database-service](https://github.com/IBM/operator-sample-go/tree/main/database-service) - A simple database application deployed by the database operator, written in Java using Quarkus
* [operator-database-backup](https://github.com/IBM/operator-sample-go/tree/main/operator-database-backup) - A Go application to query the database and upload the data to cloud object storage.  This container is launched on a schedule by the database operator
* [operator-application-scaler](https://github.com/IBM/operator-sample-go/tree/main/operator-application-scaler) - A Go application used to make autoscaling decisions for the front-end.  It queries Prometheus metrics exposed by the simple-microservice, and if necessary, modifies the custom resource which defines the size of the front-end deployment.  This container is launched on a schedule by the application operator

Scripts are provided to automate build and deployment:

* [scripts](https://github.com/IBM/operator-sample-go/tree/main/scripts) - Automation to verify workstation prerequisites, build all container images and deploy to a Kubernetes or OpenShift cluster.  Alternatively, the scripts can deploy pre-built 'golden' container images.

Check out this 1-minute demo video of the operators<br>
[![Operator Sample Go Demo 1 min](https://img.youtube.com/vi/iblGZ8mmbGo/0.jpg)](https://www.youtube.com/watch?v=iblGZ8mmbGo "Click play on YouTube")


### Documentation

Extended documentation can be found in this repo:
https://ibm.github.io/operator-sample-go-documentation/


### IBM Build Labs

This project has been created by IBM Build Labs.  We provide a service to selected IBM Business Partners (ISVs) looking to automate the operations of their solutions to meet the demands of clients, and open new routes to market using Red Hat OpenShift on any cloud/platform.

Introduction to IBM Build Labs<br>
[![Unleash the Power of your Applications](https://img.youtube.com/vi/WDBn-kgkct4/0.jpg)](https://www.youtube.com/watch?v=WDBn-kgkct4 "Click play on youtube")

Our 40-minute masterclass video provides a useful inroduction to operators and why to use them<br>
[![Operators Masterclass](https://img.youtube.com/vi/D6njEyXPieg/0.jpg)](https://www.youtube.com/watch?v=D6njEyXPieg "Click play on youtube")

### Additional Resources

* [Operator Sample Go Project Documentation](https://ibm.github.io/operator-sample-go-documentation/)
* [Operator SDK Documentation](https://sdk.operatorframework.io/docs/overview/)
* [Kubebuilder Book](https://book.kubebuilder.io/)
* [Operator Framework (OLM) Documentation](https://olm.operatorframework.io/docs/)
* [Kubernetes API Conventions](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md)

### Credits

  * [Niklas Heidloff](https://twitter.com/nheidloff)
  * [Alain Airom](https://twitter.com/AAairom)
  * [Adam de Leeuw](https://www.linkedin.com/in/deleeuwa/) 
  * [Diwakar Tiwari](https://twitter.com/diwakarptiwari)
  * [Thomas Südbröcker](https://twitter.com/tsuedbroecker)
  * [Vishal Ramani](https://www.linkedin.com/in/vishalramani/)