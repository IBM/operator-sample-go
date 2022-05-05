#!/bin/bash

# **************** Global variables

ROOT_FOLDER=$(cd $(dirname $0); cd ..; pwd)
source $ROOT_FOLDER/versions.env

# **********************************************************************************
# Functions
# **********************************************************************************

function deleteDatabaseOperator () {  
    kubectl delete -f $ROOT_FOLDER/operator-database/olm/subscription.yaml
    kubectl delete -f $ROOT_FOLDER/operator-database/olm/catalogsource.yaml

    kubectl delete -f $ROOT_FOLDER/scripts/kubernetes-database-catalogsource.yaml
    kubectl delete -f $ROOT_FOLDER/scripts/kubernetes-database-subscription.yaml

    kubectl delete customresourcedefinition databasebackups.database.sample.third.party
    kubectl delete customresourcedefinition databases.database.sample.third.party
    kubectl delete customresourcedefinition databaseclusters.database.sample.third.party

    kubectl delete deployment operator-database-controller-manager -n operators
    kubectl delete clusterserviceversion operator-database.v0.0.1 
    kubectl get pods -n operators | grep operator-database
}

function deleteApplicationOperator () {

    kubectl delete -f $ROOT_FOLDER/operator-application/olm/subscription.yaml
    kubectl delete -f $ROOT_FOLDER/operator-application/olm/catalogsource.yaml

    kubectl delete customresourcedefinition applications.application.sample.ibm.com
    kubectl delete deployment operator-application-controller-manager -n operators
    kubectl delete clusterserviceversion operator-application.v0.0.1
    
    kubectl get pods -n operators | grep operator-application
}

function deleteApplicationAndDatabaseInstance () {
    kubectl delete -f $ROOT_FOLDER/operator-application/config/samples/application.sample_v1beta1_application.yaml
    kubectl delete -f $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_database.yaml
    kubectl delete namespace database
}

# **********************************************************************************
# Execution
# **********************************************************************************

echo "************************************"
echo " Delete Database and Application instance"
echo "************************************"
deleteApplicationAndDatabaseInstance

echo "************************************"
echo " Delete Database Operator"
echo "************************************"
deleteDatabaseOperator

echo "************************************"
echo " Delete Application Operator"
echo "************************************"
deleteApplicationOperator