#!/bin/bash

# **************** Global variables

export ROOT_FOLDER=$(cd $(dirname $0); cd ..; pwd)
export LOGFILE_NAME="delete-all-kubernetes.log"
export SCRIPTNAME="delete-everything-kubernetes.sh"

# **********************************************************************************
# Functions
# **********************************************************************************

function initLog () {
    echo "$(date +'%F %H:%M:%S'): Init Script Automation Log" > $ROOT_FOLDER/scripts/$LOGFILE_NAME
    echo "$(date +'%F %H:%M:%S'): $SCRIPTNAME" >> $ROOT_FOLDER/scripts/$LOGFILE_NAME
    echo "$(date +'%F %H:%M:%S'): ********************************************************" >> $ROOT_FOLDER/scripts/"$LOGFILE_NAME"
}

function customLog () {
    LOG_TYPE="$1"
    LOG_MESSAGE="$2"
    echo "$(date +'%F %H:%M:%S'): $LOG_TYPE" >> $ROOT_FOLDER/scripts/"$LOGFILE_NAME"
    echo "$LOG_MESSAGE" >> $ROOT_FOLDER/scripts/"$LOGFILE_NAME"
    echo "$(date +'%F %H:%M:%S'): ********************************************************" >> $ROOT_FOLDER/scripts/"$LOGFILE_NAME"
}

function setEnvironmentVariablesCI () {
    source $ROOT_FOLDER/versions.env
}

function setEnvironmentVariablesLocal () {
    source $ROOT_FOLDER/versions_local.env
}

function deleteMicroserviceApplicationInstance () { 
    
    TYPE='function'
    INFO="deleteMicroserviceApplicationInstance"
    customLog $TYPE $INFO
    
    cd $ROOT_FOLDER/operator-application
    kubectl delete -f config/samples/application.sample_v1beta1_application.yaml
    kubectl delete -f config/samples/application.sample_v1alpha1_application.yaml

    kubectl delete --force customresourcedefinition applications.application.sample.ibm.com
    kubectl delete --force deployment operator-application-controller-manager -n operators
    kubectl delete --force clusterserviceversion operator-application.v0.0.1
 
    #echo "Press any key to move on"
    #read input
}

function deleteApplicationOperator () {
    
    TYPE='function'
    INFO="deleteApplicationOperator"
    customLog $TYPE $INFO

    make undeploy IMG="$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR"
    operator-sdk cleanup operator-application -n operators --delete-all
    #echo "Press any key to move on"
    #read input
}

function deleteOLMdeployment () {

    TYPE='function'
    INFO="deleteOLMdeployment"
    customLog $TYPE $INFO

    kubectl delete  --force catalogsource operator-application-catalog -n operators 
    kubectl delete  --force subscriptions operator-application-v0-0-1-sub -n operators 
    kubectl delete  --force csv operator-application.v0.0.1 -n operators
    kubectl delete  --force operators operator-application.operators -n operators

    #echo "Press any key to move on"
    #read input
}

function deleteNamespacesRelatedToApplicationOperator () {

    TYPE='function'
    INFO="deleteOLMdeployment"
    customLog $TYPE $INFO

    kubectl delete --force namespace application-alpha
    kubectl delete --force namespace application-beta
    kubectl delete --force namespace operator-application-system
    #echo "Press any key to move on"
    #read input
}

function deleteDatabaseInstance () {

    TYPE='function'
    INFO="deleteDatabaseInstance"
    customLog $TYPE $INFO

    cd $ROOT_FOLDER/operator-database
    kubectl delete -f config/samples/database.sample_v1alpha1_database.yaml
    kubectl delete -f config/samples/database.sample_v1alpha1_databasebackup.yaml
    kubectl delete -f config/samples/database.sample_v1alpha1_databasecluster.yaml
    kubectl delete --force namespace database
    #echo "Press any key to move on"
    #read input
}

function deleteDatabaseOperator () {

    TYPE='function'
    INFO="deleteDatabaseOperator"
    customLog $TYPE $INFO

    make undeploy IMG="$REGISTRY/$ORG/$IMAGE_DATBASE_OPERATOR"
    operator-sdk cleanup operator-database -n operators --delete-all   
    
    kubectl delete -f $ROOT_FOLDER/operator-database/olm/subscription.yaml
    kubectl delete -f $ROOT_FOLDER/scripts/subscription.yaml

    kubectl delete -f $ROOT_FOLDER/operator-database/olm/catalogsource.yaml 
    kubectl delete -f $ROOT_FOLDER/scripts/catalogsource.yaml

    kubectl delete --force customresourcedefinition databasebackups.database.sample.third.party -n operators
    kubectl delete --force customresourcedefinition databases.database.sample.third.party -n operators
    kubectl delete --force customresourcedefinition databaseclusters.database.sample.third.party -n operators

    kubectl delete --force deployment operator-database-controller-manager -n operators
    kubectl delete --force clusterserviceversion operator-database.v0.0.1 
    kubectl delete --force clusterrole operator-database-metrics-reader
    kubectl delete --force namespace database
    
    #echo "Press any key to move on"
    #read input
}

function deleteNamespacesRelatedToDatabaseOperator () {

    TYPE='function'
    INFO="deleteNamespacesRelatedToDatabaseOperator"
    customLog $TYPE $INFO

    kubectl delete --force namespace database
    kubectl delete --force namespace operator-database-system
    #echo "Press any key to move on"
    #read input
}

function deletePrometheus () {

    TYPE='function'
    INFO="deletePrometheus"
    customLog $TYPE $INFO

    cd $ROOT_FOLDER
     
    kubectl delete -f prometheus/kubernetes/instance
    kubectl delete -f prometheus/kubernetes/operator
    kubectl delete --force customresourcedefinition alertmanagerconfigs.monitoring.coreos.com

    # delete crds
    kubectl delete --force customresourcedefinition podmonitors.monitoring.coreos.com
    kubectl delete --force customresourcedefinition servicemonitors.monitoring.coreos.com
    kubectl delete --force customresourcedefinition thanosrulers.monitoring.coreos.com
    kubectl delete --force customresourcedefinition prometheusrules.monitoring.coreos.com
    kubectl delete --force customresourcedefinition prometheuses.monitoring.coreos.com
    kubectl delete --force customresourcedefinition probes.monitoring.coreos.com
    kubectl delete --force customresourcedefinition alertmanagers.monitoring.coreos.com
    kubectl delete --force customresourcedefinition podmonitors.monitoring.coreos.com
    
    #echo "Press any key to move on"
    #read input
}

function deleteOLM () {
    
    TYPE='function'
    INFO="deleteOLM"
    customLog $TYPE $INFO
    
    operator-sdk olm uninstall
    
    #echo "Press any key to move on"
    #read input
}

function deleteCertManager () {

  TYPE='function'
  INFO="deleteOLM"
  customLog $TYPE $INFO

  kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.2/cert-manager.yaml
    
  export max_retrys=9
  array=("cert-manager" "olm" "operators")
  export STATUS_SUCCESS=""
  for i in "${array[@]}"
    do 
        echo ""
        echo "------------------------------------------------------------------------"
        echo "Check $i"
        j=0
        export FIND=$i
        while :
        do       
           ((j++))
           STATUS_CHECK=$(kubectl get namespace $FIND | grep $FIND | awk '{print $2;}')
           echo "Status: $STATUS_CHECK"
           if [ "$STATUS_CHECK" = "$STATUS_SUCCESS" ]; then
                echo "$(date +'%F %H:%M:%S') Status: $FIND is deleted"
                echo "------------------------------------------------------------------------"
                break
            elif [[ $j -eq $max_retrys ]]; then
                echo "$(date +'%F %H:%M:%S') Please rerun the 'delete-everything-kubernetes.sh' first!"
                echo "$(date +'%F %H:%M:%S') Installation can't be cleaned!"
                echo "------------------------------------------------------------------------"
                break            
            else
                echo "$(date +'%F %H:%M:%S') Status: $FIND($STATUS_CHECK)"
                echo "------------------------------------------------------------------------"
            fi
            sleep 3
        done
    done 
    #echo "Press any key to move on"
    #read input
}

# **********************************************************************************
# Execution
# **********************************************************************************

initLog

echo "************************************"
echo " Set environment"
echo "************************************"
setEnvironmentVariablesCI

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
echo " Delete application operator OLM deployment"
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
deleteNamespacesRelatedToApplicationOperator
deleteDatabaseInstance
deleteDatabaseOperator
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