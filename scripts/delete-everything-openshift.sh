#!/bin/bash

# **************** Global variables

export ROOT_FOLDER=$(cd $(dirname $0); cd ..; pwd)
export DATABASE_TEMPLATE_FOLDER=$ROOT_FOLDER/scripts/database-operator-templates
export APPLICATION_TEMPLATE_FOLDER=$ROOT_FOLDER/scripts/application-operator-templates

# **********************************************************************************
# Functions
# **********************************************************************************

function setEnvironmentVariables () {
    source $ROOT_FOLDER/versions.env
}

function setEnvironmentVariablesLocal () {
    source $ROOT_FOLDER/versions_local.env
}

function deletePrometheusConfiguration () {
    oc delete -f $ROOT_FOLDER/prometheus/openshift/
    oc delete secret prometheus-token-secret
}

function deleteMicroserviceApplicationInstance () { 
    cd $ROOT_FOLDER/operator-application
    kubectl delete -f config/samples/application.sample_v1beta1_application.yaml
    kubectl delete -f config/samples/application.sample_v1alpha1_application.yaml

    #echo "Press any key to move on"
    #read input
}

function deleteOLMdeployment () {

    # Application
    CATALOG_NAME="$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_CATALOG"
    sed "s+APPLICATION_CATALOG_IMAGE+$CATALOG_NAME+g" $APPLICATION_TEMPLATE_FOLDER/openshift-application-catalogsource-TEMPLATE.yaml > $ROOT_FOLDER/scripts/openshift-application-catalogsource.yaml
    cp -nf $APPLICATION_TEMPLATE_FOLDER/openshift-application-subscription-TEMPLATE.yaml $ROOT_FOLDER/scripts/openshift-application-subscription.yaml 

    kubectl delete -f $ROOT_FOLDER/scripts/openshift-application-catalogsource.yaml
    kubectl delete -f $ROOT_FOLDER/scripts/openshift-application-subscription.yaml
    
    kubectl delete subscriptions operator-application-v0-0-1-sub -n openshift-operators  
    kubectl delete catalogsource operator-application-catalog -n openshift-operators 

    oc get clusterserviceversion | grep operator-application.v0.0.1 -n openshift-operators
    oc delete clusterserviceversion operator-application.v0.0.1 -n openshift-operators
    
    # Database
    CATALOG_NAME="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_CATALOG"
    sed "s+DATABASE_CATALOG_IMAGE+$CATALOG_NAME+g" $DATABASE_TEMPLATE_FOLDER/openshift-database-catalogsource-TEMPLATE.yaml > $ROOT_FOLDER/scripts/openshift-database-catalogsource.yaml
    cp -nf $DATABASE_TEMPLATE_FOLDER/openshift-database-subscription-TEMPLATE.yaml $ROOT_FOLDER/scripts/openshift-database-subscription.yaml 

    kubectl delete subscriptions operator-database-v0-0-1-sub -n openshift-operators  
    kubectl delete catalogsource operator-database-catalog -n openshift-operators

    oc get clusterserviceversion | grep operator-database.v0.0.1 -n openshift-operators
    oc delete clusterserviceversion operator-database.v0.0.1 -n openshift-operators

    kubectl delete -f $ROOT_FOLDER/scripts/openshift-database-catalogsource.yaml
    kubectl delete -f $ROOT_FOLDER/scripts/openshift-database-subscription.yaml

    kubectl delete -f $ROOT_FOLDER/bundle/manifests/operator-database.clusterserviceversion.yaml

    #kubectl delete installplans -n openshift-operators --all
    #echo "Press any key to move on"
    #read input
}

function deleteNamespacesRelatedToApplicationOperator () {
    kubectl delete namespace application-alpha
    kubectl delete namespace application-beta
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
     
    kubectl delete -f $ROOT_FOLDER/scripts/openshift-database-subscription.yaml 
    kubectl delete -f $ROOT_FOLDER/scripts/openshift-database-catalogsource.yaml

    namespace=openshift-operators
    kubectl delete customresourcedefinition databasebackups.database.sample.third.party -n $namespace
    kubectl delete customresourcedefinition databases.database.sample.third.party -n $namespace
    kubectl delete customresourcedefinition databaseclusters.database.sample.third.party -n $namespace

    kubectl delete deployment operator-database-controller-manager -n $namespace
    kubectl delete clusterserviceversion operator-database.v0.0.1 
    kubectl delete clusterrole operator-database-metrics-reader
    
    #echo "Press any key to move on"
    #read input
}

function deleteNamespacesRelatedToDatabaseOperator () {
    kubectl delete namespace database
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
echo " Delete prometheus configuration"
echo "************************************"
deletePrometheusConfiguration

echo "************************************"
echo " Delete microservice application"
echo "************************************"
deleteMicroserviceApplicationInstance

echo "************************************"
echo " Delete application operator"
echo "************************************"
deleteApplicationOperator

echo "************************************"
echo " Delete database operator"
echo "************************************"
deleteDatabaseOperator 

echo "************************************"
echo " Delete application operator OLM deployments"
echo "************************************"
deleteOLMdeployment

echo "************************************"
echo " Delete database instance"
echo "************************************"
deleteDatabaseInstance

echo "************************************"
echo " Delete namespaces related to application operator"
echo "************************************"
deleteNamespacesRelatedToApplicationOperator

echo "************************************"
echo " Delete database application"
echo "************************************"
deleteNamespacesRelatedToDatabaseOperator

echo "************************************"
echo " Delete for local configuration"
echo "************************************"
setEnvironmentVariablesLocal
deleteMicroserviceApplicationInstance
deleteApplicationOperator
deleteOLMdeployment
deleteNamespacesRelatedToApplicationOperator
deleteDatabaseInstance
deleteDatabaseOperator
deleteNamespacesRelatedToDatabaseOperator

echo "************************************"
echo " Delete cert manager"
echo "************************************"
deleteCertManager