# operator-sample-go

This project contains Kubernetes operator samples that demonstrate best practices how to develop operators with [Golang](https://go.dev/), [Operator SDK](https://sdk.operatorframework.io/) including [Kubebuilder](https://github.com/kubernetes-sigs/kubebuilder) and the [Operator (OLM) Framework](https://operatorframework.io/).

### Setup

There are various ways to run and deploy the samples. Check out the [setup instructions](operator-application/README.md).

There is a custom application controller, a database controller simulating an external resource and a sample microservice. The easiest way to get started is to run the application controller locally and to use pre-built images for the dependencies. 

### Documentation

* [Creating and updating Resources from Operators](http://heidloff.net/article/updating-resources-kubernetes-operators/)
* [Deleting Resources in Operators](http://heidloff.net/article/deleting-resources-kubernetes-operators/)
* [Storing State of Resources with Conditions](http://heidloff.net/article/storing-state-status-kubernetes-resources-conditions-operators-go/)
* [Accessing third Party Custom Resources in Go Operators](http://heidloff.net/article/accessing-third-party-custom-resources-go-operators/)
* [Finding out the Kubernetes Versions and Capabilities in Operators](http://heidloff.net/article/finding-kubernetes-version-capabilities-operators/)
* [Importing Go Modules in Operators](http://heidloff.net/article/importing-go-modules-kubernetes-operators/)
* [Using object-oriented Concepts in Golang based Operators](http://heidloff.net/article/object-oriented-concepts-golang/)
* [Manually deploying Operators to Kubernetes](http://heidloff.net/article/manually-deploying-operators-to-kubernetes/)
* [Deploying Operators with the Operator Lifecycle Manager](http://heidloff.net/article/deploying-operators-operator-lifecycle-manager-olm/)
* [Defining Dependencies in Kubernetes Operators](http://heidloff.net/article/defining-dependencies-kubernetes-operators/)

### Capabilities to be added

* Versioning
* Webhooks
* Metrics
* Events
* Phase 3 - 5
* Testing
* Leader strategy
* Customizable templates
* Stateful resources

### Resources

* [Operator SDK Documentation](https://sdk.operatorframework.io/docs/overview/)
* [Kubebuilder Book](https://book.kubebuilder.io/)
* [Operator Framework (OLM) Documentation](https://olm.operatorframework.io/docs/)
* [Intro to the Operator Lifecycle Manager](https://www.youtube.com/watch?v=5PorcMTYZTo)
* [Go Modules](https://www.youtube.com/watch?v=Z1VhG7cf83M)
* [Resources to build Kubernetes Operators](http://heidloff.net/articles/resources-to-build-kubernetes-operators/)
* [Kubernetes API Conventions](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md)
* [Quarkus sample](https://github.com/nheidloff/quarkus-operator-microservice-database)