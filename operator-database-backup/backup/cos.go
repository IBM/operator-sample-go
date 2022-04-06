package backup

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/IBM/ibm-cos-sdk-go/aws"
	"github.com/IBM/ibm-cos-sdk-go/aws/credentials"
	"github.com/IBM/ibm-cos-sdk-go/aws/session"
	"github.com/IBM/ibm-cos-sdk-go/service/s3"
)

func writeData(data string) error {
	currentTime := time.Now()
	bucketName := cosBucketNamePrefix + currentTime.Format("2006-01-02-15:04:05")
	bucketName = strings.Replace(bucketName, ":", "-", 3)
	fmt.Println("bucketName:")
	fmt.Println(bucketName)

	config := aws.NewConfig().
		WithEndpoint(cosServiceEndpoint).
		WithRegion(cosRegion).
		WithCredentials(credentials.NewStaticCredentials(cosHmacAccessKeyId, cosHmacSecretAccessKey, "")).
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
	ctx := context.Background()
	err := client.WaitUntilBucketExistsWithContext(ctx, &s3.HeadBucketInput{
		Bucket: aws.String(bucketName),
	})

	dataByteArray, err := json.MarshalIndent(data, "", "")
	if err != nil {
		return err
	}
	fileName := bucketName + ".json"
	err = ioutil.WriteFile(fileName, dataByteArray, 0644)
	if err != nil {
		return err
	}
	file, err := os.Open(fileName)
	if err != nil {
		return err
	}
	fileInfo, err := file.Stat()
	if err != nil {
		return err
	}
	reader := &CustomReader{
		fp:      file,
		size:    fileInfo.Size(),
		signMap: map[int64]struct{}{},
	}

	_, err = client.PutObjectWithContext(ctx, &s3.PutObjectInput{
		Bucket: aws.String(bucketName),
		Key:    aws.String(bucketName),
		Body:   reader,
	})
	if err != nil {
		return err
	}

	bucketList, _ := client.ListBuckets(&s3.ListBucketsInput{})
	fmt.Println("bucketList:")
	fmt.Println(bucketList)

	return nil
}

// Note: From https://github.com/IBM/ibm-cos-sdk-go/blob/master/example/service/s3/putObjectWithProcess/putObjWithProcess.go
type CustomReader struct {
	fp      *os.File
	size    int64
	read    int64
	signMap map[int64]struct{}
	mux     sync.Mutex
}

func (r *CustomReader) Read(p []byte) (int, error) {
	return r.fp.Read(p)
}

func (r *CustomReader) ReadAt(p []byte, off int64) (int, error) {
	n, err := r.fp.ReadAt(p, off)
	if err != nil {
		return n, err
	}

	r.mux.Lock()
	// Ignore the first signature call
	if _, ok := r.signMap[off]; ok {
		// Got the length have read( or means has uploaded), and you can construct your message
		r.read += int64(n)
		fmt.Printf("\rtotal read:%d    progress:%d%%", r.read, int(float32(r.read*100)/float32(r.size)))
	} else {
		r.signMap[off] = struct{}{}
	}
	r.mux.Unlock()
	return n, err
}

func (r *CustomReader) Seek(offset int64, whence int) (int64, error) {
	return r.fp.Seek(offset, whence)
}
