# Enable Prometheus Metering

## Step 1-Deploy Prometheus on your cluster

There are several ways to deploy a Prometheus instance on cluster. The easiest way is to use either Helm charts, or through the Prometheus operator which is available on “operatorhub.io”. We use the latter method as we believe that this is the best way to provide a whole life-cycle management to any application on Kubernetes based clusters.

The installation through the operator hub is quite straightforward;

1. Go to https://operatorhub.io/
2. Search for Prometheus
3. Click on “Prometheus Operator”
4. Then click on “Install” button and follow the instructions.
5. In brief what you need to do is to open a terminal command line and connect to your cluster beforehand, then;

```
bash -s v0.20.0kubectl create -f https://operatorhub.io/install/prometheus.yaml
```

## Step 2-Make the Prometheus UI accessible on the cluster

You need also enable the Prometheus UI to be accessible either through a “LoadBalancer” or “NodePort” on your Kubernetes cluster.

1-First create a “namespace” (or project under “OpenShift”) with any name you want to use;

```shell
$ kubectl create namespace monitoring
```

2-Create a “ServiceAccount” YAML file and insert following code (this Yaml file is also provided as a sample in ../operator-application/config/prometheus/1-ServiceAccount.yaml)

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus
```

```shell
$ kubectl apply -f myserviceaccount.yaml -n monitoring
or if you are already in the /operator-application/ folder
$ kubectl apply -f  /config/prometheus/1-ServiceAccount.yaml -n monitoring
```

2-Create a “ClusterRole” YAML file as shown below;

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus
rules:
- apiGroups: [""]
  resources:
  - nodes
  - nodes/metrics
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources:
  - configmaps
  verbs: ["get"]
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  verbs: ["get", "list", "watch"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
```

```shell
$ kubectl apply -f myclusterrole.yaml -n monitoring
or 
$ kubectl apply -f  /config/prometheus/2-ClusterRole.yaml -n monitoring
```

3-Create a “ClusterRoleBinding” YAML file as shown below;

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: monitoring
kubectl apply -f myclusterrolebinding.yaml -n monitoring
```

```shell
$ kubectl apply -f myclusterrolebinding.yaml -n monitoring
or
$ kubectl apply -f  /config/prometheus/3-ClusterRoleBinding.yaml -n monitoring
```

4-Build an instance of your Prometheus service;

```yaml
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: prometheus
spec:
  serviceAccountName: prometheus
  serviceMonitorSelector: {}
  serviceMonitorNamespaceSelector: {}
  resources:
    requests:
      memory: 400Mi
  enableAdminAPI: true
kubectl apply -f myprometheusinstance.yaml -n monitoring
```

```shell
$ kubectl apply -f myprometheusinstance.yaml -n monitoring
or 
$ kubectl apply -f  /config/prometheus/4-PrometheusService.yaml -n monitoring
```

**Note**: **Those {} in the YAML file are very important! The reason is that with enabling this “wildcard” feature, your Prometheus would monitor “any” service, in any namespace**.

5-Expose your Prometheus service instance to the internet;

```yaml
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  annotations:
    service.kubernetes.io/ibm-load-balancer-cloud-provider-ip-type: "public"     
spec:
  type: LoadBalancer
  ports:
  - name: web
    port: 9090
    protocol: TCP
    targetPort: 9090
  selector:
    prometheus: prometheus
```

Above is a **“LoadBalancer”** exposure, and below a **“NodePort” **version;

```yaml
apiVersion: v1
kind: Service
metadata:
  name: prometheus
spec:
  type: NodePort
  ports:
  - name: web
    nodePort: 30901
    port: 9090
    protocol: TCP
    targetPort: web
  selector:
    prometheus: prometheus
```

In either ways, apply the configuration against your cluster;

```shell
$ kubectl apply -f myprometheusserviceexpose.yaml -n monitoring
or for a LoadBalancer
$ kubectl apply -f  /config/prometheus/5-ExposePrometheusServiceLoadBalancer.yaml -n monitoring
or for a NodePort
$ kubectl apply -f  /config/prometheus/6-ExposePrometheusNodePort.yaml -n monitoring
```



6-Also for the specific usage with an operator, there is a modification to be done in the “config/default/kustomize.yaml” file; search for “prometheus” and un-comment the line;

```yaml
From the original version# [PROMETHEUS] To enable prometheus monitor, uncomment all sections with 'PROMETHEUS'.
#- ../prometheus

To

# [PROMETHEUS] To enable prometheus monitor, uncomment all sections with 'PROMETHEUS'.
- ../prometheus
```