package backup

import (
	"context"
	"fmt"
	"os"

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
	appContext context.Context
)

func Run() {
	fmt.Println("Start backup.Run()")
	appContext = context.Background()

	if len(backupResourceName) < 1 {
		exitWithErrorCondition(CONDITION_TYPE_BACKUP_RESOURCE_NAME_DEFINED)
	}
	if len(namespace) < 1 {
		exitWithErrorCondition(CONDITION_TYPE_NAMESPACE_DEFINED)
	}
	if len(cosAPIKey) < 1 {
		exitWithErrorCondition(CONDITION_TYPE_COS_API_KEY_DEFINED)
	}
	if len(cosServiceInstanceId) < 1 {
		exitWithErrorCondition(CONDITION_TYPE_COS_SERVICE_INSTANCE_ID_DEFINED)
	}

	// TODO
	// getBackupResource(BACKUP_RESOURCE_NAME, NAMESPACE)

	data, err := readData()
	if err != nil {
		exitWithErrorCondition(CONDITION_TYPE_DATA_READ)
	}
	fmt.Println("data:")
	fmt.Println(data)

	err = writeData(data)
	if err != nil {
		fmt.Println(err)
		exitWithErrorCondition(CONDITION_TYPE_DATA_WRITTEN)
	}

	// TODO
	var controllerRuntimeClient client.Client
	var object client.Object
	addConditionSucceeded(appContext, controllerRuntimeClient, object)
}

func exitWithErrorCondition(conditionType string) {
	// TODO
	var controllerRuntimeClient client.Client
	var object client.Object

	switch conditionType {
	case CONDITION_TYPE_BACKUP_RESOURCE_NAME_DEFINED:
		setConditionBackupResourceNameDefined(appContext, controllerRuntimeClient, object)
	case CONDITION_TYPE_NAMESPACE_DEFINED:
		setConditionNamespaceDefined(appContext, controllerRuntimeClient, object)
	case CONDITION_TYPE_COS_API_KEY_DEFINED:
		setConditionCOSAPIKeyDefined(appContext, controllerRuntimeClient, object)
	case CONDITION_TYPE_COS_SERVICE_INSTANCE_ID_DEFINED:
		setConditionCOSServiceInstanceIdNotDefined(appContext, controllerRuntimeClient, object)
	case CONDITION_TYPE_DATA_READ:
		setConditionDataRead(appContext, controllerRuntimeClient, object)
	case CONDITION_TYPE_DATA_WRITTEN:
		setConditionDataWritten(appContext, controllerRuntimeClient, object)
	}

	os.Exit(1)
}
