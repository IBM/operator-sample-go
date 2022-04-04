# Database Operator Backup

```
$ git clone https://github.com/ibm/operator-sample-go.git
$ cd operator-database-backup
$ go run main.go
```

```
$ git clone https://github.com/ibm/operator-sample-go.git
$ cd operator-database-backup
$ podman build -f Dockerfile -t operator-database-backup .
$ podman run --rm operator-database-backup
```