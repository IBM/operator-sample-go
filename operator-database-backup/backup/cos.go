package backup

import (
	"fmt"
	"strings"
	"time"

	"github.com/IBM/ibm-cos-sdk-go/aws"
	"github.com/IBM/ibm-cos-sdk-go/aws/credentials/ibmiam"
	"github.com/IBM/ibm-cos-sdk-go/aws/session"
	"github.com/IBM/ibm-cos-sdk-go/service/s3"
)

func writedata() error {
	currentTime := time.Now()
	bucketName := cosBucketNamePrefix + currentTime.Format("2006-01-02-15:04:05")
	bucketName = strings.Replace(bucketName, ":", "-", 3)
	fmt.Println("bucketName:")
	fmt.Println(bucketName)

	config := aws.NewConfig().
		WithEndpoint(cosServiceEndpoint).
		WithCredentials(ibmiam.NewStaticCredentials(aws.NewConfig(), cosAuthEndpoint, cosAPIKey, cosServiceInstanceId)).
		WithS3ForcePathStyle(true)
	session := session.Must(session.NewSession())
	client := s3.New(session, config)

	input := &s3.CreateBucketInput{
		Bucket: aws.String(bucketName),
	}
	_, error := client.CreateBucket(input)
	if error != nil {
		return error
	}

	// TODO: upload file

	return nil
}
