# Database Operator - Setup and local Usage

🔴 IMPORTANT: First install the [prerequistes](Prerequisites.md)! If you don't do it, it won't work :)

### Run operator locally

From a terminal run this command:

```shell
$ cd operator-database
$ make install run
```

From a second terminal run this command:

```shell
$ kubectl apply -f config/samples/database.sample_v1alpha1_database.yaml
$ kubectl apply -f config/samples/database.sample_v1alpha1_databasecluster
```

### Delete all resources

```shell
$ kubectl delete -f config/samples/database.sample_v1alpha1_databasecluster.yaml
$ kubectl delete -f config/samples/database.sample_v1alpha1_database.yaml
$ make uninstall
```
