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

func setConditionCOSAPIKeyNotDefined(controllerRuntimeClient client.Client, object client.Object) error {
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
	fmt.Println("Adding COS_SERVICE_INSTANCE_ID condition ...")
	//return utilities.AppendCondition(context.Background(), controllerRuntimeClient, object, CONDITION_TYPE_COS_SERVICE_INSTANCE_ID_DEFINED, CONDITION_STATUS_FALSE,
	//	CONDITION_REASON_COS_API_KEY_DEFINED, CONDITION_MESSAGE_COS_API_KEY_DEFINED)
	return nil
}

// Note: Status of NAMESPACE_DEFINED can only be False; otherwise there is no condition
const CONDITION_TYPE_NAMESPACE_DEFINED = "NamespaceDefined"
const CONDITION_REASON_NAMESPACE_DEFINED = "NamespaceDefined"
const CONDITION_MESSAGE_NAMESPACE_DEFINED = "Namespace is not defined"

func setConditionNamespaceNotDefined(controllerRuntimeClient client.Client, object client.Object) error {
	fmt.Println("Adding Namespace condition ...")
	//return utilities.AppendCondition(context.Background(), controllerRuntimeClient, object, CONDITION_TYPE_NAMESPACE_NOT_DEFINED, CONDITION_STATUS_FALSE,
	//	CONDITION_REASON_NAMESPACE_NOT_DEFINED, CONDITION_MESSAGE_NAMESPACE_NOT_DEFINED)
	return nil
}

// Note: Status of BACKUP_RESOURCE_NAME_NOT_DEFINED can only be False; otherwise there is no condition
const CONDITION_TYPE_NAMESPACE_NOT_DEFINED = "NamespaceDefined"
const CONDITION_REASON_NAMESPACE_NOT_DEFINED = "NamespaceDefined"
const CONDITION_MESSAGE_NAMESPACE_NOT_DEFINED = "Namespace is not defined"

func setConditionNamespaceNotDefined(controllerRuntimeClient client.Client, object client.Object) error {
	fmt.Println("Adding Namespace condition ...")
	//return utilities.AppendCondition(context.Background(), controllerRuntimeClient, object, CONDITION_TYPE_NAMESPACE_NOT_DEFINED, CONDITION_STATUS_FALSE,
	//	CONDITION_REASON_NAMESPACE_NOT_DEFINED, CONDITION_MESSAGE_NAMESPACE_NOT_DEFINED)
	return nil
}
