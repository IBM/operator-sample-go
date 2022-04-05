package backup

import (
	"context"
	"fmt"
	"os"

	databaseoperatorv1alpha1 "github.com/ibm/operator-sample-go/operator-database/api/v1alpha1"
	"k8s.io/utils/env"
	"sigs.k8s.io/controller-runtime/pkg/client"
)

var (
	// mandatory enviornment variables
	backupResourceName   = env.GetString("BACKUP_RESOURCE_NAME", "")
	cosAPIKey            = env.GetString("CLOUD_OBJECT_STORAGE_API_KEY", "")
	cosServiceInstanceId = env.GetString("CLOUD_OBJECT_STORAGE_SERVICE_INSTANCE_ID", "")
	cosServiceEndpoint   = env.GetString("CLOUD_OBJECT_STORAGE_SERVICE_ENDPOINT", "https://s3.fra.eu.cloud-object-storage.appdomain.cloud")

	// optional environment variables
	cosAuthEndpoint     = env.GetString("CLOUD_OBJECT_STORAGE_AUTH_ENDPOINT", "https://iam.cloud.ibm.com/identity/token")
	cosBucketNamePrefix = env.GetString("CLOUD_OBJECT_STORAGE_BUCKET_NAME_PREFIX", "database-backup-")
	namespace           = env.GetString("NAMESPACE", "database")

	// internal
	applicationContext     context.Context
	kubernetesClient       client.Client
	databaseBackupResource databaseoperatorv1alpha1.DatabaseBackup
)

func Run() {
	fmt.Println("Start backup.Run()")
	applicationContext = context.Background()

	if len(backupResourceName) < 1 {
		exitWithErrorCondition(CONDITION_TYPE_BACKUP_RESOURCE_NAME_DEFINED, nil)
	}
	if len(namespace) < 1 {
		exitWithErrorCondition(CONDITION_TYPE_NAMESPACE_DEFINED, nil)
	}
	if len(cosAPIKey) < 1 {
		exitWithErrorCondition(CONDITION_TYPE_COS_API_KEY_DEFINED, nil)
	}
	if len(cosServiceInstanceId) < 1 {
		exitWithErrorCondition(CONDITION_TYPE_COS_SERVICE_INSTANCE_ID_DEFINED, nil)
	}

	err := getBackupResource()
	if err != nil {
		exitWithErrorCondition(CONDITION_TYPE_BACKUP_RESOURCE_FOUND, err)
	}
	fmt.Println("databaseBackupResource:")
	fmt.Println(databaseBackupResource.Name)

	data, err := readData()
	if err != nil {
		exitWithErrorCondition(CONDITION_TYPE_DATA_READ, err)
	}
	fmt.Println("data:")
	fmt.Println(data)

	err = writeData(data)
	if err != nil {
		exitWithErrorCondition(CONDITION_TYPE_DATA_WRITTEN, err)
	}

	addConditionSucceeded()
}

func exitWithErrorCondition(conditionType string, err error) {
	fmt.Println("Exit backup.Run() with error")
	if err != nil {
		fmt.Println(err)
	}

	switch conditionType {
	case CONDITION_TYPE_BACKUP_RESOURCE_NAME_DEFINED:
		setConditionBackupResourceNameDefined()
	case CONDITION_TYPE_NAMESPACE_DEFINED:
		setConditionNamespaceDefined()
	case CONDITION_TYPE_COS_API_KEY_DEFINED:
		setConditionCOSAPIKeyDefined()
	case CONDITION_TYPE_COS_SERVICE_INSTANCE_ID_DEFINED:
		setConditionCOSServiceInstanceIdNotDefined()
	case CONDITION_TYPE_DATA_READ:
		setConditionDataRead()
	case CONDITION_TYPE_DATA_WRITTEN:
		setConditionDataWritten()
	case CONDITION_TYPE_BACKUP_RESOURCE_FOUND:
		setConditionBackupResourceFound()
	}

	os.Exit(1)
}
