# Database Operator - Setup and local Usage

First install [prerequistes](Prerequisites.md)!

### Navigate to operator-database

```
$ cd operator-database
```

### Run operator locally

From a terminal run this command:

```
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
