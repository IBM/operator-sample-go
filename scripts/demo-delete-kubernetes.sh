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
}

function deleteApplicationOperator () {
    kubectl delete -f $ROOT_FOLDER/operator-application/olm/subscription.yaml
    kubectl delete -f $ROOT_FOLDER/operator-application/olm/catalogsource.yaml
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

echo "************************************"
echo " Delete Application and Database instance"
echo "************************************"
deleteApplicationAndDatabaseInstance