# Development Commands

Commands for the project creation:

```
$ operator-sdk init --domain ibm.com --repo github.com/nheidloff/operator-sample-go/operator-application
$ operator-sdk create api --group application.sample --version v1alpha1 --kind Application --resource --controller
$ make generate
$ make manifests
```

Commands for the bundle creation:

```
$ make bundle IMG="$REGISTRY/$ORG/$IMAGE"
```

Commands for the webhook creations:

```
$ operator-sdk create webhook --group application.sample --version v1alpha1 --kind Application --defaulting --programmatic-validation --conversion
$ make manifests
$ make install
$ make run ENABLE_WEBHOOKS=false
```

Command for the catalog creation:

```
$ make catalog-build docker-push CATALOG_IMG="$REGISTRY/$ORG/$CATALOG_IMAGE" BUNDLE_IMGS="$REGISTRY/$ORG/$BUNDLE_IMAGE" IMG="$REGISTRY/$ORG/$CATALOG_IMAGE"
```