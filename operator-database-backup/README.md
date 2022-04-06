# Database Operator Backup

To run this application, you need [IBM Cloud Object Storage](https://cloud.ibm.com/docs/cloud-object-storage) which is accessed via S3 APIs. After you have created the object storage instance, you need to get the API key, instance id and endpoint.

To run the Go backup application locally, run these commands:

```
$ git clone https://github.com/ibm/operator-sample-go.git
$ cd operator-database-backup
$ export BACKUP_RESOURCE_NAME=databasebackup-manual
$ export NAMESPACE=database
$ export CLOUD_OBJECT_STORAGE_API_KEY="xxx"
$ export CLOUD_OBJECT_STORAGE_SERVICE_INSTANCE_ID="xxx"
$ export CLOUD_OBJECT_STORAGE_SERVICE_ENDPOINT="https://s3.fra.eu.cloud-object-storage.appdomain.cloud"
$ go run main.go
```

To debug, add the API key and the instance id to launch.json.

To deploy the backup application as Kubernetes job, build and push the image and change the reference in kubernetes/job.yaml:

```
$ export REGISTRY='docker.io'
$ export ORG='nheidloff'
$ export IMAGE_DATABASE_BACKUP='operator-database-backup:v1.0.4'
$ podman build -f Dockerfile -t operator-database-backup .
$ podman tag operator-database-backup:latest "$REGISTRY/$ORG/$IMAGE_DATABASE_BACKUP"
$ podman push "$REGISTRY/$ORG/$IMAGE_DATABASE_BACKUP"
```

Run backup application manually via CronJob:

Update your credentials in cronjob.yaml first. Additionally you need to deploy the [database-service](https://github.com/IBM/operator-sample-go/blob/main/database-service/README.md#getting-started).

```
$ kubectl apply -f ../operator-database/config/samples/database.sample_v1alpha1_databasebackup.yaml
$ kubectl apply -f kubernetes/role.yaml
$ kubectl apply -f kubernetes/cronjob.yaml
$ kubectl create job --from=cronjob/database-backup manuallytriggered -n database
$ kubectl get databasebackups databasebackup-manual -n database -oyaml
$ kubectl logs -n database $(kubectl get pods -n database | awk '/manuallytriggered/ {print $1;exit}')
```