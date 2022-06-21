# Kubernetes Operator Patterns and Best Practises

This project contains Kubernetes operator samples that demonstrate best practices how to develop operators with [Golang](https://go.dev/), [Operator SDK](https://sdk.operatorframework.io/) including [Kubebuilder](https://github.com/kubernetes-sigs/kubebuilder) and the [Operator Lifecycle Manager Framework](https://operatorframework.io/).

### Brief Overview

The repo contains two operators:
1) Application operator: Deploys and manages a simple microservice application, providing a front-end UI.
2) Database operator: Deploys and manages a simple database. Used by the front-end application.

Additionally the repo contains four more components:
1) [Simple micorservice](simple-microservice/README.md) managed by the application operator
2) [Database service](database-service/README.md) managed by the database operator
3) [Database controller extension](operator-database-backup/README.md) to automatically backups of data
4) [Application controller extension](operator-application-scaler/README.md) to automatically scale up the microservice

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
