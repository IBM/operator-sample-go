package variablesdatabasebackup

import (
	"fmt"

	databasesamplev1alpha1 "github.com/ibm/operator-sample-go/operator-database/api/v1alpha1"
)

var CronJobName string
var JobName string
var ContainerName string
var BackupRoleName string
var BackupRoleBindingName string

const Image = "docker.io/nheidloff/operator-database-backup:v1.0.7"
const LabelKey = "app"
const LabelValue = "database-backup"
const EnvKeyBackupResourceName = "BACKUP_RESOURCE_NAME"
const BackupResourceName = "databasebackup-manual"
const EnvKeyNamespace = "NAMESPACE"
const EnvKeyCosHmacAccessKeyId = "CLOUD_OBJECT_STORAGE_HMAC_ACCESS_KEY_ID"
const EnvKeyCosHmacSecretAccessKey = "CLOUD_OBJECT_STORAGE_HMAC_SECRET_ACCESS_KEY"
const EnvKeyCosRegion = "CLOUD_OBJECT_STORAGE_REGION"
const EnvKeyCosSecretName = "ibmcos-repo"
const EnvKeyCosSecretDataKeyHmacAccessKeyId = "apikey"
const EnvKeyCosSecretDataKeyHmacSecretAccess = "serviceInstanceId"

//const CosRegion = "eu-geo"
const EnvKeyCosEndpoint = "CLOUD_OBJECT_STORAGE_SERVICE_ENDPOINT"

//const cosEndpoint = "s3.eu.cloud-object-storage.appdomain.cloud"
const RoleBindingServiceAccount = "default"

func SetGlobalVariables(applicationName string) {
	CronJobName = applicationName + "-cronjob-databasebackup"
	JobName = applicationName + "-job-databasebackup"
	ContainerName = applicationName + "--databasebackup"
	BackupRoleName = applicationName + "-role-databasebackup"
	BackupRoleBindingName = applicationName + "-rolebinding-databasebackup"
}

func PrintVariables(databaseName string, databaseNamespace string, repos []databasesamplev1alpha1.BackupRepo, manualTrigger databasesamplev1alpha1.ManualTrigger, scheduledTrigger databasesamplev1alpha1.ScheduledTrigger) {
	fmt.Println("Custom Resource Values:")
	fmt.Printf("- Name: %s\n", databaseName)
	fmt.Printf("- Namespace: %s\n", databaseNamespace)

	for i, r := range repos {
		fmt.Printf("- Repo.Name[%d]: %s\n", i, r.Name)
		fmt.Printf("- Repo.Type[%d].ServiceEndpoint: %s\n", i, r.ServiceEndpoint)
		fmt.Printf("- Repo.Type[%d].BucketNamePrefix: %s\n", i, r.BucketNamePrefix)
		fmt.Printf("- Repo.Type[%d].SecretName: %s\n", i, r.SecretName)
	}
	fmt.Printf("- ManualTrigger.Repo: %s\n", manualTrigger.Repo)
	fmt.Printf("- ManualTrigger.Time: %s\n", manualTrigger.Time)
	//fmt.Printf("- ManualTrigger.Enabled: %t\n", manualTrigger.Enabled)

	fmt.Printf("- ScheduledTrigger.Repo: %s\n", scheduledTrigger.Repo)
	fmt.Printf("- ScheduledTrigger.Schedule: %s\n", scheduledTrigger.Schedule)
	//fmt.Printf("- ScheduledTrigger.Enabled: %t\n", scheduledTrigger.Enabled)

}
