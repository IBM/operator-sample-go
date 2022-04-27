
# Demonstration Script

Use this section as a guide to give a live demo of the operator-sample-go asset on OpenShift.  The following topics are included:

* OpenShift OperatorHub and OLM
* Deployment via OperatorHub
* Auto backup
* Auto scalability and Metrics

## Setup

* First install the [prerequistes](Prerequisites.md)
* Follow the instructions for [installing the application operator with OLM]()
* Follow the instructions for [installing the database operator with OLM]()

**Note that after following the install setps, you will need to reverse some of the deployment steps as they are intended to be performed live in the demo script below.**

* Uninstall both operators (but leave Catalog sources)
* Delete application and database namespaces
* Delete all CR instances (Application, Database, Databasecluster, Databasebackup)

## OpenShift OperatorHub and OLM

Once you’ve created an operator for your Kubernetes solution, you’ll need a way to version, package and distribute the operator to your customers, making it easy for their administrators to discover and install the operator, to manage your solution’s workload.

Kubernetes includes an Operator Lifecycle Manager component which is used extensively by OpenShift to manage its own operators, and you can use it to manage your custom operator(s).  In the OpenShift UI console, you’ll find the OperatorHub.

<img src="images/demo1.png" />

Each tile represents an operator which are visible in the UI of the thousands of OpenShift clusters, used by enterprises worldwide.  Currently, there are around 400 operators from RedHat, IBM and other ISVs and you can filter the operators in various ways.  The OperatorHub collates its contents from various sources (known as Catalogs).

<img src="images/demo2.png" />

* Red Hat Operators - Red Hat products packaged and shipped by Red Hat.

* Certified Operators - Products from leading independent software vendors (ISVs), and there is a simple process with RedHat to verify the operator and solution meet their quality criteria.  

* Red Hat Marketplace – these are certified operators that are available to purchase via the Red Hat marketplace.

* Community Operators – these are open source operators from a specific github repo, into which it is very easy to add content.  These community operators also appear in another marketplace called OperatorHub.io.  Although this has a similar name to the OperatorHub in OpenShift, it’s a separate marketplace aimed at any Kubernetes platform.

It’s also possible to create your own catalog sources to represent all your operators if you have multiple solutions.  As you can see, in my cluster I have two custom catalog sources for some operators we have created as examples, one source contains apps the other a simple database, which I’ll show in a moment.  

IBM takes a similar catalog approach with its Cloud Paks software.  But first, let’s look at the purchasing experience for a commercial offering from CrunchyData.

<img src="images/demo3.png" />

If I wanted to purchase Crunchy Postgres, I simply locate it in the OperatorHub and click the button to either Install or Purchase.  The fact that I can install without entitlement suggests there is a free trial available, which you can verify if you click Purchase, which directs you to the Red Hat Marketplace which can process transactions or look at the free trial terms.

<img src="images/demo4.png" />

Returning to OperatorHub in OpenShift, let’s see what happens if we install this operator.

<img src="images/demo5.png" />

Here you can see the options to install the operator which can install and manage the Crunchy Postgres solution.  It’s very simple, and you only need to choose a namespace and decide if you want your cluster to automatically approve & install updates to the operator as they are published by the publisher.  

Remember, the operator doesn’t install the Crunchy Postgres database, it just deploys a container in which the operator is running.  The operator will spring into life when the administrator creates a custom resource on the cluster, just like you would for any standard Kubernetes resources like pods, or secrets etc.  

Let’s hold off on installing this commercial offering, and now work with a sample operator we created, which is responsible for deploying and managing our simple database.

## Deployment via OperatorHub

Before we install it with OLM, it’s important to understand how the packaging works.  To have your own operator included in any of the catalog sources we have looked at, it needs to be packaged according to the requirements of the Operator Lifecycle Manager, which in simplified terms looks like this:

<img src="images/demo6.png" />

The bundle is a collection of files which includes a resource definition called a ClusterServiceVersion which describes the operator and where to find it in a registry, the manifests to create the CRDs the operator manages, and any dependencies such as other operators.  From the bundle, you must create a Dockerfile to build a minimal container containing the files, which is pushed to a registry.  Finally, you must create another container called the index image.  The existing (or additional/new) catalog sources derive their content from index images, as they provide an API which publishes the details of your bundle.  

If this all sounds a bit complicated, this is of course IBM Build Labs help you.  In addition, we use an open source tool called operator-sdk which not only helps to scaffold operators in Go (and other languages), but also helps automate these packaging steps too.

Once you have these packaging artifacts, what you do next depends on which catalog you want your operator to appear in, e.g. for RHM you would work with RedHat, for a community operator you would create a pull request and commit your bundle to the relevant open source repo, or you could simply provide the packaging artifacts directly to your customers (as I have done in this cluster)

I have already created the Catalog Sources, and the bundle, catalog and operator are in my dockerhub registry.  Therefore we we have a couple of operators ready to install.  

Let’s do that via the UI now (of course everything can be done via command line too), then I’ll explain what these operators deploy and manage.

<img src="images/demo7.png" />

<img src="images/demo8.png" />

<img src="images/demo9.png" />

<img src="images/demo10.png" />

After initiating the install, the operators are deployed as containers from the registry defined in the bundle that the catalog feeds from.  So, what have we deployed?  Notice that each operator provides a number of APIs – these are custom extensions to the Kubernetes API, i.e. CRDs.

The database operator provides three APIs:

* The Cluster API/CRD allows for creating a ‘cluster’ of pods which simulate a typical database.  Each pod is managed by a stateful set, has some storage, and provides some APIs.  The database pods communicate with each other to establish one leader, to which data can be written and multiple followers/replicas which replicate the data for high availability. The database itself is just a sample, when called by an API, it writes a single json file to its associated persistent storage.

* The Database API/CRD instructs the database cluster to create a ‘database schema’, populated by the specified SQL file.  A real database may have other ways to create the schema.

* The Backup API/CRD is used to automate the day 2 operation of triggering a manual or scheduled backup of the data, to cloud object storage.  The operator encapsulates all the relevant know how to perform backups in a consistent and repeatable way. 

The application operator supports one API:

* The Application API/CRD creates a frontend web application by creating Kubernetes resources like secrets and deployments, and in addition, it uses the custom resources I just spoke about to create a ‘database schema’ (NB. It doesn't actually do this but this was the intention for this CR.  For now, the database is currently hardcoded with its data).  It’s even smart enough to know if that custom Database API/CRD has been installed to the cluster and will keep retrying until this dependency is satisfied.

Let’s try it.  To make the operators spring into life, we need to create some resources with a ‘kind’ that correlates to the CRD definitions the operators have already installed to the cluster.  These resources can be created manually via the operator’s UI, or you can create from a yaml file as most Kubernetes administrators would do.  Let’s apply the following yamls:

* A namespace for the database cluster & the web application:

```
cat <<EOF | oc apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: database
---
apiVersion: v1
kind: Namespace
metadata:
  name: application-beta
EOF
```

* The database cluster itself.  Note the kind is a custom resource, defined by our Database operator, and the fields are specific to our database application.  We don’t need to create lots of kuberenetes resources ourselves, the DatabaseCluster kind provides an abstraction.  We only need to give the database cluster a name, and define how many pods we want (1 leader, 2 followers in this case):

```
cat <<EOF | oc apply -f -
apiVersion: database.sample.third.party/v1alpha1
kind: DatabaseCluster
metadata:
  name: databasecluster-sample
  namespace: database
spec:
  amountPods: 3
EOF
```

* Finally, we can use the custom resource to create the frontend application.  Again, it provides an abstraction, and it will take care of creating Kuberenetes resources to deploy a web app pod (providing a single API endpoint), and even use the database CR to create some data in our database cluster.

```
cat <<EOF | oc apply -f -
apiVersion: application.sample.ibm.com/v1beta1
kind: Application
metadata:
  name: application
  namespace: application-beta
spec:
  version: "1.0.0"
  amountPods: 1
  databaseName: database
  databaseNamespace: database
  title: people
EOF
```

Now we have a database cluster, a database, and a front end microservice.  Let’s test the database by calling its endpoint to return the data (from within the container's terminal as the endpoint is not externally exposed):

```
curl -s http://localhost:8089/persons
```

<img src="images/demo11.png" />


## Auto backup

What if we wanted to use an operator to automate the day 2 task of scheduling a backup, to copy the current data to Cloud Object Storage?  Instead of creating a script or runbook to be executed by a human, we can create a backup CR, which the database operator will process by creating a cron job which launches another ‘backup’ container on a schedule.  The backup container reads from the database cluster, connects to cloud object storage and performs the backup.  Let’s create the backup CR.  As you can see, it has optional properties to create either a manual backup, or create a scheduled backup, putting the data in the list of repos (COS in this case).

```
cat <<EOF | oc apply -f -
apiVersion: database.sample.third.party/v1alpha1
kind: DatabaseBackup
metadata:
  name: databasebackup-manual
  namespace: database
spec:
  repos:
  - name: ibmcos-repo
    type: ibmcos
    secretName: ibmcos-repo
    serviceEndpoint: s3.eu.cloud-object-storage.appdomain.cloud
    cosRegion: eu-geo
    bucketNamePrefix: "database-backup-"
  manualTrigger:
    time: "2022-04-20T02:59:43.1Z"
    repo: ibmcos-repo
  scheduledTrigger:
    schedule: "*/3 * * * *"
    repo: ibmcos-repo
EOF
```

Once the CR has been processed by the operator, you’ll see it created a CronJob which launches a Job (a pod which runs to completion), every three minutes.

<img src="images/demo12.png" />

And if you look at the Jobs this CronJob creates, it launches container which calls our databases and backups the data to COS.

<img src="images/demo13.png" />

To prove it really works, you can even see the data in COS.

<img src="images/demo14.png" />

The data can be downloaded.

<img src="images/demo15.png" />


## Auto scalability and Metrics

Work in progress
