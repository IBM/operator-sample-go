package variables

import (
	"fmt"
)

const Finalizer = "database.sample.third.party/finalizer"

var CronJobName string
var SecretName string
var ImageName string
var DeploymentName string
var ServiceName string
var ContainerName string
var MonitorName string
var ClusterRoleName string
var ClusterRoleBindingName string

var ClusterRoleNameOCP string
var ClusterRoleBindingNameOCPWithOLM string
var ClusterRoleBindingNameOCPWithoutOLM string

var ApplicationScalerContainerName string

const ANNOTATION_TITLE = "applications.application.sample.ibm.com/title"
const DEFAULT_ANNOTATION_TITLE = "My Title"

const Port int32 = 8081
const NodePort int32 = 30548
const LabelKey = "app"
const GreetingMessage = "World"
const SecretGreetingMessageLabel = "GREETING_MESSAGE"
const CronJobSchedule = "0 * * * *"
const ApplicationScalerImageName = "docker.io/deleeuw/operator-application-scaler:v1.0.23"
const IKSvolumeMountscertdatamountPath = "/etc/prometheus-k8s-cert"
const IKSvolumeMountscertdatatokendata = "/etc/prometheus-k8s-token"
const OCPvolumescertdatasecretName = "prometheus-cert-secret"
const OCPvolumestokendatasecretName = "prometheus-token-secret"

const EnvApplicationResourceName = "APPLICATION_RESOURCE_NAME"
const EnvKeyApplicationResourceNameSpace = "APPLICATION_RESOURCE_NAMESPACE"
const ValueApplicationResourceName = "application"
const ValueApplicationResourceNameSpace = "application-beta"

const LabelValue = "application"
const RoleBindingServiceAccount = "default"
const RoleBindingServiceAccountOCP = "default"

const OCPOperatorWithOLMNamespace = "openshift-operators"
const OCPOperatorWithoutOLMNamespace = "operator-application-system"
const OCPClusterRoleNamespace = "openshift-monitoring"

// Note: For simplication purposes database properties are hardcoded
const DatabaseUser string = "name"
const DatabasePassword string = "password"
const DatabaseUrl string = "url"
const DatabaseCertificate string = "certificate"

func SetGlobalVariables(applicationName string, image string) {
	CronJobName = applicationName + "-scaler"
	SecretName = applicationName + "-secret-greeting"
	DeploymentName = applicationName + "-deployment-microservice"
	ServiceName = applicationName + "-service-microservice"
	ContainerName = applicationName + "-microservice"
	MonitorName = applicationName + "-monitor"
	ClusterRoleName = applicationName + "-application-scaler-role"
	ClusterRoleBindingName = applicationName + "-application-scaler-rolebinding"
	ClusterRoleNameOCP = applicationName + "-prometheus-k8s-role"
	ClusterRoleBindingNameOCPWithOLM = applicationName + "-prometheus-k8s-rolebinding-olm"
	ClusterRoleBindingNameOCPWithoutOLM = applicationName + "-prometheus-k8s-rolebinding"
	ImageName = image
	ApplicationScalerContainerName = applicationName + "-appscaler"
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
	fmt.Printf("- CronJobName: %s\n", CronJobName)
	fmt.Printf("- ApplicationScalerContainerName: %s\n", ApplicationScalerContainerName)
}
