package backup

import (
	//"context"
	"fmt"

	//"github.com/ibm/operator-sample-go/operator-application/utilities"
	"sigs.k8s.io/controller-runtime/pkg/client"
)

const CONDITION_STATUS_TRUE = "True"
const CONDITION_STATUS_FALSE = "False"
const CONDITION_STATUS_UNKNOWN = "Unknown"

// Note: Status of COS_API_KEY_DEFINED can only be False; otherwise there is no condition
const CONDITION_TYPE_COS_API_KEY_DEFINED = "COSAPIKeyDefined"
const CONDITION_REASON_COS_API_KEY_DEFINED = "COSAPIKeyDefined"
const CONDITION_MESSAGE_COS_API_KEY_DEFINED = "Cloud Object Storage API key is not defined"

func setConditionCOSAPIKeyDefined(controllerRuntimeClient client.Client, object client.Object) error {
	fmt.Println("Adding COS_API_KEY_DEFINED condition ...")
	//return utilities.AppendCondition(context.Background(), controllerRuntimeClient, object, CONDITION_TYPE_COS_API_KEY_DEFINED, CONDITION_STATUS_FALSE,
	//	CONDITION_REASON_COS_API_KEY_DEFINED, CONDITION_MESSAGE_COS_API_KEY_DEFINED)
	return nil
}

// Note: Status of COS_SERVICE_INSTANCE_ID_DEFINED can only be False; otherwise there is no condition
const CONDITION_TYPE_COS_SERVICE_INSTANCE_ID_DEFINED = "COSServiceInstanceIdDefined"
const CONDITION_REASON_COS_SERVICE_INSTANCE_DEFINED = "COSServiceInstanceIdDefined"
const CONDITION_MESSAGE_COS_SERVICE_INSTANCE_DEFINED = "Cloud Object Storage service instance id is not defined"

func setConditionCOSServiceInstanceIdNotDefined(controllerRuntimeClient client.Client, object client.Object) error {
	fmt.Println("Adding COS_SERVICE_INSTANCE_ID_DEFINED condition ...")
	//return utilities.AppendCondition(context.Background(), controllerRuntimeClient, object, CONDITION_TYPE_COS_SERVICE_INSTANCE_ID_DEFINED, CONDITION_STATUS_FALSE,
	//	CONDITION_REASON_COS_SERVICE_INSTANCE_ID_DEFINED, CONDITION_MESSAGE_COS_SERVICE_INSTANCE_ID_DEFINED)
	return nil
}

// Note: Status of NAMESPACE_DEFINED can only be False; otherwise there is no condition
const CONDITION_TYPE_NAMESPACE_DEFINED = "NamespaceDefined"
const CONDITION_REASON_NAMESPACE_DEFINED = "NamespaceDefined"
const CONDITION_MESSAGE_NAMESPACE_DEFINED = "Namespace is not defined"

func setConditionNamespaceDefined(controllerRuntimeClient client.Client, object client.Object) error {
	fmt.Println("Adding NAMESPACE_DEFINED condition ...")
	//return utilities.AppendCondition(context.Background(), controllerRuntimeClient, object, CONDITION_TYPE_NAMESPACE_DEFINED, CONDITION_STATUS_FALSE,
	//	CONDITION_REASON_NAMESPACE_DEFINED, CONDITION_MESSAGE_NAMESPACE_DEFINED)
	return nil
}

// Note: Status of BACKUP_RESOURCE_NAME_DEFINED can only be False; otherwise there is no condition
const CONDITION_TYPE_BACKUP_RESOURCE_NAME_DEFINED = "BackupResourceNameDefined"
const CONDITION_REASON_BACKUP_RESOURCE_NAME_DEFINED = "BackupResourceNameDefined"
const CONDITION_MESSAGE_BACKUP_RESOURCE_NAME_DEFINED = "Backup resource name is not defined"

func setConditionBackupResourceNameDefined(controllerRuntimeClient client.Client, object client.Object) error {
	fmt.Println("Adding BACKUP_RESOURCE_NAME_DEFINED condition ...")
	//return utilities.AppendCondition(context.Background(), controllerRuntimeClient, object, CONDITION_TYPE_BACKUP_RESOURCE_NAME_DEFINED, CONDITION_STATUS_FALSE,
	//	CONDITION_REASON_BACKUP_RESOURCE_NAME_DEFINED, CONDITION_MESSAGE_BACKUP_RESOURCE_NAME_DEFINED)
	return nil
}

// Note: Status of DATA_READ can only be False; otherwise there is no condition
const CONDITION_TYPE_DATA_READ = "DataRead"
const CONDITION_REASON_DATA_READ = "DataRead"
const CONDITION_MESSAGE_DATA_READ = "Data could not be read"

func setConditionDataRead(controllerRuntimeClient client.Client, object client.Object) error {
	fmt.Println("Adding DATA_READ condition ...")
	//return utilities.AppendCondition(context.Background(), controllerRuntimeClient, object, CONDITION_TYPE_DATA_READ, CONDITION_STATUS_FALSE,
	//	CONDITION_REASON_DATA_READ, CONDITION_MESSAGE_DATA_READ)
	return nil
}

// Note: Status of DATA_WRITTEN can only be False; otherwise there is no condition
const CONDITION_TYPE_DATA_WRITTEN = "DataWritten"
const CONDITION_REASON_DATA_WRITTEN = "DataWritten"
const CONDITION_MESSAGE_DATA_WRITTEN = "Data could not be written"

func setConditionDataWritten(controllerRuntimeClient client.Client, object client.Object) error {
	fmt.Println("Adding DATA_WRITTEN condition ...")
	//return utilities.AppendCondition(context.Background(), controllerRuntimeClient, object, CONDITION_TYPE_DATA_WRITTEN, CONDITION_STATUS_FALSE,
	//	CONDITION_REASON_DATA_WRITTEN, CONDITION_MESSAGE_DATA_WRITTEN)
	return nil
}

// Note: Status of SUCCEEDED can only be True
const CONDITION_TYPE_SUCCEEDED = "Succeeded"
const CONDITION_REASON_SUCCEEDED = "InstallSucceeded"
const CONDITION_MESSAGE_SUCCEEDED = "Application has been installed"

func addConditionSucceeded(controllerRuntimeClient client.Client, object client.Object) error {
	fmt.Println("Adding SUCCEEDED condition ...")
	//return utilities.AppendCondition(context.Background(), controllerRuntimeClient, object, CONDITION_TYPE_SUCCEEDED, CONDITION_STATUS_TRUE,
	//	CONDITION_REASON_SUCCEEDED, CONDITION_MESSAGE_SUCCEEDED)
	return nil
}
