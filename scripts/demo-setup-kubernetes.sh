#!/bin/bash

echo "************************************"
echo " Display parameter"
echo "************************************"
echo ""
echo "Parameter count : $@"
echo "Parameter zero 'name of the script': $0"
echo "---------------------------------"
echo "Reset                    : $1"
echo "-----------------------------"

# **************** Global variables

export ROOT_FOLDER=$(cd $(dirname $0); cd ..; pwd)
source $ROOT_FOLDER/versions.env
export APPLICATION_TEMPLATE_FOLDER=$ROOT_FOLDER/scripts/application-operator-templates
export DATABASE_TEMPLATE_FOLDER=$ROOT_FOLDER/scripts/database-operator-templates
export RESET=$1

# **********************************************************************************
# Functions
# **********************************************************************************

function resetAll () {

    if [[ $RESET == "reset" ]]; then
        echo "*** RESET Kubernetes environment!"
        echo "*** DELETE all Kubernetes compoments!"
        cd $ROOT_FOLDER/scripts
        bash ./delete-everything-kubernetes.sh

        echo "*** Install required Kubernetes compoments!"
        cd $ROOT_FOLDER/scripts
        bash ./install-required-kubernetes-components.sh
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

function createOLMDatabaseOperatorYAMLs () {
    CATALOG_NAME="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_CATALOG"
    sed "s+DATABASE_CATALOG_IMAGE+$CATALOG_NAME+g" $DATABASE_TEMPLATE_FOLDER/kubernetes-database-catalogsource-TEMPLATE.yaml > $ROOT_FOLDER/scripts/kubernetes-database-catalogsource.yaml
}

function deployDatabaseOperator () {

    # kubectl apply -f $ROOT_FOLDER/operator-database/olm/catalogsource.yaml
    # kubectl get catalogsource -n operators
    # kubectl apply -f $ROOT_FOLDER/operator-database/olm/subscription.yaml
    # kubectl get subscription -n operators
    # kubectl get installplans -n operators

    kubectl create -f $ROOT_FOLDER/scripts/kubernetes-database-catalogsource.yaml
    kubectl create -f $ROOT_FOLDER/scripts/kubernetes-database-subscription.yaml
    
    NAMESPACE=operators

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

function deployApplicationOperator () {
    #kubectl apply -f $ROOT_FOLDER/operator-application/olm/catalogsource.yaml
    #kubectl apply -f $ROOT_FOLDER/operator-application/olm/subscription.yaml

    kubectl create -f $ROOT_FOLDER/scripts/kubernetes-application-catalogsource.yaml
    kubectl create -f $ROOT_FOLDER/scripts/kubernetes-application-subscription.yaml
 
    array=("operator-application-catalog")
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

    array=("operator-application.v0.0.1")
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

    array=("operator-application-controller-manager" )
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
    kubectl get operators operator-application.$namespace -n $namespace -oyaml
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

function createDatabaseInstance () {
    #Database
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

function createOLMApplicationOperatorYAMLs () {
    CATALOG_NAME="$REGISTRY/$ORG/$IMAGE_APPLICATOI_OPERATOR_CATALOG"
    sed "s+APPLICATION_CATALOG_IMAGE+$CATALOG_NAME+g" $APPLICATION_TEMPLATE_FOLDER/kubernetes-application-catalogsource-TEMPLATE.yaml > $ROOT_FOLDER/scripts/kubernetes-database-catalogsource.yaml
}

function configureCR_SimpleMicroservice () {
    IMAGE_NAME="$REGISTRY/$ORG/$IMAGE_MICROSERVICE"
    sed "s+SIMPLE_APPLICATION_IMAGE+$IMAGE_NAME+g" $APPLICATION_TEMPLATE_FOLDER/application.sample_v1alpha1_application.yaml > $ROOT_FOLDER/operator-application/config/samples/application.sample_v1alpha1_application.yaml
    sed "s+SIMPLE_APPLICATION_IMAGE+$IMAGE_NAME+g" $APPLICATION_TEMPLATE_FOLDER/application.sample_v1beta1_application.yaml > $ROOT_FOLDER/operator-application/config/samples/application.sample_v1beta1_application.yaml
}

function createApplicationInstance () {   
    #Application
    kubectl apply -f  $ROOT_FOLDER/operator-application/config/samples/application.sample_v1beta1_application.yaml
    kubectl get applications.application.sample.ibm.com/application -n application-beta -oyaml
}

function verifyApplicationBeta () {
    kubectl get applications.application.sample.ibm.com/application -n application-beta -oyaml
    kubectl exec -n application-beta $(kubectl get pods -n application-beta | awk '/application-deployment-microservice/ {print $1;exit}') --container application-microservice -- curl http://localhost:8081/hello
    kubectl logs -n $NAMESPACE $(kubectl get pods -n $NAMESPACE | awk '/operator-application-controller-manager/ {print $1;exit}') -c manager
}

function verifyPrometheusInstance () {
   kubectl get service -n monitoring
   kubectl port-forward service/prometheus-instance -n monitoring 9090
}

# **********************************************************************************
# Execution
# **********************************************************************************

resetAll

echo "************************************"
echo " Verify prerequisites"
echo "************************************"
verifyPreReqs

echo "************************************"
echo " Create OLM database operator YAMLs"
echo "************************************"
createOLMDatabaseOperatorYAMLs

echo "************************************"
echo " Deploy Database Operator"
echo "************************************"
deployDatabaseOperator

echo "************************************"
echo " Configure CRs for Database Operator"
echo "************************************"
configureCRs_DatabaseOperator

echo "************************************"
echo " Create Database Instance"
echo "************************************"
createDatabaseInstance

echo "************************************"
echo " Create OLM application operator YAMLs"
echo "************************************"
createOLMApplicationOperatorYAMLs

echo "************************************"
echo " Deploy Application Operator"
echo "************************************"
deployApplicationOperator

echo "************************************"
echo " Configure CRs for Application Operator"
echo "************************************"
configureCR_SimpleMicroservice

echo "************************************"
echo " Create Application Instance"
echo "************************************"
createApplicationInstance

echo "************************************"
echo " Verify Application Beta"
echo "************************************"
verifyApplicationBeta

echo "************************************"
echo " Verify prometheus instance"
echo "************************************"
verifyPrometheusInstance