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
- in configure your resource section enter <br/>
  a. Enter Service Name <br/>
  b. Select a Resource Group <br/>
  c. enter Tags as requied <br/>
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


## Adding the Credentials in Secret YAML (For Auto Backup)

to configure the cron job for Auto Backup of Database to IBM Cloud Object Storage within Operator we need to put credentials in a [secret.yaml](https://github.com/IBM/operator-sample-go/blob/main/operator-database-backup/kubernetes/secret.yaml) file

change the following lines at Number 8 and 9 respectively:

```sh
  HmacAccessKeyId: "ADD access_key_id from Credential JSON"
  HmacSecretAccessKey: "ADD ecret_access_key from Credential JSON"
```


now apply the secret file 

```ssh
cd operator-database-backup
kubectl apply -f kubernetes/secret.yaml
```

