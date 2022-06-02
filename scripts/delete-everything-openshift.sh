#!/bin/bash

# **************** Global variables

export ROOT_FOLDER=$(cd $(dirname $0); cd ..; pwd)
export DATABASE_TEMPLATE_FOLDER=$ROOT_FOLDER/scripts/database-operator-templates
export APPLICATION_TEMPLATE_FOLDER=$ROOT_FOLDER/scripts/application-operator-templates
export LOGFILE_NAME="delete-all-openshift.log"
export SCRIPTNAME="delete-everything-openshift.sh"

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

function runCIconfiguation () {
    CONFIGURATION="ci"
    source $ROOT_FOLDER/versions.env &> temp.txt
    ERROR=$(cat temp.txt | grep 'source:' | awk '{print $1;}')
    VERIFICATION='source: no such file or directory'
    if [[ $ERROR == $VERIFICATION ]]; then
        customLog "ERROR" "YOU MUST have a versions.env file!"
        rm -f temp.txt
        exit 1
    else
        rm -f temp.txt
        echo "************************************"
        echo " Delete for $CONFIGURATION configuration"
        echo "************************************"
        echo "************************************"
        echo " Delete microservice application ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config:($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteMicroserviceApplicationInstance

        echo "************************************"
        echo " Delete database instance ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config:($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteDatabaseInstance

        echo "************************************"
        echo " Delete database operator ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config:($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteDatabaseOperator 

        echo "************************************"
        echo " Delete OLM deployments ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config:($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteOLMdeployment

        echo "************************************"
        echo " Delete namespaces related to application operator ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config:($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteNamespacesRelatedToApplicationOperator

        echo "************************************"
        echo " Delete database application ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config:($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteNamespacesRelatedToDatabaseOperator
    fi 
}

function runLocalConfiguation () {
    CONFIGURATION="local"
    source $ROOT_FOLDER/versions_local.env &> temp.txt
    ERROR=$(cat temp.txt | grep 'source:' | awk '{print $1;}')
    VERIFICATION='source: no such file or directory'
    if [[ $ERROR == $VERIFICATION ]]; then
        customLog "ERROR" "$ERROR"
        rm -f temp.txt
        break
    else
        rm -f temp.txt
        echo "************************************"
        echo " Delete for $CONFIGURATION configuration"
        echo "************************************"
        echo "************************************"
        echo " Delete microservice application ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config:($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteMicroserviceApplicationInstance

        echo "************************************"
        echo " Delete database instance ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config:($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteDatabaseInstance

        echo "************************************"
        echo " Delete database operator ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config:($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteDatabaseOperator 

        echo "************************************"
        echo " Delete OLM deployments ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config:($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteOLMdeployment

        echo "************************************"
        echo " Delete namespaces related to application operator ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config:($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteNamespacesRelatedToApplicationOperator

        echo "************************************"
        echo " Delete database application ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config:($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteNamespacesRelatedToDatabaseOperator
    fi 
}

function deletePrometheusConfiguration () {
    

    oc delete -f $ROOT_FOLDER/prometheus/openshift/

    echo "*** delete secrets"
    oc delete --force secret prometheus-token-secret -n openshift-operators
    oc delete --force secret prometheus-token-secret -n application-beta
    oc get secret prometheus-token-secret -n openshift-operators
    oc get secret prometheus-token-secret -n application-beta
    
    TYPE='Info'
    INFO='deletePrometheusConfiguration -> was executed'
    customLog $TYPE $INFO
}

function deleteInstallPlan () {
  
  array=("operator-database.v0.0.1" "operator-application.v0.0.1")
  namespace="openshift-operators"
  oc get installplans -n $namespace
  for i in "${array[@]}"
    do 
        echo ""
        echo "------------------------------------------------------------------------"
        echo "Check $i"
        while :
        do
            FIND=$i
            STATUS_SUCCESS="$FIND"
            STATUS_CHECK=$(kubectl get installplans -n $namespace | grep "$FIND" | awk '{print $2;}' | sed 's/"//g' | sed 's/,//g')
            INSTALLPLAN=$(kubectl get installplans -n $namespace | grep "$FIND" | awk '{print $1;}' | sed 's/"//g' | sed 's/,//g')
            echo "Status: $STATUS_CHECK"
            if [[ "$STATUS_CHECK" == "$STATUS_SUCCESS" ]]; then
                echo "$(date +'%F %H:%M:%S') $INSTALLPLAN Status: $FIND is found and will be deleted"
                oc delete --force installplans $INSTALLPLAN -n $namespace
                echo "------------------------------------------------------------------------"
            elif [[ "$STATUS_CHECK" == "" ]]; then
                echo "$(date +'%F %H:%M:%S') No installplan for: $FIND is found."
                echo "------------------------------------------------------------------------"
                break             
            elif [[ $j -eq $max_retrys ]]; then
                echo "$(date +'%F %H:%M:%S') Error during the deletion of the installplans"
                echo "$(date +'%F %H:%M:%S') Please verify the your system!"
                echo "------------------------------------------------------------------------"
                break               
            else
                echo "$(date +'%F %H:%M:%S') $FIND Status: ($STATUS_CHECK)"
                echo "------------------------------------------------------------------------"
            fi
            sleep 3
        done
    done 

    TYPE='Info'
    INFO='deleteInstallPlan -> was executed'
    customLog $TYPE $INFO
}

function deleteMicroserviceApplicationInstance () { 
    
    cd $ROOT_FOLDER/operator-application

    kubectl delete -f config/samples/application.sample_v1beta1_application.yaml
    kubectl delete -f config/samples/application.sample_v1alpha1_application.yaml
    
    kubectl get application -n application-beta
    kubectl get application -n application-alpha

    TYPE='Info'
    INFO='deleteMicroserviceApplicationInstance -> was executed'
    customLog $TYPE $INFO

    #echo "Press any key to move on"
    #read input
}

function deleteOLMdeployment () {
    namespace=openshift-operators

    # Application
    CATALOG_NAME="$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_CATALOG"
    sed "s+APPLICATION_CATALOG_IMAGE+$CATALOG_NAME+g" $APPLICATION_TEMPLATE_FOLDER/openshift-application-catalogsource-TEMPLATE.yaml > $ROOT_FOLDER/scripts/openshift-application-catalogsource.yaml
    cp -nf $APPLICATION_TEMPLATE_FOLDER/openshift-application-subscription-TEMPLATE.yaml $ROOT_FOLDER/scripts/openshift-application-subscription.yaml 
   
    kubectl delete -f $ROOT_FOLDER/scripts/openshift-application-subscription.yaml -n $namespace
    kubectl delete -f $ROOT_FOLDER/scripts/openshift-application-catalogsource.yaml -n $namespace
    
    rm -f $ROOT_FOLDER/scripts/openshift-application-catalogsource.yaml
    rm -f $ROOT_FOLDER/scripts/openshift-application-subscription.yaml
 
    kubectl get catalogsource -n $namespace
    kubectl get subscription -n $namespace
    oc get subscription --all-namespaces
    
    echo "*** delete subscription and catalogsource application"
    kubectl delete --force subscriptions operator-application-v0-0-1-sub -n $namespace  
    kubectl delete --force catalogsource operator-application-catalog -n $namespace 
    
    oc get clusterserviceversion -all-namespaces
    deleteApplicationOperatorCSVs
    oc get clusterserviceversion | grep operator-application.v0.0.1 -n $namespace

    # Database
    CATALOG_NAME="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_CATALOG"
    sed "s+DATABASE_CATALOG_IMAGE+$CATALOG_NAME+g" $DATABASE_TEMPLATE_FOLDER/openshift-database-catalogsource-TEMPLATE.yaml > $ROOT_FOLDER/scripts/openshift-database-catalogsource.yaml
    cp -nf $DATABASE_TEMPLATE_FOLDER/openshift-database-subscription-TEMPLATE.yaml $ROOT_FOLDER/scripts/openshift-database-subscription.yaml 
    
    echo "*** delete subscription and catalogsource database"
    kubectl delete --force subscriptions operator-database-v0-0-1-sub -n $namespace  
    kubectl delete --force catalogsource operator-database-catalog -n $namespace
    rm -f $ROOT_FOLDER/scripts/openshift-database-catalogsource.yaml
    rm -f $ROOT_FOLDER/scripts/openshift-database-subscription.yaml
     
    kubectl get catalogsource -n $namespace
    kubectl get subscription -n $namespace

    oc delete subscription operator-database-v0-0-1-sub -n $namespace
    oc delete subscription operator-database-v0-0-1-sub -n $namespace
    oc get subscription --all-namespaces

    echo "*** delete clusterserviceversion database"
    oc delete --force clusterserviceversion operator-database.v0.0.1 -n $namespace
    oc get clusterserviceversion | grep operator-database.v0.0.1 -n $namespace

    echo "*** delete cluster service versions"
    deleteDatabaseOperatorCSVs 

    echo "*** delete subscription and catalogsource database"
    kubectl delete -f $ROOT_FOLDER/scripts/openshift-database-subscription.yaml
    kubectl delete -f $ROOT_FOLDER/scripts/openshift-database-catalogsource.yaml
   
    kubectl get catalogsource -n $namespace
    kubectl get subscription -n $namespace

    echo "*** delete clusterserviceversion database"
    kubectl delete -f $ROOT_FOLDER/bundle/manifests/operator-database.clusterserviceversion.yaml
    kubectl get clusterserviceversion operator-database.v0.0.1

    TYPE='Info'
    INFO='deleteOLMdeployment -> was executed'
    customLog $TYPE $INFO

    rm -f $ROOT_FOLDER/scripts/openshift-database-catalogsource.yaml
    rm -f $ROOT_FOLDER/scripts/openshift-database-subsciption.yaml 

    #kubectl delete installplans -n openshift-operators --all
    #echo "Press any key to move on"
    #read input
}

function deleteNamespacesRelatedToApplicationOperator () {
    
    echo "*** delete project application"
    oc delete --force project application-alpha
    oc delete --force project application-beta

    export max_retrys=9
    array=("application-alpha" "application-beta")
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
                    echo "$(date +'%F %H:%M:%S') Error during the deletion!"
                    echo "$(date +'%F %H:%M:%S') Please verify your cluster and the existing operator installation!"
                    echo "------------------------------------------------------------------------"
                    break            
                else
                    echo "$(date +'%F %H:%M:%S') Status: $FIND($STATUS_CHECK)"
                    echo "------------------------------------------------------------------------"
                fi
                sleep 3
            done
        done 
    
    TYPE='Info'
    INFO='deleteNamespacesRelatedToApplicationOperator -> was executed'
    customLog $TYPE $INFO

    #echo "Press any key to move on"
    #read input
}

function deleteDatabaseInstance () {
    namespace=database
    cd $ROOT_FOLDER/operator-database

    echo "*** delete database instances"
    kubectl delete -f config/samples/database.sample_v1alpha1_database.yaml
    kubectl delete -f config/samples/database.sample_v1alpha1_databasebackup.yaml
    kubectl delete -f config/samples/database.sample_v1alpha1_databasecluster.yaml

    kubectl get databasecluster database -n $namespace

    TYPE='Info'
    INFO='deleteDatabaseInstance -> was executed'
    customLog $TYPE $INFO
    #echo "Press any key to move on"
    #read input
}

function deleteDatabaseOperatorCSVs() {

  array=("operator-database.v0.0.1")
  export STATUS_SUCCESS=""
  for i in "${array[@]}"
    do 
        echo ""
        echo "------------------------------------------------------------------------"
        echo "Check $i"
        export FIND=$i
        while :
        do               
           STATUS_CHECK=$(kubectl get clusterserviceversion --all-namespaces | grep $FIND | awk '{print $1;}' |  head -n 1 )
           echo "*** Status: $STATUS_CHECK"
           if [[ "$STATUS_CHECK" == "$STATUS_SUCCESS" ]]; then
                echo "$(date +'%F %H:%M:%S') Status: $FIND is deleted"
                echo "------------------------------------------------------------------------"
                break           
            else
                NAMESPACE="$STATUS_CHECK"
                echo "*** Namespace: $NAMESPACE"
                echo "*** Find: $FIND"
                STATUS_CHECK=$(kubectl get clusterserviceversion "$FIND" -n "$NAMESPACE" | grep "$FIND" | awk '{print $1;}')
                echo "*** Status check: $STATUS_CHECK"
                if [[ "$STATUS_CHECK" == "$FIND" ]]; then
                    kubectl -n $NAMESPACE delete clusterserviceversion $FIND
                    echo "$(date +'%F %H:%M:%S') Status: $NAMESPACE($FIND) is deleted"
                    echo "------------------------------------------------------------------------"
                else 
                   echo "$(date +'%F %H:%M:%S') Error: Status: $NAMESPACE($FIND)"
                   echo "Can't delete $FIND in $NAMESPACE!"
                   echo "------------------------------------------------------------------------"
                fi
            fi
            sleep 2
        done
    done

}

function deleteApplicationOperatorCSVs() {
  kubectl get pod -n openshift-operators
  array=("operator-application.v0.0.1")
  export STATUS_SUCCESS=""
  for i in "${array[@]}"
    do 
        echo ""
        echo "------------------------------------------------------------------------"
        echo "Check $i"
        export FIND=$i
        while :
        do               
           STATUS_CHECK=$(kubectl get clusterserviceversion --all-namespaces | grep $FIND | awk '{print $1;}' |  head -n 1 )
           echo "*** Status: $STATUS_CHECK"
           if [[ "$STATUS_CHECK" == "$STATUS_SUCCESS" ]]; then
                echo "$(date +'%F %H:%M:%S') Status: $FIND is deleted"
                echo "------------------------------------------------------------------------"
                break           
            else
                NAMESPACE="$STATUS_CHECK"
                echo "*** Namespace: $NAMESPACE"
                echo "*** Find: $FIND"
                STATUS_CHECK=$(kubectl get clusterserviceversion "$FIND" -n "$NAMESPACE" | grep "$FIND" | awk '{print $1;}')
                echo "*** Status check: $STATUS_CHECK"
                if [[ "$STATUS_CHECK" == "$FIND" ]]; then
                    kubectl -n $NAMESPACE delete clusterserviceversion $FIND
                    echo "$(date +'%F %H:%M:%S') Status: $NAMESPACE($FIND) is deleted"
                    echo "------------------------------------------------------------------------"
                else 
                   echo "$(date +'%F %H:%M:%S') Error: Status: $NAMESPACE($FIND)"
                   echo "Can't delete $FIND in $NAMESPACE!"
                   echo "------------------------------------------------------------------------"
                fi
            fi
            sleep 2
        done
    done
}

function deleteDatabaseOperator () {
     
    echo "*** delete subcription and catalogsource"
    kubectl delete -f $ROOT_FOLDER/scripts/openshift-database-subscription.yaml 
    kubectl delete -f $ROOT_FOLDER/scripts/openshift-database-catalogsource.yaml
    
    echo "*** delete customresourcedefinition"
    namespace=openshift-operators
    kubectl delete --force customresourcedefinition databasebackups.database.sample.third.party -n $namespace
    kubectl delete --force customresourcedefinition databases.database.sample.third.party -n $namespace
    kubectl delete --force customresourcedefinition databaseclusters.database.sample.third.party -n $namespace
    kubectl delete --force operators.operators.coreos.com operator-database.openshift-operators

    echo "*** delete deployment in namespace: $namespace"
    kubectl delete --force deployment operator-database-controller-manager -n $namespace
    echo "*** delete deployment"
    kubectl delete --force clusterrole operator-database-metrics-reader
    
    TYPE='Info'
    INFO='deleteDatabaseInstance -> was executed'
    customLog $TYPE $INFO   
    
    #echo "Press any key to move on"
    #read input
}

function deleteNamespacesRelatedToDatabaseOperator () {

    echo "*** delete project database"
    oc delete --force project database

    export max_retrys=9
    array=("database")
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
                    echo "$(date +'%F %H:%M:%S') Error deleting the database."
                    echo "$(date +'%F %H:%M:%S') Please verify your installation!"
                    echo "------------------------------------------------------------------------"
                    break            
                else
                    kubectl get namespace $FIND
                    echo "$(date +'%F %H:%M:%S') Status: $FIND($STATUS_CHECK)"
                    echo "------------------------------------------------------------------------"
                fi
                sleep 3
            done
        done 
    TYPE='Info'
    INFO='deleteNamespacesRelatedToDatabaseOperator -> was executed'
    customLog $TYPE $INFO
    
    #echo "Press any key to move on"
    #read input
}

function deleteCertManager () {
  kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.2/cert-manager.yaml

  export max_retrys=9
  array=("cert-manager")
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
           if [[ "$STATUS_CHECK" == "$STATUS_SUCCESS" ]]; then
                echo "$(date +'%F %H:%M:%S') Status: $FIND is deleted"
                echo "------------------------------------------------------------------------"
                break
            elif [[ $j -eq $max_retrys ]]; then
                echo "$(date +'%F %H:%M:%S') Please run 'delete-everything-kubernetes.sh' first!"
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

    TYPE='Info'
    INFO='deleteCertManager -> was executed'
    customLog $TYPE $INFO

    #echo "Press any key to move on"
    #read input
}

# **********************************************************************************
# Execution
# **********************************************************************************

echo "************************************"
echo " Init logfile $LOGFILE_NAME"
echo "************************************"
initLog

echo "************************************"
echo " Delete prometheus configuration"
echo "************************************"
deletePrometheusConfiguration

runCIconfiguation
runLocalConfiguation
deleteInstallPlan

echo "************************************"
echo " Delete cert manager"
echo "************************************"
deleteCertManager

echo "************************************"
echo " All delete commands were executed"
echo "************************************"