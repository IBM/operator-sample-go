# Setup and local Usage

Install [prerequistes](Prerequisites.md).

Get the code:

```
$ https://github.com/nheidloff/operator-sample-go.git
$ cd operator-application
$ code .
```

Login to Kubernetes:

```
$ ibmcloud login -a cloud.ibm.com -r eu-de -g resource-group-niklas-heidloff7 --sso
$ ibmcloud ks cluster config --cluster xxxxxxx
```

Create Database Resource:

```
$ kubectl apply -f ../operator-database/config/crd/bases/database.sample.third.party_databases.yaml
```

From a terminal in VSCode run these commands:

```
$ make install run ENABLE_WEBHOOKS=false
$ kubectl apply -f config/samples/application.sample_v1beta1_application.yaml
```

To debug, press F5 (Run - Start Debugging) instead of 'make install run'. The directory 'operator-application' needs to be root in VSCode.

The sample endpoint can be triggered via '<your-ip>:30548/hello':

```
$ ibmcloud ks worker ls --cluster niklas2-us-south-1-cx2.2x4
$ open http://159.122.86.194:30548/hello
```

All resources can be deleted:

```
$ kubectl delete -f config/samples/application.sample_v1beta1_application.yaml
$ make uninstall
```