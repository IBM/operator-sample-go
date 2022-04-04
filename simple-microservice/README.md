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
$ cd simple-microservice
$ mvn clean install
$ docker build -f src/main/docker/Dockerfile.jvm -t nheidloff/simple-microservice .
$ podman run -i --rm -p 8081:8081 -e GREETING_MESSAGE=World nheidloff/simple-microservice
$ open http://localhost:8081/hello
$ podman tag nheidloff/simple-microservice docker.io/nheidloff/simple-microservice:v1.0.0
$ podman push docker.io/nheidloff/simple-microservice:v1.0.0
```