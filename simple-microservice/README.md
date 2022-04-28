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

#### Step 1: Clone the project

```sh
git clone https://github.com/ibm/operator-sample-go.git
```

#### Step 2: Navigate to the application folder

```sh
cd operator-sample-go/simple-microservice
```

#### Step 3: Define a environment variable as a parameter

```sh
export GREETING_MESSAGE=World
```

#### Step 4: Run the application in development mode

```sh
mvn clean quarkus:dev
```

#### Step 5: Open the application `hello` endpoint

```sh
open http://localhost:8081/hello
```

#### Step 6: Access the metrics endpoint for later usage in context of monitoring

```sh
open http://localhost:8081/q/metrics/application
```

### Run as a container

#### Step 1: Clone project

```sh
git clone https://github.com/ibm/operator-sample-go.git
```

#### Step 2: Navigate to the application folder

```sh
cd operator-sample-go/simple-microservice
```

#### Step 3: Build container locally

```sh
export REPOSITORY_URL=nheidloff
podman build -t $REPOSITORY_URL/simple-microservice .
```

#### Step 4: Run the container locally and using the environment variable as a parameter

```sh
podman run -i --rm -p 8081:8081 -e GREETING_MESSAGE=World $REPOSITORY_URL/simple-microservice
```

#### Step 5: Open the application `hello` endpoint

```sh
open http://localhost:8081/hello
```

### Build and push a new image to the container registry

#### Step 1: Clone the project

```sh
git clone https://github.com/ibm/operator-sample-go.git
```

#### Step 2: Navigate to the application folder

```sh
cd operator-sample-go/simple-microservice
```
#### Step 3: Use environment [`.env`](../versions.env) file for environment variable definition 

```sh
code ../versions.env
source ../versions.env
```

Example configuration:

```env
# Definition of the used container registry
export REGISTRY='quay.io'

# Definition of the repository inside the container registry
export ORG=tsuedbroecker

# container image names including the tag
export IMAGE_MICROSERVICE='simple-microservice:v1.0.11'
```

#### Step 4: Build the container

```sh
podman build -t "$REGISTRY/$ORG/$IMAGE_MICROSERVICE" .
```

#### Step 5: Push the container

```sh
echo "$REGISTRY/$ORG/$IMAGE_MICROSERVICE"
podman push "$REGISTRY/$ORG/$IMAGE_MICROSERVICE"
```
