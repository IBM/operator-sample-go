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
	backupResourceName     = env.GetString("BACKUP_RESOURCE_NAME", "")
	namespace              = env.GetString("NAMESPACE", "")
	cosHmacAccessKeyId     = env.GetString("CLOUD_OBJECT_STORAGE_HMAC_ACCESS_KEY_ID", "")
	cosHmacSecretAccessKey = env.GetString("CLOUD_OBJECT_STORAGE_HMAC_SECRET_ACCESS_KEY", "")
	cosRegion              = env.GetString("CLOUD_OBJECT_STORAGE_REGION", "")
	cosServiceEndpoint     = env.GetString("CLOUD_OBJECT_STORAGE_SERVICE_ENDPOINT", "")

	// optional environment variables
	cosBucketNamePrefix = env.GetString("CLOUD_OBJECT_STORAGE_BUCKET_NAME_PREFIX", "database-backup-")

	// internal
	applicationContext     context.Context
	kubernetesClient       client.Client
	databaseBackupResource *databaseoperatorv1alpha1.DatabaseBackup
)

func Run() {
	fmt.Println("Start backup.Run()")
	applicationContext = context.Background()

	err := getBackupResource()
	if err != nil {
		exit(err)
	}

	if len(backupResourceName) < 1 {
		exitWithErrorCondition(CONDITION_TYPE_BACKUP_RESOURCE_NAME_DEFINED, nil)
	}
	if len(namespace) < 1 {
		exitWithErrorCondition(CONDITION_TYPE_NAMESPACE_DEFINED, nil)
	}
	if len(cosHmacAccessKeyId) < 1 {
		exitWithErrorCondition(CONDITION_TYPE_COS_HMAC_ACCESS_KEY_ID_DEFINED, nil)
	}
	if len(cosHmacSecretAccessKey) < 1 {
		exitWithErrorCondition(CONDITION_TYPE_COS_HMAC_SECRET_ACCESS_KEY_DEFINED, nil)
	}
	if len(cosRegion) < 1 {
		exitWithErrorCondition(CONDITION_TYPE_COS_REGION_DEFINED, nil)
	}
	if len(cosServiceEndpoint) < 1 {
		exitWithErrorCondition(CONDITION_TYPE_COS_SERVICE_ENDPOINT_DEFINED, nil)
	}

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
	fmt.Println("Exit backup.exitWithErrorCondition()")
	if err != nil {
		fmt.Println(err)
	}

	switch conditionType {
	case CONDITION_TYPE_BACKUP_RESOURCE_NAME_DEFINED:
		err = setConditionBackupResourceNameDefined()
	case CONDITION_TYPE_NAMESPACE_DEFINED:
		err = setConditionNamespaceDefined()
	case CONDITION_TYPE_COS_HMAC_ACCESS_KEY_ID_DEFINED:
		err = setConditionCOSHmacAccessKeyIdNotDefined()
	case CONDITION_TYPE_COS_HMAC_SECRET_ACCESS_KEY_DEFINED:
		err = setConditionCOSHmacSecretAccessKeyNotDefined()
	case CONDITION_TYPE_COS_REGION_DEFINED:
		err = setConditionCOSRegionNotDefined()
	case CONDITION_TYPE_COS_SERVICE_ENDPOINT_DEFINED:
		err = setConditionCOSServiceEndpointNotDefined()
	case CONDITION_TYPE_DATA_READ:
		err = setConditionDataRead()
	case CONDITION_TYPE_DATA_WRITTEN:
		err = setConditionDataWritten()
	}

	if err != nil {
		exit(err)
	}

	os.Exit(1)
}

func exit(err error) {
	fmt.Println("backup.exit()")
	if err != nil {
		fmt.Println(err)
	}

	os.Exit(1)
}
