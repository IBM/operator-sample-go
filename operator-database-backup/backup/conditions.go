package backup

import (
	"fmt"

	"github.com/ibm/operator-sample-go/operator-application/utilities"
)

const CONDITION_STATUS_TRUE = "True"
const CONDITION_STATUS_FALSE = "False"
const CONDITION_STATUS_UNKNOWN = "Unknown"

// Note: Status of COS_HMAC_ACCESS_KEY_ID_DEFINED can only be False; otherwise there is no condition
const CONDITION_TYPE_COS_HMAC_ACCESS_KEY_ID_DEFINED = "COSHMACAccessKeyIdDefined"
const CONDITION_REASON_COS_HMAC_ACCESS_KEY_ID_DEFINED = "COSHMACAccessKeyIdDefined"
const CONDITION_MESSAGE_COS_HMAC_ACCESS_KEY_ID_DEFINED = "Cloud Object Storage HMAC access key id is not defined"

func setConditionCOSHmacAccessKeyIdNotDefined() error {
	fmt.Println(CONDITION_MESSAGE_COS_HMAC_ACCESS_KEY_ID_DEFINED)
	return utilities.AppendCondition(applicationContext, kubernetesClient, databaseBackupResource, CONDITION_TYPE_COS_HMAC_ACCESS_KEY_ID_DEFINED, CONDITION_STATUS_FALSE,
		CONDITION_REASON_COS_HMAC_ACCESS_KEY_ID_DEFINED, CONDITION_MESSAGE_COS_HMAC_ACCESS_KEY_ID_DEFINED)
}

// Note: Status of COS_HMAC_SECRET_ACCESS_KEY_DEFINED can only be False; otherwise there is no condition
const CONDITION_TYPE_COS_HMAC_SECRET_ACCESS_KEY_DEFINED = "COSHMACSecretAccessKeyDefined"
const CONDITION_REASON_COS_HMAC_SECRET_ACCESS_KEY_DEFINED = "COSHMACSecretAccessKeyDefined"
const CONDITION_MESSAGE_COS_HMAC_SECRET_ACCESS_KEY_DEFINED = "Cloud Object Storage HMAC secret access key is not defined"

func setConditionCOSHmacSecretAccessKeyNotDefined() error {
	fmt.Println(CONDITION_MESSAGE_COS_HMAC_SECRET_ACCESS_KEY_DEFINED)
	return utilities.AppendCondition(applicationContext, kubernetesClient, databaseBackupResource, CONDITION_TYPE_COS_HMAC_SECRET_ACCESS_KEY_DEFINED, CONDITION_STATUS_FALSE,
		CONDITION_REASON_COS_HMAC_SECRET_ACCESS_KEY_DEFINED, CONDITION_MESSAGE_COS_HMAC_SECRET_ACCESS_KEY_DEFINED)
}

// Note: Status of COS_REGION_DEFINED can only be False; otherwise there is no condition
const CONDITION_TYPE_COS_REGION_DEFINED = "COSRegionDefined"
const CONDITION_REASON_COS_REGION_DEFINED = "COSRegionDefined"
const CONDITION_MESSAGE_COS_REGION_DEFINED = "Cloud Object Storage region is not defined"

func setConditionCOSRegionNotDefined() error {
	fmt.Println(CONDITION_MESSAGE_COS_REGION_DEFINED)
	return utilities.AppendCondition(applicationContext, kubernetesClient, databaseBackupResource, CONDITION_TYPE_COS_REGION_DEFINED, CONDITION_STATUS_FALSE,
		CONDITION_REASON_COS_REGION_DEFINED, CONDITION_MESSAGE_COS_REGION_DEFINED)
}

// Note: Status of COS_SERVICE_ENDPOINT_DEFINED can only be False; otherwise there is no condition
const CONDITION_TYPE_COS_SERVICE_ENDPOINT_DEFINED = "COSServiceEndpointDefined"
const CONDITION_REASON_COS_SERVICE_ENDPOINT_DEFINED = "COSServiceEndpointDefined"
const CONDITION_MESSAGE_COS_SERVICE_ENDPOINT_DEFINED = "Cloud Object Storage service endpoint is not defined"

func setConditionCOSServiceEndpointNotDefined() error {
	fmt.Println(CONDITION_MESSAGE_COS_SERVICE_ENDPOINT_DEFINED)
	return utilities.AppendCondition(applicationContext, kubernetesClient, databaseBackupResource, CONDITION_TYPE_COS_SERVICE_ENDPOINT_DEFINED, CONDITION_STATUS_FALSE,
		CONDITION_REASON_COS_SERVICE_ENDPOINT_DEFINED, CONDITION_MESSAGE_COS_SERVICE_ENDPOINT_DEFINED)
}

// Note: Status of NAMESPACE_DEFINED can only be False; otherwise there is no condition
const CONDITION_TYPE_NAMESPACE_DEFINED = "NamespaceDefined"
const CONDITION_REASON_NAMESPACE_DEFINED = "NamespaceDefined"
const CONDITION_MESSAGE_NAMESPACE_DEFINED = "Namespace is not defined"

func setConditionNamespaceDefined() error {
	fmt.Println(CONDITION_MESSAGE_NAMESPACE_DEFINED)
	return utilities.AppendCondition(applicationContext, kubernetesClient, databaseBackupResource, CONDITION_TYPE_NAMESPACE_DEFINED, CONDITION_STATUS_FALSE,
		CONDITION_REASON_NAMESPACE_DEFINED, CONDITION_MESSAGE_NAMESPACE_DEFINED)
}

// Note: Status of BACKUP_RESOURCE_NAME_DEFINED can only be False; otherwise there is no condition
const CONDITION_TYPE_BACKUP_RESOURCE_NAME_DEFINED = "BackupResourceNameDefined"
const CONDITION_REASON_BACKUP_RESOURCE_NAME_DEFINED = "BackupResourceNameDefined"
const CONDITION_MESSAGE_BACKUP_RESOURCE_NAME_DEFINED = "Backup resource name is not defined"

func setConditionBackupResourceNameDefined() error {
	fmt.Println(CONDITION_MESSAGE_BACKUP_RESOURCE_NAME_DEFINED)
	return utilities.AppendCondition(applicationContext, kubernetesClient, databaseBackupResource, CONDITION_TYPE_BACKUP_RESOURCE_NAME_DEFINED, CONDITION_STATUS_FALSE,
		CONDITION_REASON_BACKUP_RESOURCE_NAME_DEFINED, CONDITION_MESSAGE_BACKUP_RESOURCE_NAME_DEFINED)
}

// Note: Status of DATA_READ can only be False; otherwise there is no condition
const CONDITION_TYPE_DATA_READ = "DataRead"
const CONDITION_REASON_DATA_READ = "DataRead"
const CONDITION_MESSAGE_DATA_READ = "Data could not be read"

func setConditionDataRead() error {
	fmt.Println(CONDITION_MESSAGE_DATA_READ)
	return utilities.AppendCondition(applicationContext, kubernetesClient, databaseBackupResource, CONDITION_TYPE_DATA_READ, CONDITION_STATUS_FALSE,
		CONDITION_REASON_DATA_READ, CONDITION_MESSAGE_DATA_READ)
}

// Note: Status of DATA_WRITTEN can only be False; otherwise there is no condition
const CONDITION_TYPE_DATA_WRITTEN = "DataWritten"
const CONDITION_REASON_DATA_WRITTEN = "DataWritten"
const CONDITION_MESSAGE_DATA_WRITTEN = "Data could not be written"

func setConditionDataWritten() error {
	fmt.Println(CONDITION_MESSAGE_DATA_WRITTEN)
	return utilities.AppendCondition(applicationContext, kubernetesClient, databaseBackupResource, CONDITION_TYPE_DATA_WRITTEN, CONDITION_STATUS_FALSE,
		CONDITION_REASON_DATA_WRITTEN, CONDITION_MESSAGE_DATA_WRITTEN)
}

// Note: Status of SUCCEEDED can only be True
const CONDITION_TYPE_SUCCEEDED = "Succeeded"
const CONDITION_REASON_SUCCEEDED = "BackupSucceeded"
const CONDITION_MESSAGE_SUCCEEDED = "Database has been archived"

func addConditionSucceeded() error {
	fmt.Println(CONDITION_MESSAGE_SUCCEEDED)
	return utilities.AppendCondition(applicationContext, kubernetesClient, databaseBackupResource, CONDITION_TYPE_SUCCEEDED, CONDITION_STATUS_TRUE,
		CONDITION_REASON_SUCCEEDED, CONDITION_MESSAGE_SUCCEEDED)
}
