package backup

import (
	"context"
	"fmt"
	"os"
	"time"

	"github.com/IBM/ibm-cos-sdk-go/aws"
	"github.com/IBM/ibm-cos-sdk-go/aws/credentials/ibmiam"
	"github.com/IBM/ibm-cos-sdk-go/aws/session"
	"github.com/IBM/ibm-cos-sdk-go/service/s3"
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

	// no environment variables
	ctx context.Context
)

func Run() {
	fmt.Println("Start backup.Run()")

	currentTime := time.Now()
	bucketName := cosBucketNamePrefix + currentTime.Format("2006-01-02-15:04:05")
	fmt.Println("bucketName:")
	fmt.Println(bucketName)

	if len(backupResourceName) < 1 {
		exitWithErrorCondition(backupResourceName)
	}
	if len(namespace) < 1 {
		exitWithErrorCondition(namespace)
	}
	if len(cosAPIKey) < 1 {
		exitWithErrorCondition(CONDITION_TYPE_COS_API_KEY_DEFINED)
	}
	if len(cosServiceInstanceId) < 1 {
		exitWithErrorCondition(cosServiceInstanceId)
	}

	//getBackupResource(BACKUP_RESOURCE_NAME, NAMESPACE)

	config := aws.NewConfig().
		WithEndpoint(cosServiceEndpoint).
		WithCredentials(ibmiam.NewStaticCredentials(aws.NewConfig(), cosAuthEndpoint, cosAPIKey, cosServiceInstanceId)).
		WithS3ForcePathStyle(true)

	session := session.Must(session.NewSession())
	client := s3.New(session, config)

	/*
		input := &s3.CreateBucketInput{
			Bucket: aws.String(newBucket),
		}

		_, error := client.CreateBucket(input)
		if error != nil {
			fmt.Println(error)
		}
	*/

	bucketList, _ := client.ListBuckets(&s3.ListBucketsInput{})
	fmt.Println("bucketList:")
	fmt.Println(bucketList)
}

func exitWithErrorCondition(conditionType string) {
	var controllerRuntimeClient client.Client
	var object client.Object
	switch conditionType {
	case CONDITION_TYPE_COS_API_KEY_DEFINED:
		setConditionCOSAPIKeyNotDefined(controllerRuntimeClient, object)
	case CONDITION_TYPE_COS_SERVICE_INSTANCE_ID_DEFINED:
		setConditionCOSServiceInstanceIdNotDefined(controllerRuntimeClient, object)
	}

	os.Exit(1)
}
