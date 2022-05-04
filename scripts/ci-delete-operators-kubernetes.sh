#!/bin/bash

# **************** Global variables

ROOT_FOLDER=$(cd $(dirname $0); cd ..; pwd)

# **********************************************************************************
# Functions
# **********************************************************************************

function deleteDatabaseOperatorOLM () {
    kubectl delete -f $ROOT_FOLDER/scripts/kubernetes-database-catalogsource.yaml
    kubectl delete -f $ROOT_FOLDER/scripts/kubernetes-database-subscription.yaml
}

function deleteDatabaseInstance () {
    kubectl delete -f $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_database.yaml
}

# **********************************************************************************
# Execution
# **********************************************************************************


echo "************************************"
echo " Delete Database Operator (OLM)"
echo "************************************"
deleteDatabaseOperatorOLM

echo "************************************"
echo " Delete Database Instance"
echo "************************************"
deleteDatabaseInstance