# Development Commands

Commands for the project creation:

```
$ operator-sdk init --domain ibm.com --repo github.com/nheidloff/operator-sample-go/operator-application
$ operator-sdk create api --group application.sample --version v1alpha1 --kind Application --resource --controller
$ make generate manifests
```

Commands for the webhook creations:

```
$ operator-sdk create webhook --group application.sample --version v1alpha1 --kind Application --defaulting --programmatic-validation --conversion
$ make generate manifests
$ make install run ENABLE_WEBHOOKS=false
```