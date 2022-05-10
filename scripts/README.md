# Automation with scripts

### 1. Types of scripts

#### a.  **install-required**-xxx-components.sh

Installs the required components for 

`xxx == Kubernetes or OpenShift`

#### b. **demo**-xxx-yyyy.sh

Setup or delete based on the golden source versions.

`yyy == Kubernetes or OpenShift`

`xxx == delete or setup`

#### c.  **ci**-www-xxx-yyy-zzz.sh

Creates all operators or specific operators of the project in Kubernetes or OpenShift.

* `www == create or delete`
* `xxx == operator or operators`
* `zzz == Kubernetes or OpenShift`

#### d.   **delete-everything**xxx

Deletes all depending on the Platfrom such as the operators, OLM, Prometheus or Cert-Manager.

* `xxx == Kubernetes or OpenShift`

### 2. Script parameters

#### a. ci-create-operators-kubernetes.sh

That scripts creates the operators in Kubernetes and has following parameter options.

* First parameter:

    * Use 'database' for setup the database operator only
    * Use 'app' for setup the database and application operator.

* Second parameter:

    * Use 'local' for using the `versions_local.env` file as input for the container tags.

    * Use 'ci' for using the `versions.env` file as input for the container tags. **ONLY FOR GOLDEN SOURCE!**

* Third parameter:

    * Use 'reset' to deinstall the operators and prereq.

* Fourth parameter:

    * Use 'podman-reset' to delete podman vm, create a new podman vm with size of 15, and start podman.


Example:

```sh
sh scripts/ci-create-operators-kubernetes.sh database local reset podman-reset
```


