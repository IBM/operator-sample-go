# Database Operator - Setup and local Usage

First install the [prerequistes](Prerequisites.md)!

### Run operator locally

From a terminal run this command:

```
$ cd operator-database
$ make install run
```

From a second terminal run this command:

```
$ kubectl apply -f config/samples/database.sample_v1alpha1_database.yaml
```

### Delete all resources

```
$ kubectl delete -f config/samples/database.sample_v1alpha1_database.yaml
$ make uninstall
```
