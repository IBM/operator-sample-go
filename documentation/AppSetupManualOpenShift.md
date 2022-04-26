# Application Operator - Setup and manual Deployment on OpenShift

Follow the [Kubernetes instructions](AppSetupManual.md)! They are identical to OpenShift, except the configuration of Prometheus.

### Prometheus Metrics

```
$ oc label namespace application-beta openshift.io/cluster-monitoring="true"
$ kubectl apply -f prometheus
TODO: same for operator-application
```
