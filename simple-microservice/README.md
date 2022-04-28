# Simple Microservice

The microservice provides a `hello world` endpoint which prints out an input environment variable. The service has been built with [Quarkus](https://quay.io/).

Endpoints:

* `http://localhost:8081/hello` which prints out an input environment variable.
* `http://localhost:8081/q/metrics/application` provides metrics information.


The documentation covers three topics:

* Run the microservice locally
* Run the microservice as a container
* Build and push a new container image for the microservice to a container registry

### Run locally

```
$ cd simple-microservice
$ export GREETING_MESSAGE=World
$ mvn clean quarkus:dev
$ open http://localhost:8081/hello
$ open http://localhost:8081/q/metrics/application
```

### Run as Container

```
$ cd simple-microservice
$ podman build -t simple-microservice .
$ podman run -i --rm -p 8081:8081 -e GREETING_MESSAGE=World simple-microservice 
$ open http://localhost:8081/hello
```

### Build new Image

```
$ cd simple-microservice
$ code ../versions.env
$ source ../versions.env
$ podman build -t "$REGISTRY/$ORG/$IMAGE_MICROSERVICE" .
$ podman push "$REGISTRY/$ORG/$IMAGE_MICROSERVICE"
```
