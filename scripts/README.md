# Automation with scripts

> 🔴 IMPORTANT: **Don't commit any changes made by the script automation to the repository!** Only the persons who are responsible for the **golden source** are allowed to do that!

The documentation is structured in following sections.

1. Technical environment
2. The script automation
3. Types of scripts
4. Script parameters

### 1. Technical environment

> 🔴 IMPORTANT: [opm](https://github.com/operator-framework/operator-registry/blob/master/docs/design/opm-tooling.md#opm) installation please read the [blog post](https://suedbroecker.net/2022/04/28/make-generate-error-127/) or just copy the `bin` folder of an **existing project** `Operator SDK` project to the **cloned github project** directory.

All local installation versions are related to macOS.

| Tools or framework | Version |  (G)obal, (L) ocal or (C)loud installed | Tested |
| --- | --- | --- |  --- |
| [Podman](https://podman.io/) Client / Server | 4.1.0 / 4.3.0 | G | OK |
| [Operator SDK](https://sdk.operatorframework.io/) | v1.18.0  | G | OK |
| [Operator SDK](https://sdk.operatorframework.io/) | v1.18.1  | G | OK |
| [Operator SDK](https://sdk.operatorframework.io/) | v1.19.1  | G | OK |
| Go | go1.17.6 | G | OK |
| Kubernetes cluster (VPC) | 1.23.6_1527 | C | OK |
| kubectl client | 1.23 | L | OK |
| kubectl server | v1.23.6+IKS | C | OK |
| operator-database/bin/[opm](https://github.com/operator-framework/operator-registry/blob/master/docs/design/opm-tooling.md#opm) | v1.21.0 | L | OK |
| operator-application/bin/[opm](https://github.com/operator-framework/operator-registry/blob/master/docs/design/opm-tooling.md#opm) | v1.21.0 | L | OK |
| bash | GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin21)  | L | OK |
| sed | 12.3.1 | L | OK |
| awk | awk version 20200816 | L | OK |
| macOS | 12.3.1 | L | OK |

### 2. The script automation

The script automation does following. 

> The functionality has variations depending on the script you are going to use.

1. It ensures that with two `versions.env` files that the tagging for the container images is in a consistent way.
  
  *  `versions.env` for **golden sources**
  *  `versions_local.env` for **custom local configurations**

2. It creates a temp `github tag` related to the last commit **before** the automation was started

3. It creates a `script-automation.log` file which will not be load to the git repo.

4. Resets the cluster environment

    * OLM installation
    * Cert manager installation
    * Prometheus installation
    * Clean the installed operators and application to that example

5. Creates following containers:

    * Database operator related
        * `Database-service` (_quarkus application_), a custom database which provides stateful sets
        * `operator-database` (operator), this operator creates an instance of the `Database-service`
        * `operator-database-backup`(_quarkus application_), this is an application which will be instantiated later from the  `operator-database` to create a backup on an object storage database
        * `operator-database-bundle`, that is a container image which will be created by the operator-sdk and will be used later inside the `operator-database-catalog` which is relevant for the `OLM` usage.
        * `operator-database-catalog`, that container image contains a reference to the `operator-database-bundle` and will be used in the context of `OLM`

    * Application operator related
        * `simple-microservice` (_quarkus application_), a simple microservice to display messages and runs as a stateless application
        * `operator-application-autoscaler`(_go application_), that application implements a cron job to manage the scaling for the instances of the `simple-microservice` which were created by `operator-application` operator.
        * `operator-application` (operator), this operator creates an instance of the `simple-microservice`
        * `operator-application-bundle`, that is a container image which will be created by the operator-sdk and will be used later inside the `operator-application-catalog` which is relevant for the `OLM` usage.
        * `operator-application-catalog`, that container image contains a reference to the `operator-application-bundle` and will be used in the context of `OLM`

6. It ensures based on templates that the manual configuration for the `operator-application` and `operator-database` are right configured to be ready for OLM usage

7. Resets the podman vm if needed.

8. It creates `role.yaml`, `role-binding.yaml`, `clusterserviceversion.yaml` and sample custom resources for the given operators, based on templates.

### 3. Types of scripts

There are four major types of scripts:

* **install-required**
* **demo**
* **ci**
* **delete**

#### a.  **install-required**-xxx-components.sh

* Definition: 
`xxx == Kubernetes or OpenShift`

* Table overview:

Installs the required components for Kubernetes or OpenShift.

| Component | Kubernetes | OpenShift **(not implemented yet)** |
| --- |  --- |  --- |
| CertManager | Yes |  Yes |
| OLM | Yes |  No |
| Prometheus Operator | Yes |  No |
| Prometheus Instance | Yes |  No |



#### b. **demo**-xxx-yyyy.sh

Setup or delete based on the **golden source versions** (version.env).

* Definition: 

`yyy == Kubernetes or OpenShift`
`xxx == delete or setup`

* Table overview:

| Name | Kubernetes | OpenShift **(not implemented yet)** |
| --- |  --- |  --- |
| **demo**-setup-kubernetes.sh | Yes | No  |
| **demo**-delete-kubernetes.sh | Yes |  No |

#### c.  **ci**-www-xxx-yyy-zzz.sh

* Definition: 

Creates all operators or specific operators of the project in Kubernetes or OpenShift.

* `www == create or delete`
* `xxx == operator or operators`
* `zzz == Kubernetes or OpenShift`

* Table overview:

Here is a list of available ci scripts.

| Name | Kubernetes | OpenShift **(not implemented yet)** | Creates Database Operator | Creates Application Operator|
| --- |  --- |  --- |  --- |  --- |
| **ci**-create-operator-database-kubernetes.sh | Yes | No  | Yes  | No  |
| **ci**-create-operator-application-kubernetes.sh | Yes |  No | No  | Yes  |
| **ci**-create-operators-kubernetes.sh | Yes |  No | Yes  | Yes  |
| **ci**-delete-operators-kubernetes.sh | Yes (under construction) |  No | Yes  | Yes  |

#### d.   **delete-everything**-xxx

Deletes all depending on the Platfrom such as the operators, OLM, Prometheus or Cert-Manager.

* `xxx == Kubernetes or OpenShift`

### 4. Script parameters

> 🔴 IMPORTANT: The order of the parameters is hard coded!

#### a. ci-create-operators-kubernetes.sh

That scripts creates the operators in Kubernetes and has following parameter options.

* Kubernetes

| Parameter combination | versions.env  |  versions_local.env | delete all and setup prerequisites | creates `operator database` | creates `operator application` | reset podman |
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


#### Example invokation:

* `database` - The script does create all container images related to the `database-operator`
* `local` - The script uses `versions_local.env` as input for the environment variables.
* `reset` - Deletes all Kubernetes components related to the example: `olm`, `cert-manager`, `prometheus-operator`, `database-operator` and ` application-operator`
`podman_reset` - Reset the podman vm by deleting the default-vm and create one with the size of 15 gig and start podman.

```sh
sh scripts/ci-create-operators-kubernetes.sh database local reset podman_reset
```
