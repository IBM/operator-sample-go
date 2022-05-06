#!/bin/bash

# **************** Global variables

ROOT_FOLDER=$(cd $(dirname $0); cd ..; pwd)
source $ROOT_FOLDER/versions.env

# **********************************************************************************
# Functions
# **********************************************************************************

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
    sed "s+DATABASE_CATALOG_IMAGE+$CATALOG_NAME+g" $ROOT_FOLDER/scripts/kubernetes-database-catalogsource-TEMPLATE.yaml > $ROOT_FOLDER/scripts/kubernetes-database-catalogsource.yaml
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
    kubectl apply -f $ROOT_FOLDER/operator-application/olm/catalogsource.yaml
    kubectl apply -f $ROOT_FOLDER/operator-application/olm/subscription.yaml

    array=("operator-application-catalog" "operator-application-controller-manager" )
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
    #Database
    kubectl create namespace database
    kubectl apply -f $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_database.yaml
    kubectl apply -f $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasecluster.yaml


    kubectl get pods -n database
    kubectl get databases.database.sample.third.party/database -n database -oyaml
    kubectl get databaseclusters.database.sample.third.party/databasecluster-sample -n database -oyaml

}

function createApplicationInstance () {   
    #Application
    kubectl apply -f  $ROOT_FOLDER/operator-application/config/samples/application.sample_v1beta1_application.yaml
    kubectl get applications.application.sample.ibm.com/application -n application-beta -oyaml
}

function verifyApplicationBeta () {
    kubectl exec -n application-beta $(kubectl get pods -n application-beta | awk '/application-deployment-microservice/ {print $1;exit}') --container application-microservice -- curl http://localhost:8081/hello
}

# **********************************************************************************
# Execution
# **********************************************************************************

echo "************************************"
echo " Verify prerequisites"
echo "************************************"
#verifyPreReqs

echo "************************************"
echo " Create OLM database operator YAMLs"
echo "************************************"
#createOLMDatabaseOperatorYAMLs

echo "************************************"
echo " Deploy Database Operator"
echo "************************************"
#deployDatabaseOperator

echo "************************************"
echo " Create Database Instance"
echo "************************************"
createDatabaseInstance

echo "************************************"
echo " Deploy Application Operator"
echo "************************************"
# deployApplicationOperator

echo "************************************"
echo " Create Application and Database instance"
echo "************************************"
# createApplicationAndDatabaseInstance

echo "************************************"
echo " Verify Application Beta"
echo "************************************"
# verifyApplicationBeta