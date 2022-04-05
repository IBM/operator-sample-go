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

```
$ export REGISTRY='docker.io'
$ export ORG='nheidloff'
$ export IMAGE='operator-database-backup:v1.0.0'
$ podman build -f Dockerfile -t operator-database-backup .
$ podman tag operator-database-backup:latest "$REGISTRY/$ORG/$IMAGE"
$ podman push "$REGISTRY/$ORG/$IMAGE"
```