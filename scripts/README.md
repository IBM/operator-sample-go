# Automation with scripts

The script automation does following.

* It ensure that with two `versions.env` file that the tagging is in an consitant way

* Resets the cluster environment

    * OLM installation
    * Cert manager installation
    * Prometheus installation
    * Clean the installed operators and application to that example

* Creates following containers:

    * Database operator related
        * `Database-service` (_quakus application_), a custom database which provides stateful sets
        * `operator-database` (operator), this operator creates an instance of the `Database-service`
        * `operator-database-backup`(_quarkus application_), this is an application which will be instantiated later from the  `operator-database` to create a backup on an object storage database
        * `operator-database-bundle`, that is a container image which will be created by the operator-sdk and will be used later inside the `operator-database-catalog` wihich is relevant for the `OLM` usage.
        * `operator-database-catalog`, that container image contains a reference to the `operator-database-bundle` and will be used in the context of `OLM`

    * Application operator related
        * `simple-microservice` (_quarkus application_), a simple microservice to display messages and runs as a stateless application
        * `operator-application-autoscaler`(_go application_), that application implements a cron job to manage the scaling for the instances of the `simple-microservice` which were created by `operator-application` operator.
        * `operator-application` (operator), this operator creates an instance of the `simple-microservice`
        * `operator-application-bundle`, that is a container image which will be created by the operator-sdk and will be used later inside the `operator-application-catalog` wihich is relevant for the `OLM` usage.
        * `operator-application-catalog`, that container image contains a reference to the `operator-application-bundle` and will be used in the context of `OLM`

* It ensures based on templates that the manual configuration for the `operator-application` and `operator-database` are right configured to be ready for OLM usage

* Resets the podman vm if needed 

### 1. Types of scripts

#### a.  **install-required**-xxx-components.sh

Installs the required components for Kubernetes or OpenShift.

| Component | Kubernetes | OpenShift **(not implemented yet)** |
| --- |  --- |  --- |
| CertManager | Yes |  Yes |
| OLM | Yes |  No |
| Prometheus Operator | Yes |  No |
| Prometheus Instance | Yes |  No |

`xxx == Kubernetes or OpenShift`

#### b. **demo**-xxx-yyyy.sh

Setup or delete based on the **golden source versions** (version.env).

`yyy == Kubernetes or OpenShift`
`xxx == delete or setup`

| Name | Kubernetes | OpenShift **(not implemented yet)** |
| --- |  --- |  --- |
| **demo**-setup-kubernetes.sh | Yes | No  |
| **demo**-delete-kubernetes.sh | Yes |  No |

#### c.  **ci**-www-xxx-yyy-zzz.sh

Creates all operators or specific operators of the project in Kubernetes or OpenShift.

* `www == create or delete`
* `xxx == operator or operators`
* `zzz == Kubernetes or OpenShift`

Here a list of the ci scripts

| Name | Kubernetes | OpenShift **(not implemented yet)** | Database Operator | Application Operator|
| --- |  --- |  --- |  --- |  --- |
| **ci**-create-operator-database-kubernetes.sh | Yes | No  | Yes  | No  |
| **ci**-create-operator-application-kubernetes.sh | Yes |  No | No  | Yes  |
| **ci**-create-operators-kubernetes.sh | Yes |  No | Yes  | Yes  |
| **ci**-delete-operators-kubernetes.sh | Yes (under construction) |  No | Yes  | Yes  |

#### d.   **delete-everything**-xxx

Deletes all depending on the Platfrom such as the operators, OLM, Prometheus or Cert-Manager.

* `xxx == Kubernetes or OpenShift`

### 2. Script parameters

#### a. ci-create-operators-kubernetes.sh

That scripts creates the operators in Kubernetes and has following parameter options.

* Kubernetes

| Parameter combination | versions.env  |  versions_local.env | delete all and setup prerequisites | `operator database` | `operator application` | reset podman |
| --- |  --- | --- | --- |  --- | --- | --- |
| `database` `local` |  no | yes | no | yes | no | no |
| `database` `local` `reset` |  no | yes |yes | yes | no | no |
| `database` `local` `reset` `podman_reset` |  no | yes |yes | yes | no | yes |
| `app` `local` |  no | yes | no | yes | yes | no |
| `app` `local` `reset` |  no | yes |yes | yes | yes | no |
| `app` `local` `reset` `podman_reset` |  no | yes |yes | yes | yes | yes |


* First parameter: ('database' or 'app')

    * Use 'database' for setup the database operator only
    * Use 'app' for setup the database and application operator.

* Second parameter: ('local' or 'ci')

    * Use 'local' for using the `versions_local.env` file as input for the container tags.

    * Use 'ci' for using the `versions.env` file as input for the container tags. **ONLY FOR GOLDEN SOURCE!**

* Third parameter: ('reset')

    * Use 'reset' to deinstall the operators and prereq.

* Fourth parameter: ('podman_reset')

    * Use 'podman_reset' to delete podman vm, create a new podman vm with size of 15, and start podman.


Example:

```sh
sh scripts/ci-create-operators-kubernetes.sh database local reset podman_reset
```


ç