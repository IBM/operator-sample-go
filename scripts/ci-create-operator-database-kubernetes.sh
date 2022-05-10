#!/bin/bash

# **********************************************************************************
# Set global variables using parameters
# **********************************************************************************

echo "************************************"
echo " Display parameter"
echo "************************************"
echo ""
echo "Parameter count : $@"
echo "Parameter zero 'name of the script': $0"
echo "---------------------------------"
echo "CI Configuration         : $1"
echo "Reset                    : $2"
echo "Reset Podman             : $3"
echo "-----------------------------"

# **************** Global variables

ROOT_FOLDER=$(cd $(dirname $0); cd ..; pwd)
NAMESPACE=operators
export CI_CONFIG=$1
export RESET=$2
export RESET_PODMAN=$3
export VERSIONS_FILE=""
export DATABASE_TEMPLATE_FOLDER=$ROOT_FOLDER/scripts/database-operator-templates

# **********************************************************************************
# Functions
# **********************************************************************************

function setEnvironmentVariables () {
    
    if [[ $RESET_PODMAN == "podman_reset" ]] ; then
       echo "************************************"
       echo " Reset podman"
       echo "************************************"
       podman version
       podman machine stop
       podman machine list
       podman machine rm -f podman-machine-default
       podman machine init --disk-size 15
       podman machine start
    fi

    echo "************************************"
    echo " Check if podman is running"
    echo "************************************"
    podman images &> $ROOT_FOLDER/scripts/check_podman.log

    CHECK=$(cat $ROOT_FOLDER/scripts/check_podman.log | grep 'Cannot connect to Podman' | awk '{print $1;}')
    echo "*** Podman check: $CHECK"
    
    if [[ $CHECK == "Cannot" ]]; then
       echo "*** Podman is not running! The script ends here."
       rm -f $ROOT_FOLDER/scripts/check_podman.log
       exit 1
    fi

    if [[ $CI_CONFIG == "local" ]]; then
        echo "*** Set versions_local.env file a input"
        source $ROOT_FOLDER/versions_local.env
        rm -f $ROOT_FOLDER/scripts/check_podman.log
    elif [[ $CI_CONFIG == "ci" ]]; then
        echo "*** Set versions.env file a input"        
        source $ROOT_FOLDER/versions.env
        rm -f $ROOT_FOLDER/scripts/check_podman.log
    else 
        echo "*** Please select a valid option to run!"
        echo "*** Use 'local' for your local test."
        echo "*** Use 'ci' for your the ci test."
        echo "*** Example:"
        echo "*** sh ci-operators-kubernetes.sh local"
        exit 1
    fi
}

function resetAll () {

    if [[ $RESET == "reset" ]]; then
        echo "*** RESET Kubernetes environment!"
        echo "*** DELETE all Kubernetes compoments!"
        cd $ROOT_FOLDER/scripts
        bash $ROOT_FOLDER/scripts/delete-everything-kubernetes.sh
        
        echo "*** Install required Kubernetes compoments!"
        cd $ROOT_FOLDER/scripts
        bash $ROOT_FOLDER/scripts/install-required-kubernetes-components.sh
    fi
}

function verifyPreReqs () {
  
  max_retrys=2
  j=0
  array=("cert-manager-cainjector" "cert-manager-webhook")
  namespace=cert-manager
  export STATUS_SUCCESS="Running"
  for i in "${array[@]}"
    do 
        echo ""
        echo "------------------------------------------------------------------------"
        echo "Check $i"
        while :
        do
            FIND=$i
            ((j++))
            STATUS_CHECK=$(kubectl get pods -n $namespace | grep "$FIND" | awk '{print $3;}' | sed 's/"//g' | sed 's/,//g')
            echo "Status: $STATUS_CHECK"
            STATUS_VERIFICATION=$(echo "$STATUS_CHECK" | grep $STATUS_SUCCESS)
            if [ "$STATUS_VERIFICATION" = "$STATUS_SUCCESS" ]; then
                echo "$(date +'%F %H:%M:%S') Status: $FIND is Ready"
                echo "------------------------------------------------------------------------"
                break
            elif [[ $j -eq $max_retrys ]]; then
                echo "$(date +'%F %H:%M:%S') Please run `install-required-kubernetes-components.sh`first!"
                echo "$(date +'%F %H:%M:%S') Prereqs aren't ready!"
                echo "------------------------------------------------------------------------"
                break               
            else
                echo "$(date +'%F %H:%M:%S') Status: $FIND($STATUS_CHECK)"
                echo "------------------------------------------------------------------------"
            fi
            sleep 3
        done
    done 

  array=("catalog-operator" "olm-operator" "operatorhubio-catalog" )
  namespace=olm
  export STATUS_SUCCESS="Running"
  for i in "${array[@]}"
    do 
        echo ""
        echo "------------------------------------------------------------------------"
        echo "Check $i"
        while :
        do
            FIND=$i
            ((j++))
            STATUS_CHECK=$(kubectl get pods -n $namespace | grep "$FIND" | awk '{print $3;}' | sed 's/"//g' | sed 's/,//g')
            echo "Status: $STATUS_CHECK"
            STATUS_VERIFICATION=$(echo "$STATUS_CHECK" | grep $STATUS_SUCCESS)
            if [ "$STATUS_VERIFICATION" = "$STATUS_SUCCESS" ]; then
                echo "$(date +'%F %H:%M:%S') Status: $FIND is Ready"
                echo "------------------------------------------------------------------------"
                break
            elif [[ $j -eq $max_retrys ]]; then
                echo "$(date +'%F %H:%M:%S') Please run `install-required-kubernetes-components.sh`first!"
                echo "$(date +'%F %H:%M:%S') Prereqs aren't ready!"
                echo "------------------------------------------------------------------------"
                break               
            else
                echo "$(date +'%F %H:%M:%S') Status: $FIND($STATUS_CHECK)"
                echo "------------------------------------------------------------------------"
            fi
            sleep 3
        done
    done 

  array=("prometheus-operator" )
  namespace=monitoring
  export STATUS_SUCCESS="Running"
   for i in "${array[@]}"
    do 
        echo ""
        echo "------------------------------------------------------------------------"
        echo "Check $i"
        while :
        do
            FIND=$i
            ((j++))
            STATUS_CHECK=$(kubectl get pods -n $namespace | grep "$FIND" | awk '{print $3;}' | sed 's/"//g' | sed 's/,//g')
            echo "Status: $STATUS_CHECK"
            STATUS_VERIFICATION=$(echo "$STATUS_CHECK" | grep $STATUS_SUCCESS)
            if [ "$STATUS_VERIFICATION" = "$STATUS_SUCCESS" ]; then
                echo "$(date +'%F %H:%M:%S') Status: $FIND is Ready"
                echo "------------------------------------------------------------------------"
                break
            elif [[ $j -eq $max_retrys ]]; then
                echo "$(date +'%F %H:%M:%S') Please run `install-required-kubernetes-components.sh`first!"
                echo "$(date +'%F %H:%M:%S') Prereqs aren't ready!"
                echo "------------------------------------------------------------------------"
                break               
            else
                echo "$(date +'%F %H:%M:%S') Status: $FIND($STATUS_CHECK)"
                echo "------------------------------------------------------------------------"
            fi
            sleep 3
        done
    done 
}

function buildDatabaseService () {
    cd $ROOT_FOLDER/database-service
    podman build -t "$REGISTRY/$ORG/$IMAGE_DATABASE_SERVICE" .
    podman login $REGISTRY
    podman push "$REGISTRY/$ORG/$IMAGE_DATABASE_SERVICE"
}

function buildDatabaseBackup () {
    cd $ROOT_FOLDER/operator-database-backup
    podman build -t "$REGISTRY/$ORG/$IMAGE_DATABASE_BACKUP" .
    podman login $REGISTRY
    podman push "$REGISTRY/$ORG/$IMAGE_DATABASE_BACKUP"
}

function configureCRs_DatabaseOperator () {
    
    #Backup
    IMAGE_NAME="$REGISTRY/$ORG/$IMAGE_DATABASE_BACKUP"
    echo $IMAGE_NAME
    sed "s+DATABASE_BACKUP_IMAGE+$IMAGE_NAME+g" "$DATABASE_TEMPLATE_FOLDER/database.sample_v1alpha1_databasebackup-TEMPLATE.yaml" > "$ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasebackup.yaml"
    cat $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasebackup.yaml | grep "$IMAGE_DATABASE_BACKUP"
    IMAGE_NAME="$REGISTRY/$ORG/$IMAGE_DATABASE_SERVICE"
    
    #Cluster
    IMAGE_NAME="$REGISTRY/$ORG/$IMAGE_DATABASE_SERVICE" 
    echo $IMAGE_NAME
    sed "s+DATABASE_SERVICE_IMAGE+$IMAGE_NAME+g" $DATABASE_TEMPLATE_FOLDER/database.sample_v1alpha1_databasecluster-TEMPLATE.yaml > $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasecluster.yaml
    cat $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasebackup.yaml | grep "$IMAGE_DATABASE_BACKUP"
}

function buildDatabaseOperator () {
    cd $ROOT_FOLDER/operator-database
    make generate
    make manifests
    # Build container
    # make docker-build IMG="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"
    podman build -t "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR" .
    # Push container
    podman login $REGISTRY
    podman push "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"
}

function buildDatabaseOperatorBundle () {
    cd $ROOT_FOLDER/operator-database
    # Build bundle
    make bundle IMG="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"
    
    # Replace CSV and RBAC generate files with customized versions
    DATABASE_OPERATOR_IMAGE="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"
    sed "s+DATABASE_OPERATOR_IMAGE+$DATABASE_OPERATOR_IMAGE+g" $DATABASE_TEMPLATE_FOLDER/operator-database.clusterserviceversion-TEMPLATE.yaml $ROOT_FOLDER/operator-database/bundle/manifests/operator-database.clusterserviceversion.yaml > $ROOT_FOLDER/operator-database/bundle/manifests/operator-database.clusterserviceversion.yaml 
    OPERATOR_NAMESPACE=operators
    sed "s+OPERATOR_NAMESPACE+$OPERATOR_NAMESPACE+g" $DATABASE_TEMPLATE_FOLDER/operator-database-role_binding_patch_TEMPLATE.yaml > $ROOT_FOLDER/operator-database/config/rbac/role_binding.yaml
    cp -nf $DATABASE_TEMPLATE_FOLDER/scripts/operator-database-role_patch_TEMPLATE.yaml $ROOT_FOLDER/operator-database/config/rbac/role.yaml
    # make bundle-build BUNDLE_IMG="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE"
    podman build -f bundle.Dockerfile -t "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE" .
    
    # Push container
    podman login $REGISTRY
    podman push "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE"
}

function buildDatabaseOperatorCatalog () {
    cd $ROOT_FOLDER/operator-database
    # make catalog-build CATALOG_IMG="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_CATALOG" BUNDLE_IMGS="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE"
    $ROOT_FOLDER/operator-database/bin/opm index add --build-tool podman --mode semver --tag "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_CATALOG" --bundles "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE"
    podman login $REGISTRY
    podman push "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_CATALOG"
}

function createOLMDatabaseOperatorYAMLs () {
    CATALOG_NAME="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_CATALOG"
    sed "s+DATABASE_CATALOG_IMAGE+$CATALOG_NAME+g" $DATABASE_TEMPLATE_FOLDER/kubernetes-database-catalogsource-TEMPLATE.yaml > $ROOT_FOLDER/scripts/kubernetes-database-catalogsource.yaml
}

function deployDatabaseOperatorOLM () {
    kubectl create -f $ROOT_FOLDER/scripts/kubernetes-database-catalogsource.yaml
    kubectl create -f $ROOT_FOLDER/scripts/kubernetes-database-subscription.yaml

    kubectl get catalogsource operator-database-catalog -n $NAMESPACE -oyaml
    kubectl get subscriptions operator-database-v0-0-1-sub -n $NAMESPACE -oyaml
    kubectl get installplans -n $NAMESPACE
    kubectl get pods -n $NAMESPACE
    kubectl get all -n $NAMESPACE

    array=("operator-database-catalog")
    namespace=operators
    export STATUS_SUCCESS="Running"
    for i in "${array[@]}"
        do 
            echo ""
            echo "------------------------------------------------------------------------"
            echo "Check $i"
            while :
            do
                FIND=$i
                STATUS_CHECK=$(kubectl get pods -n $namespace | grep "$FIND" | awk '{print $3;}' | sed 's/"//g' | sed 's/,//g')
                echo "Status: $STATUS_CHECK"
                STATUS_VERIFICATION=$(echo "$STATUS_CHECK" | grep $STATUS_SUCCESS)
                if [ "$STATUS_VERIFICATION" = "$STATUS_SUCCESS" ]; then
                    echo "$(date +'%F %H:%M:%S') Status: $FIND is Ready"
                    echo "------------------------------------------------------------------------"
                    break
                else
                    echo "$(date +'%F %H:%M:%S') Status: $FIND($STATUS_CHECK)"
                    echo "------------------------------------------------------------------------"
                fi
                sleep 3
            done
        done

    array=("operator-database.v0.0.1")
    namespace=operators
    search=installplans
    export STATUS_SUCCESS="true"
    for i in "${array[@]}"
        do 
            echo ""
            echo "------------------------------------------------------------------------"
            echo "Check $i"
            while :
            do
                FIND=$i
                STATUS_CHECK=$(kubectl get $search -n $namespace | grep "$FIND" | awk '{print $4;}' | sed 's/"//g' | sed 's/,//g')
                echo "Status: $STATUS_CHECK"
                STATUS_VERIFICATION=$(echo "$STATUS_CHECK" | grep $STATUS_SUCCESS)
                if [ "$STATUS_VERIFICATION" = "$STATUS_SUCCESS" ]; then
                    echo "$(date +'%F %H:%M:%S') Status: $search($STATUS_CHECK)"
                    echo "------------------------------------------------------------------------"
                    break
                else
                    echo "$(date +'%F %H:%M:%S') Status: $search($STATUS_CHECK)"
                    echo "------------------------------------------------------------------------"
                fi
                sleep 3
            done
        done

    array=("operator-database-controller-manager" )
    namespace=operators
    export STATUS_SUCCESS="Running"
    for i in "${array[@]}"
        do 
            echo ""
            echo "------------------------------------------------------------------------"
            echo "Check $i"
            while :
            do
                FIND=$i
                STATUS_CHECK=$(kubectl get pods -n $namespace | grep "$FIND" | awk '{print $3;}' | sed 's/"//g' | sed 's/,//g')
                echo "Status: $STATUS_CHECK"
                STATUS_VERIFICATION=$(echo "$STATUS_CHECK" | grep $STATUS_SUCCESS)
                if [ "$STATUS_VERIFICATION" = "$STATUS_SUCCESS" ]; then
                    echo "$(date +'%F %H:%M:%S') Status: $FIND is Ready"
                    echo "------------------------------------------------------------------------"
                    break
                else
                    echo "$(date +'%F %H:%M:%S') Status: $FIND($STATUS_CHECK)"
                    echo "------------------------------------------------------------------------"
                fi
                sleep 3
            done
        done
}

function createDatabaseInstance () {
    kubectl create ns database   
    kubectl apply -f $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_database.yaml
    kubectl apply -f $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasecluster.yaml
    kubectl get pods -n database
    
    array=("database-cluster-0" "database-cluster-1")
    namespace=database
    export STATUS_SUCCESS="Running"
    for i in "${array[@]}"
        do 
            echo ""
            echo "------------------------------------------------------------------------"
            echo "Check $i"
            while :
            do
                FIND=$i
                STATUS_CHECK=$(kubectl get pods -n $namespace | grep "$FIND" | awk '{print $3;}' | sed 's/"//g' | sed 's/,//g')
                echo "Status: $STATUS_CHECK"
                STATUS_VERIFICATION=$(echo "$STATUS_CHECK" | grep $STATUS_SUCCESS)
                if [ "$STATUS_VERIFICATION" = "$STATUS_SUCCESS" ]; then
                    echo "$(date +'%F %H:%M:%S') Status: $FIND is Ready"
                    echo "------------------------------------------------------------------------"
                    break
                else
                    echo "$(date +'%F %H:%M:%S') Status: $FIND($STATUS_CHECK)"
                    echo "------------------------------------------------------------------------"
                fi
                sleep 3
            done
        done
    
    kubectl get databases/database -n database -oyaml
    kubectl get databases.database.sample.third.party/database -n database -oyaml
}

function verifyDatabase() {
     kubectl get database/databasecluster-sample -oyaml
     kubectl exec -n database database-cluster-1 -- curl -s http://localhost:8089/persons
     kubectl exec -n database database-cluster-0 -- curl -s http://localhost:8089/api/leader
}

# **********************************************************************************
# Execution
# **********************************************************************************

echo "************************************"
echo " Set context"
echo "************************************"
setEnvironmentVariables

resetAll

echo "************************************"
echo " Verify prerequisites"
echo "************************************"
verifyPreReqs

echo "************************************"
echo " Build 'database service'"
echo " Push image to $REGISTRY/$ORG/$IMAGE_DATABASE_SERVICE"
echo "************************************"
buildDatabaseService

echo "************************************"
echo " Build 'operator database backup'"
echo " Push image to $REGISTRY/$ORG/$IMAGE_DATABASE_BACKUP"
echo "************************************"
buildDatabaseBackup

echo "************************************"
echo " Configure CR samples for the 'database operator'"
echo "************************************"
configureCRs_DatabaseOperator

echo "************************************"
echo " Build 'database operator'"
echo " Push image to $REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"
echo "************************************"
buildDatabaseOperator

echo "************************************"
echo " Build 'database operator bundle'"
echo " Push image to $REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE"
echo "************************************"
buildDatabaseOperatorBundle

echo "************************************"
echo " Build 'database operator catalog'"
echo " Push image to $REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_CATALOG"
echo "************************************"
buildDatabaseOperatorCatalog

echo "************************************"
echo " Create OLM yamls"
echo "************************************"
createOLMDatabaseOperatorYAMLs

echo "************************************"
echo " Deploy Database Operator OLM"
echo "************************************"
deployDatabaseOperatorOLM

echo "************************************"
echo " Create Database Instance"
echo "************************************"
createDatabaseInstance

echo "************************************"
echo " Verify Database Instance"
echo "************************************"
verifyDatabase