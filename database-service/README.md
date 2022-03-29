# Database Service

The database service simulates a simple database that writes and reads data to and from a local JSON file. The service has been built with Quarkus.

### Run locally

```
$ git clone https://github.com/ibm/operator-sample-go.git
$ cd database-service
$ mvn clean quarkus:dev
$ open http://localhost:8089/q/swagger-ui/
$ open http://localhost:8089/persons
```

```
$ curl http://localhost:8089/persons
$ curl -X 'GET' \
  'http://localhost:8089/persons/e0a08c5b-62d5-4b20-a024-e1c270d901c2' \
  -H 'accept: application/json'
$ curl -X 'DELETE' \
  'http://localhost:8089/persons' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{"id": "e0a08c5b-62d5-4b20-a024-e1c270d901c2"}'
$ curl -X 'POST' \
  'http://localhost:8089/persons' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "firstName": "Mo",
  "lastName": "Haghighi",
  "id": "e956b5d0-fa0c-40e8-9da9-333c214dcaf7"
}'
```

### Run as Container

```
$ git clone https://github.com/ibm/operator-sample-go.git
$ cd database-service
$ mvn clean install
$ docker build -f src/main/docker/Dockerfile.jvm -t nheidloff/database-service .
$ docker run -i --rm -p 8089:8089 -e GREETING_MESSAGE=World nheidloff/database-service
$ open http://localhost:8089/q/swagger-ui/
$ open http://localhost:8089/persons
$ docker tag nheidloff/database-service docker.io/nheidloff/database-service:v1.0.0
$ docker push docker.io/nheidloff/database-service:v1.0.0
```