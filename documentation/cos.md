# Setup Cloud Object Storage

Cloud Object Storage (COS) stores encrypted and dispersed data across multiple geographic locations. [click for more info](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-getting-started-cloud-object-storage)

This guide indicates creating Object Storage on  [IBM Cloud](https://cloud.ibm.com/) only hence to start we need to have an account on [IBM Cloud](https://cloud.ibm.com/).
Once you are ready with your IBM Cloud Account:


- Login to your IBM Cloud Console
- Search for Object Storage in Search Bar **_OR_** Click on Catalog from Upper Navigation Menu, Choose Services in Type
- Click on the Object Storage 
- Once clicked a tab window will open of Cloud Ojbect Storage
- **IBM Cloud** will be selected by default
- Choose your pricing plan
- in configure your resource section enter
  a. Enter Service Name
  b. Select a Resource Group
  c. enter Tags as requied
- Click on Create

## Create Service Credentials

Service credentials are required in order start [Auto Backup](https://github.com/IBM/operator-sample-go/blob/main/documentation/demo.md#auto-backup) within Database Operator

to create a service credentials follow below instructions:
1. From the Left Navigation Menu Click on **Service Credentials**.
2. in the righ Middle Section click on **"New Credential"** Blue Button.
3. Enter the name of credentials.
4. Keep the Role to **"writer"**.
5. Click on **"Adavanced options"**.
6. Enable to the toggle to **"Include HMAC Credentials"**.
7. Click on **"Add"** Button.
8. Click on the **Arrow Down** before credential name to show the **ACCESS KEY ID** and  **SECRET ACCESS KEY** written in **JSON**.

## Selecting the Region and Endpoint

by default Global or region based on your location would be selected, to change it or show it:

1. From the Left Navigation Menu Click on **Endpoints**.
2. Select your region type from **Select resiliency** dropdown
3. Choose your **REGION NAME** and **ENDPOINT URL** will also be shown in front of Region.


## Export Credentials and Resource Name to Environment Variables (For Manual Backup)

to run [Database Operator Backup](https://github.com/IBM/operator-sample-go/tree/main/operator-database-backup) locally we need to have credentials details which we obtained from above step as environment variables.

Export Backup Resource Name and Namespace details to environment variables

```ssh
export BACKUP_RESOURCE_NAME=databasebackup-manual
export NAMESPACE=database
```
Now we need to export Access Key ID, Secret Access Key, Region and Service Endpoint URL
1. **CLOUD_OBJECT_STORAGE_HMAC_ACCESS_KEY_ID** is the **access_key_id** from Credentials JSON
2. **CLOUD_OBJECT_STORAGE_HMAC_SECRET_ACCESS_KEY** is the **secret_access_key** from Credentials JSON
3. **CLOUD_OBJECT_STORAGE_REGION** is the Region where you want to put in Backup. For demo purpose we are using **eu-geo**
4. **CLOUD_OBJECT_STORAGE_SERVICE_ENDPOINT** is the endpoint URL Obtained along with Region.

```ssh
export CLOUD_OBJECT_STORAGE_HMAC_ACCESS_KEY_ID="xxx"
export CLOUD_OBJECT_STORAGE_HMAC_SECRET_ACCESS_KEY="xxx"
export CLOUD_OBJECT_STORAGE_REGION="eu-geo"
export CLOUD_OBJECT_STORAGE_SERVICE_ENDPOINT="s3.eu.cloud-object-storage.appdomain.cloud"
```

## Adding the Credentials in Secret YAML (For Auto Backup)

to configure the cron job for Auto Backup of Database to IBM Cloud Object Storage within Operator we need to put credentials in a [secret.yaml](https://github.com/IBM/operator-sample-go/blob/main/operator-database-backup/kubernetes/secret.yaml) file

change the following lines at Number 8 and 9 respectively:

```sh
  HmacAccessKeyId: "ADD access_key_id from Credential JSON"
  HmacSecretAccessKey: "ADD ecret_access_key from Credential JSON"
```


## Add the CRON JOB and CR of Database Backup

After updating credentials in secret.yml we need to add CRD for Database Backup which will create CRONJOB in the database namesapce and starting taking backup as cron mentioned in this file:

```sh
cd operator-database
kubectl apply -f config/samples/database.sample_v1alpha1_databasebackup.yaml
```

more details on this [CR](https://github.com/IBM/operator-sample-go/blob/main/documentation/demo.md#auto-backup)
### Verify the Database Backups created in the Cloud Object Stroage 

- Login to your IBM Cloud Console
- Go to Cloud Object Storage
- Select your Cloud Object Storage created in  [Setup Cloud Object Storage]()
- in the Bucket List you will see the backups created with interval defined in Cron Job


