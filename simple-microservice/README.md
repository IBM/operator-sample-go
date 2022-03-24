# simple-microservice

The microservice provides a hello world endpoint which prints out an input environment variable. The service has been built with Quarkus.

### Run locally

```
$ https://github.com/nheidloff/operator-sample-go.git
$ cd simple-microservice
$ mvn clean quarkus:dev
$ open http://localhost:8081/hello
```

### Run as Container

```
$ https://github.com/nheidloff/operator-sample-go.git
$ cd simple-microservice
$ mvn clean install
$ podman build -f src/main/docker/Dockerfile.jvm -t nheidloff/simple-microservice .
$ podman run -i --rm -p 8081:8081 -e GREETING_MESSAGE=World nheidloff/simple-microservice
$ open http://localhost:8081/hello
$ podman tag localhost/nheidloff/simple-microservice docker.io/nheidloff/simple-microservice
$ podman push docker.io/nheidloff/simple-microservice
```