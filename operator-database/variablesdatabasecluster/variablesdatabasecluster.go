package variablesdatabasecluster

import (
	"fmt"
)

var StatefulSetName string
var ServiceName string
var ImageName string
var ClusterRoleName string
var ClusterRoleBindingName string
var ContainerName string
var DataDirectory string = "/data"

var StorageResourceRequirement = "1Gi"

// To improve portability between OpenShift environments, we rely on the cluster providing a default storage class
//var StorageClassName string = "ibmc-vpc-block-5iops-tier"

const ANNOTATION_TITLE = "applications.application.sample.ibm.com/title"
const DEFAULT_ANNOTATION_TITLE = "My Title"
const LabelKey = "app"
const LabelValue = "database-cluster"
const Port int32 = 8089
const VolumeMountName = "data-volume"

const EnvKeyDataDirectory = "DATA_DIRECTORY"
const EnvKeyPodname = "POD_NAME"
const EnvKeyNamespace = "NAMESPACE"

const RoleBindingServiceAccount = "default"

func SetGlobalVariables(applicationName string, image string) {
	applicationName = "database"
	StatefulSetName = applicationName + "-cluster"
	ServiceName = applicationName + "-service"
	ClusterRoleName = applicationName + "-role"
	ClusterRoleBindingName = applicationName + "-rolebinding"
	ContainerName = applicationName + "-app"
	ImageName = image
}

func PrintVariables(databaseName string, databaseNamespace string, amountPods int32) {
	fmt.Println("Custom Resource Values:")
	fmt.Printf("- Name: %s\n", databaseName)
	fmt.Printf("- Namespace: %s\n", databaseNamespace)
	fmt.Printf("- AmountPods: %d\n", amountPods)
	fmt.Printf("- Image: %s\n", ImageName)
}
