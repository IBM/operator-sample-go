# Database Operator Backup

To run this application, you need [IBM Cloud Object Storage](https://cloud.ibm.com/docs/cloud-object-storage) which is accessed via S3 APIs. After you have created the object storage instance, you need to get the HMAC access key id, secret access key API key, region and service endpoint. When you create the credentials, make sure you select 'Writer' and 'HMAC' (see [documentation](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-uhc-hmac-credentials-main)).

To run the Go backup application locally, run these commands:

```
$ git clone https://github.com/ibm/operator-sample-go.git
$ cd operator-database-backup
$ export BACKUP_RESOURCE_NAME=databasebackup-manual
$ export NAMESPACE=database
$ export CLOUD_OBJECT_STORAGE_HMAC_ACCESS_KEY_ID="xxx"
$ export CLOUD_OBJECT_STORAGE_HMAC_SECRET_ACCESS_KEY="xxx"
$ export CLOUD_OBJECT_STORAGE_REGION="eu-geo"
$ export CLOUD_OBJECT_STORAGE_SERVICE_ENDPOINT="s3.eu.cloud-object-storage.appdomain.cloud"
$ go run main.go
```

To debug, add the API key and the instance id to launch.json.

To deploy the backup application as Kubernetes job, build and push the image and change the reference in kubernetes/job.yaml:

```
$ cd operator-database-backup
$ code ../versions.env
$ source ../versions.env
$ podman build -f Dockerfile -t "$REGISTRY/$ORG/$IMAGE_DATABASE_BACKUP" .
$ podman push "$REGISTRY/$ORG/$IMAGE_DATABASE_BACKUP"
```

Run backup application manually via CronJob:

Update your credentials and the image version in cronjob.yaml first. Additionally you need to deploy the [database-service](https://github.com/IBM/operator-sample-go/blob/main/database-service/README.md#getting-started).

```
$ kubectl apply -f ../operator-database/config/samples/database.sample_v1alpha1_databasebackup.yaml
$ kubectl apply -f kubernetes/role.yaml
$ kubectl apply -f kubernetes/cronjob.yaml
$ kubectl create job --from=cronjob/database-backup manuallytriggered -n database
$ kubectl get databasebackups databasebackup-manual -n database -oyaml
$ kubectl logs -n database $(kubectl get pods -n database | awk '/manuallytriggered/ {print $1;exit}')
```
