package variables

import (
	"fmt"
)

const Finalizer = "database.sample.third.party/finalizer"

var SecretName string
var ImageName string
var DeploymentName string
var ServiceName string
var ContainerName string
var MonitorName string

const ANNOTATION_TITLE = "applications.application.sample.ibm.com/title"
const DEFAULT_ANNOTATION_TITLE = "My Title"

const Port int32 = 8081
const NodePort int32 = 30548
const LabelKey = "app"
const GreetingMessage = "World"
const SecretGreetingMessageLabel = "GREETING_MESSAGE"

// Note: For simplication purposes database properties are hardcoded
const DatabaseUser string = "name"
const DatabasePassword string = "password"
const DatabaseUrl string = "url"
const DatabaseCertificate string = "certificate"

func SetGlobalVariables(applicationName string, image string) {
	SecretName = applicationName + "-secret-greeting"
	DeploymentName = applicationName + "-deployment-microservice"
	ServiceName = applicationName + "-service-microservice"
	ContainerName = applicationName + "-microservice"
	MonitorName = applicationName + "-monitor"
	ImageName = image
}

func PrintVariables(applicationName string, applicationNamespace string, version string, amountPods int32, databaseName string, databaseNamespace string) {
	fmt.Println("Custom Resource Values:")
	fmt.Printf("- Name: %s\n", applicationName)
	fmt.Printf("- Namespace: %s\n", applicationNamespace)
	fmt.Printf("- Version: %s\n", version)
	fmt.Printf("- AmountPods: %d\n", amountPods)
	fmt.Printf("- DatabaseName: %s\n", databaseName)
	fmt.Printf("- DatabaseNamespace: %s\n", databaseNamespace)
	fmt.Printf("- Image: %s\n", ImageName)
}
