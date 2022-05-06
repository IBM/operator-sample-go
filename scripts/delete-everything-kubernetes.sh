#!/bin/bash

# **************** Global variables

ROOT_FOLDER=$(cd $(dirname $0); cd ..; pwd)

# **********************************************************************************
# Functions
# **********************************************************************************

function setEnvironmentVariables () {
    source $ROOT_FOLDER/versions.env
}

function deleteMicroserviceApplicationInstance () { 
    cd $ROOT_FOLDER/operator-application
    kubectl delete -f config/samples/application.sample_v1beta1_application.yaml
    kubectl delete -f config/samples/application.sample_v1alpha1_application.yaml

    kubectl delete customresourcedefinition applications.application.sample.ibm.com
    kubectl delete deployment operator-application-controller-manager -n operators
    kubectl delete clusterserviceversion operator-application.v0.0.1
 
    #echo "Press any key to move on"
    #read input
}

function deleteApplicationOperator () {
    make undeploy IMG="$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR"
    operator-sdk cleanup operator-application -n operators --delete-all
    #echo "Press any key to move on"
    #read input
}

function deleteOLMdeployment () {
    kubectl delete catalogsource operator-application-catalog -n operators 
    kubectl delete subscriptions operator-application-v0-0-1-sub -n operators 
    kubectl delete csv operator-application.v0.0.1 -n operators
    kubectl delete operators operator-application.operators -n operators
    kubectl delete installplans -n operators --all
    #echo "Press any key to move on"
    #read input
}

function deleteNamespacesRelatedToApplicationOperator () {
    kubectl delete namespace application-alpha
    kubectl delete namespace application-beta
    kubectl delete all --all -n operator-application-system
    kubectl delete namespace operator-application-system
    #echo "Press any key to move on"
    #read input
}

function deleteDatabaseInstance () {
    cd $ROOT_FOLDER/operator-database
    kubectl delete -f config/samples/database.sample_v1alpha1_database.yaml
    #echo "Press any key to move on"
    #read input
}

function deleteDatabaseOperator () {
    make undeploy IMG="$REGISTRY/$ORG/$IMAGE_DATBASE_OPERATOR"
    operator-sdk cleanup operator-database -n operators --delete-all   
    
    kubectl delete -f $ROOT_FOLDER/operator-database/olm/subscription.yaml
    kubectl delete -f $ROOT_FOLDER/operator-database/olm/catalogsource.yaml

    kubectl delete customresourcedefinition databasebackups.database.sample.third.party
    kubectl delete customresourcedefinition databases.database.sample.third.party
    kubectl delete customresourcedefinition databaseclusters.database.sample.third.party

    kubectl delete deployment operator-database-controller-manager -n operators
    kubectl delete clusterserviceversion operator-database.v0.0.1 
    kubectl delete clusterrole operator-database-metrics-reader
    
    #echo "Press any key to move on"
    #read input
}

function deleteNamespacesRelatedToDatabaseOperator () {
    kubectl delete namespace database
    kubectl delete all --all -n operator-database-system
    kubectl delete namespace operator-database-system
    #echo "Press any key to move on"
    #read input
}

function deletePrometheus () {
    cd $ROOT_FOLDER
    kubectl delete -f prometheus/kubernetes/operator
    kubectl delete -f prometheus/kubernetes/instance
    kubectl delete customresourcedefinition alertmanagerconfigs.monitoring.coreos.com

    # delete crds
    kubectl delete customresourcedefinition podmonitors.monitoring.coreos.com
    kubectl delete customresourcedefinition servicemonitors.monitoring.coreos.com
    kubectl delete customresourcedefinition thanosrulers.monitoring.coreos.com
    kubectl delete customresourcedefinition prometheusrules.monitoring.coreos.com
    kubectl delete customresourcedefinition prometheuses.monitoring.coreos.com
    kubectl delete customresourcedefinition probes.monitoring.coreos.com
    kubectl delete customresourcedefinition alertmanagers.monitoring.coreos.com
    kubectl delete customresourcedefinition podmonitors.monitoring.coreos.com
    
    #echo "Press any key to move on"
    #read input
}

function deleteOLM () {
    operator-sdk olm uninstall
    
    #echo "Press any key to move on"
    #read input
}

function deleteCertManager () {
    kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.2/cert-manager.yaml
        
    #echo "Press any key to move on"
    #read input
}

# **********************************************************************************
# Execution
# **********************************************************************************

echo "************************************"
echo " Set environment"
echo "************************************"
setEnvironmentVariables

echo "************************************"
echo " Delete microservice application"
echo "************************************"
deleteMicroserviceApplicationInstance

echo "************************************"
echo " Delete application operator"
echo "************************************"
deleteApplicationOperator

echo "************************************"
echo " Delete application operator OLM deployment"
echo "************************************"
deleteOLMdeployment

echo "************************************"
echo " Delete namespaces related to application operator"
echo "************************************"
deleteNamespacesRelatedToApplicationOperator

echo "************************************"
echo " Delete database application and operator"
echo "************************************"
deleteDatabaseInstance

echo "************************************"
echo " Delete database application"
echo "************************************"
deleteNamespacesRelatedToDatabaseOperator

echo "************************************"
echo " Delete prometheus"
echo "************************************"
deletePrometheus

echo "************************************"
echo " Delete OLM"
echo "************************************"
deleteOLM

echo "************************************"
echo " Delete cert manager"
echo "************************************"
deleteCertManager