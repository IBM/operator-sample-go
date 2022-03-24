package applicationcontroller

import (
	"fmt"

	applicationsamplev1beta1 "github.com/ibm/operator-sample-go/operator-application/api/v1beta1"
	"k8s.io/client-go/rest"
)

var managerConfig *rest.Config

const finalizer = "database.sample.third.party/finalizer"

var secretName string
var deploymentName string
var serviceName string
var containerName string

const image = "docker.io/nheidloff/simple-microservice:v1.0.0"
const port int32 = 8081
const nodePort int32 = 30548
const labelKey = "app"
const labelValue = "myapplication"
const greetingMessage = "World"
const secretGreetingMessageLabel = "GREETING_MESSAGE"

// Note: For simplication purposes database properties are hardcoded
const databaseUser string = "name"
const databasePassword string = "password"
const databaseUrl string = "url"
const databaseCertificate string = "certificate"

func (reconciler *ApplicationReconciler) setGlobalVariables(application *applicationsamplev1beta1.Application) {
	secretName = application.Name + "-secret-greeting"
	deploymentName = application.Name + "-deployment-microservice"
	serviceName = application.Name + "-service-microservice"
	containerName = application.Name + "-microservice"
	// TODO: Handle application.Spec.Version
}

func (reconciler *ApplicationReconciler) printVariables(application *applicationsamplev1beta1.Application) {
	fmt.Println("Custom Resource Values:")
	fmt.Printf("- Name: %s\n", application.Name)
	fmt.Printf("- Namespace: %s\n", application.Namespace)
	fmt.Printf("- Version: %s\n", application.Spec.Version)
	fmt.Printf("- AmountPods: %d\n", application.Spec.AmountPods)
	fmt.Printf("- DatabaseName: %s\n", application.Spec.DatabaseName)
	fmt.Printf("- DatabaseNamespace: %s\n", application.Spec.DatabaseNamespace)
}
