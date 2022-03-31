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

const Image = "docker.io/nheidloff/database-service:v1.0.17"

const Port int32 = 8089

const DataVolumeName = "data-volume"
const StorageClassName = "ibmc-vpc-block-5iops-tier"
const StorageResourceRequirement = "1Gi"
const DataDirectoryKey = "DATA_DIRECTORY"
const DataDirectoryValue = "/data"
const fsGroup = "2000"

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
