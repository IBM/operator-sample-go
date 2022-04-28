# Kubernetes Operator Patterns and Best Practises

This project contains Kubernetes operator samples that demonstrate best practices how to develop operators with [Golang](https://go.dev/), [Operator SDK](https://sdk.operatorframework.io/) including [Kubebuilder](https://github.com/kubernetes-sigs/kubebuilder) and the [Operator Lifecycle Manager Framework](https://operatorframework.io/).

### Getting started

The repo contains two operators:
1) Application operator: Deploys and manages a simple microservice application.
2) Database operator: Deploys and manages a simple database. Used by the application.

Additionally the repo contains four more components:
1) [Simple micorservice](simple-microservice/README.md) managed by the application operator
2) [Database service](database-service/README.md) managed by the database operator
3) [Database controller extension](operator-database-backup/README.md) to automatically backups of data
4) [Application controller extension](operator-application-scaler/README.md) to automatically scale up the microservice

The easiest way to get started is to [run the application operator locally](documentation/AppSetupLocal.md) which uses prebuilt images of the database controller, the microservice and all other required components.

Run the application operator:

1) [Local operator](documentation/AppSetupLocal.md) 
2) [Operator deployed without OLM](documentation/AppSetupWithoutOLM.md)
3) [Operator deployed with OLM](documentation/AppSetupWithOLM.md)

Run the database operator:

1) [Local operator](documentation/DbSetupLocal.md) 
2) [Operator deployed without OLM](documentation/DbSetupWithoutOLM.md)
3) [Operator deployed with OLM](documentation/DbSetupWithOLM.md)

### Documentation

*Overview and Scenarios*

* [Why you should build Kubernetes Operators](http://heidloff.net/article/why-you-should-build-kubernetes-operators/)
* [Day 2 Scenario: Automatically Archiving Data](http://heidloff.net/article/automatically-archiving-data-kubernetes-operators/)
* [Day 2 Scenario: Automatically Scaling Applications](http://heidloff.net/article/scaling-applications-automatically-operators/)
* [The Kubernetes Operator Metamodel](http://heidloff.net/article/the-kubernetes-operator-metamodel/)

*Basic Capabilities*

* [Creating and updating Resources](http://heidloff.net/article/updating-resources-kubernetes-operators/)
* [Deleting Resources](http://heidloff.net/article/deleting-resources-kubernetes-operators/)
* [Storing State of Resources with Conditions](http://heidloff.net/article/storing-state-status-kubernetes-resources-conditions-operators-go/)
* [Finding out the Kubernetes Versions and Capabilities](http://heidloff.net/article/finding-kubernetes-version-capabilities-operators/)
* [Configuring Webhooks](http://heidloff.net/article/configuring-webhooks-kubernetes-operators/)
* [Initialization and Validation Webhooks](http://heidloff.net/article/developing-initialization-validation-webhooks-kubernetes-operators/)
* [Converting Custom Resource Versions](http://heidloff.net/article/converting-custom-resource-versions-kubernetes-operators/)
* [Defining Dependencies](http://heidloff.net/article/defining-dependencies-kubernetes-operators/)

*Advanced Capabilities*

* [Exporting Metrics from Kubernetes Apps for Prometheus](http://heidloff.net/article/exporting-metrics-kubernetes-applications-prometheus/)
* [Accessing Kubernetes from Go Applications](http://heidloff.net/article/accessing-kubernetes-from-go-applications/)
* [How to build your own Database on Kubernetes](http://heidloff.net/article/how-to-build-your-own-database-on-kubernetes/)
* [Building Databases on Kubernetes with Quarkus](http://heidloff.net/quarkus/building-databases-kubernetes-quarkus/)

*Development and Deployment*

* [Manually deploying Operators to Kubernetes](http://heidloff.net/article/manually-deploying-operators-to-kubernetes/)
* [Deploying Operators with the Operator Lifecycle Manager](http://heidloff.net/article/deploying-operators-operator-lifecycle-manager-olm/)

*Golang*

* [Importing Go Modules in Operators](http://heidloff.net/article/importing-go-modules-kubernetes-operators/)
* [Accessing third Party Custom Resources in Go Operators](http://heidloff.net/article/accessing-third-party-custom-resources-go-operators/)
* [Using object-oriented Concepts in Golang based Operators](http://heidloff.net/article/object-oriented-concepts-golang/)

To start developing operators, we recommend to get familiar with the [Kubernetes Operator Metamodel](http://heidloff.net/article/the-kubernetes-operator-metamodel/) first.

<img src="documentation/OperatorMetamodel.png" />

### Resources

* [Operator SDK Documentation](https://sdk.operatorframework.io/docs/overview/)
* [Kubebuilder Book](https://book.kubebuilder.io/)
* [Operator Framework (OLM) Documentation](https://olm.operatorframework.io/docs/)
* [Kubernetes API Conventions](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md)
