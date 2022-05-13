#!/bin/bash

# **************** Global variables

export ROOT_FOLDER=$(cd $(dirname $0); cd ..; pwd)

# **********************************************************************************
# Functions
# **********************************************************************************

function deleteDatabaseOperatorOLM () {
    kubectl delete -f $ROOT_FOLDER/scripts/kubernetes-database-catalogsource.yaml
    kubectl delete -f $ROOT_FOLDER/scripts/kubernetes-database-subscription.yaml

    kubectl delete customresourcedefinition applications.application.sample.ibm.com
    kubectl delete customresourcedefinition databasebackups.database.sample.third.party
    kubectl delete customresourcedefinition databases.database.sample.third.party
    kubectl delete customresourcedefinition databaseclusters.database.sample.third.party

    kubectl delete deployment operator-application-controller-manager -n operators
    kubectl delete clusterserviceversion operator-application.v0.0.1
    kubectl get pods -n operators | grep operator-application
}

function deleteDatabaseInstance () {
    kubectl delete -f $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_database.yaml
}

# **********************************************************************************
# Execution
# **********************************************************************************

echo "************************************"
echo " Delete Database Instance"
echo "************************************"
deleteDatabaseInstance

echo "************************************"
echo " Delete Database Operator (OLM)"
echo "************************************"
deleteDatabaseOperatorOLM

