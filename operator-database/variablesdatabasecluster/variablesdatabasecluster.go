package variablesdatabasecluster

import (
	"fmt"
)

var StatefulSetName string
var ServiceName string
var ClusterRoleName string
var ClusterRoleBindingName string
var ContainerName string
var DataDirectory string = "/data"

var FsGroup int64 = 2000
var StorageResourceRequirement = "1Gi"
var StorageClassName string = "ibmc-vpc-block-5iops-tier"

const ANNOTATION_TITLE = "applications.application.sample.ibm.com/title"
const DEFAULT_ANNOTATION_TITLE = "My Title"
const LabelKey = "app"
const LabelValue = "database-cluster"
const Image = "docker.io/nheidloff/database-service:v1.0.23"
const Port int32 = 8089
const VolumeMountName = "data-volume"

const EnvKeyDataDirectory = "DATA_DIRECTORY"
const EnvKeyPodname = "POD_NAME"
const EnvKeyNamespace = "NAMESPACE"

const RoleBindingServiceAccount = "default"

func SetGlobalVariables(applicationName string) {
	StatefulSetName = applicationName + "-statefulset-databasecluster"
	ServiceName = applicationName + "-service-databasecluster"
	ClusterRoleName = applicationName + "-role-databasecluster"
	ClusterRoleBindingName = applicationName + "-rolebinding-databasecluster"
	ContainerName = applicationName + "--databasecluster"
}

func PrintVariables(databaseName string, databaseNamespace string, amountPods int32) {
	fmt.Println("Custom Resource Values:")
	fmt.Printf("- Name: %s\n", databaseName)
	fmt.Printf("- Namespace: %s\n", databaseNamespace)
	fmt.Printf("- AmountPods: %d\n", amountPods)
}