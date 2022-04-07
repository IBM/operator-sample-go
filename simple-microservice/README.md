# Simple Microservice

The microservice provides a hello world endpoint which prints out an input environment variable. The service has been built with Quarkus.

### Run locally

```
$ git clone https://github.com/ibm/operator-sample-go.git
$ cd simple-microservice
$ mvn clean quarkus:dev
$ open http://localhost:8081/hello
```

### Run as Container

```
$ git clone https://github.com/ibm/operator-sample-go.git
$ podman build -t nheidloff/simple-microservice .
$ podman run -i --rm -p 8081:8081 -e GREETING_MESSAGE=World nheidloff/simple-microservice 
$ open http://localhost:8081/hello
```

### Build new Image

```
$ git clone https://github.com/ibm/operator-sample-go.git
$ cd simple-microservice
$ export REGISTRY='docker.io'
$ export ORG='nheidloff'
$ export IMAGE_MICROSERVICE='simple-microservice:v1.0.9'
$ podman build -t "$REGISTRY/$ORG/$IMAGE_MICROSERVICE" .
$ podman push "$REGISTRY/$ORG/$IMAGE_MICROSERVICE"
```
