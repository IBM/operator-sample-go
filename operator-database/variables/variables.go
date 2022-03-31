package variables

import (
	"fmt"
)

var SecretName string
var DeploymentName string
var StatefulSetName string
var ServiceName string
var ContainerName string

const ANNOTATION_TITLE = "applications.application.sample.ibm.com/title"
const DEFAULT_ANNOTATION_TITLE = "My Title"

const LabelKey = "app"
const LabelValue = "mydatabase"

const Image = "docker.io/nheidloff/database-service:v1.0.0"
const Port int32 = 8089

func SetGlobalVariables(applicationName string) {
	SecretName = applicationName + "-secret-greeting"
	DeploymentName = applicationName + "-deployment-microservice"
	StatefulSetName = applicationName + "-statefulset-microservice"
	ServiceName = applicationName + "-service-microservice"
	ContainerName = applicationName + "-microservice"
}

func PrintVariables(databaseName string, databaseNamespace string, amountPods int32) {
	fmt.Println("Custom Resource Values:")
	fmt.Printf("- Name: %s\n", databaseName)
	fmt.Printf("- Namespace: %s\n", databaseNamespace)
	fmt.Printf("- AmountPods: %d\n", amountPods)
}
