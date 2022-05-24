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
        INFO="Config: ($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteMicroserviceApplicationInstance

        echo "************************************"
        echo " Delete database operator ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config: ($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteDatabaseOperator 

        echo "************************************"
        echo " Delete OLM deployments ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config: ($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteOLMdeployment

        echo "************************************"
        echo " Delete database instance ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config: ($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteDatabaseInstance

        echo "************************************"
        echo " Delete namespaces related to application operator ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config: ($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteNamespacesRelatedToApplicationOperator

        echo "************************************"
        echo " Delete database application ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config: ($CONFIGURATION)"
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
        INFO="Config: ($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteMicroserviceApplicationInstance

        echo "************************************"
        echo " Delete database operator ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config: ($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteDatabaseOperator 

        echo "************************************"
        echo " Delete OLM deployments ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config: ($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteOLMdeployment

        echo "************************************"
        echo " Delete database instance ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config: ($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteDatabaseInstance

        echo "************************************"
        echo " Delete namespaces related to application operator ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config: ($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteNamespacesRelatedToApplicationOperator

        echo "************************************"
        echo " Delete database application ($CONFIGURATION)"
        echo "************************************"
        TYPE='Configuration'
        INFO="Config: ($CONFIGURATION)"
        customLog $TYPE $INFO
        deleteNamespacesRelatedToDatabaseOperator
    fi 
}

function deletePrometheusConfiguration () {
    oc delete -f $ROOT_FOLDER/prometheus/openshift/
    oc delete secret prometheus-token-secret -n openshift-operators
    oc delete secret prometheus-token-secret -n application-beta
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
  export STATUS_SUCCESS="tru"
  for i in "${array[@]}"
    do 
        echo ""
        echo "------------------------------------------------------------------------"
        echo "Check $i"
        while :
        do
            FIND=$i
            STATUS_CHECK=$(kubectl get installplans -n $namespace | grep "$FIND" | awk '{print $3;}' | sed 's/"//g' | sed 's/,//g')
            INSTALLPLAN=$(kubectl get installplans -n $namespace | grep "$FIND" | awk '{print $1;}' | sed 's/"//g' | sed 's/,//g')
            echo "Status: $STATUS_CHECK"
            STATUS_VERIFICATION=$(echo "$STATUS_CHECK" | grep $STATUS_SUCCESS)
            if [ "$STATUS_VERIFICATION" = "$STATUS_SUCCESS" ]; then
                echo "$(date +'%F %H:%M:%S') Status: $FIND is found"
                oc delete installplans $INSTALLPLAN -n $namespace
                echo "------------------------------------------------------------------------"
            elif [[ $j -eq $max_retrys ]]; then
                echo "$(date +'%F %H:%M:%S') Please run `install-required-kubernetes-components.sh`first!"
                echo "$(date +'%F %H:%M:%S') Prereqs aren't ready!"
                echo "------------------------------------------------------------------------"
                break               
            else
                echo "$(date +'%F %H:%M:%S') Status: $FIND: ($INSTALLPLAN) Status: ($STATUS_CHECK)"
                echo "------------------------------------------------------------------------"
            fi
            sleep 3
        done
    done 

    oc delete -f $ROOT_FOLDER/prometheus/openshift/
    oc delete secret prometheus-token-secret -n openshift-operators
    oc delete secret prometheus-token-secret -n application-beta
    oc get secret prometheus-token-secret -n openshift-operators
    oc get secret prometheus-token-secret -n application-beta
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

    kubectl delete -f $ROOT_FOLDER/scripts/openshift-application-catalogsource.yaml -n $namespace
    kubectl delete -f $ROOT_FOLDER/scripts/openshift-application-subscription.yaml -n $namespace
    kubectl get catalogsource -n $namespace
    kubectl get subscription -n $namespace

    kubectl delete subscriptions operator-application-v0-0-1-sub -n $namespace  
    kubectl delete catalogsource operator-application-catalog -n $namespace 

    oc delete clusterserviceversion operator-application.v0.0.1 -n $namespace
    oc get clusterserviceversion | grep operator-application.v0.0.1 -n $namespace

    # Database
    CATALOG_NAME="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_CATALOG"
    sed "s+DATABASE_CATALOG_IMAGE+$CATALOG_NAME+g" $DATABASE_TEMPLATE_FOLDER/openshift-database-catalogsource-TEMPLATE.yaml > $ROOT_FOLDER/scripts/openshift-database-catalogsource.yaml
    cp -nf $DATABASE_TEMPLATE_FOLDER/openshift-database-subscription-TEMPLATE.yaml $ROOT_FOLDER/scripts/openshift-database-subscription.yaml 

    kubectl delete subscriptions operator-database-v0-0-1-sub -n $namespace  
    kubectl delete catalogsource operator-database-catalog -n $namespace
    kubectl get catalogsource -n $namespace
    kubectl get subscription -n$namespace

    oc delete clusterserviceversion operator-database.v0.0.1 -n $namespace
    oc get clusterserviceversion | grep operator-database.v0.0.1 -n $namespace

    kubectl delete -f $ROOT_FOLDER/scripts/openshift-database-catalogsource.yaml
    kubectl delete -f $ROOT_FOLDER/scripts/openshift-database-subscription.yaml
    kubectl get catalogsource -n $namespace
    kubectl get subscription -n $namespace

    kubectl delete -f $ROOT_FOLDER/bundle/manifests/operator-database.clusterserviceversion.yaml
    kubectl get clusterserviceversion operator-database.v0.0.1

    TYPE='Info'
    INFO='deleteOLMdeployment -> was executed'
    customLog $TYPE $INFO

    #kubectl delete installplans -n openshift-operators --all
    #echo "Press any key to move on"
    #read input
}

function deleteNamespacesRelatedToApplicationOperator () {
    oc delete project application-alpha
    oc delete project application-beta

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
            STATUS_CHECK=$(kubectl get namespace -n $FIND | grep $FIND | awk '{print $2;}')
            echo "Status: $STATUS_CHECK"
            if [ "$STATUS_CHECK" = "$STATUS_SUCCESS" ]; then
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
    INFO='deleteNamespacesRelatedToApplicationOperator -> was executed'
    customLog $TYPE $INFO

    #echo "Press any key to move on"
    #read input
}

function deleteDatabaseInstance () {
    namespace=database
    cd $ROOT_FOLDER/operator-database
    kubectl delete -f config/samples/database.sample_v1alpha1_database.yaml
    kubectl get databasecluster database -n $namespace

    TYPE='Info'
    INFO='deleteDatabaseInstance -> was executed'
    customLog $TYPE $INFO
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
    kubectl delete operators.operators.coreos.com operator-database.openshift-operators

    kubectl delete deployment operator-database-controller-manager -n $namespace
    kubectl delete clusterserviceversion operator-database.v0.0.1 
    kubectl delete clusterrole operator-database-metrics-reader

    TYPE='Info'
    INFO='deleteDatabaseInstance -> was executed'
    customLog $TYPE $INFO   
    
    #echo "Press any key to move on"
    #read input
}

function deleteNamespacesRelatedToDatabaseOperator () {
    oc delete project database

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
            STATUS_CHECK=$(kubectl get namespace -n $FIND | grep $FIND | awk '{print $2;}')
            echo "Status: $STATUS_CHECK"
            if [ "$STATUS_CHECK" = "$STATUS_SUCCESS" ]; then
                    echo "$(date +'%F %H:%M:%S') Status: $FIND is deleted"
                    echo "------------------------------------------------------------------------"
                    break
                elif [[ $j -eq $max_retrys ]]; then
                    echo "$(date +'%F %H:%M:%S') Please run 'delete-everything-openshift.sh' first!"
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
           STATUS_CHECK=$(kubectl get namespace -n $FIND | grep $FIND | awk '{print $2;}')
           echo "Status: $STATUS_CHECK"
           if [ "$STATUS_CHECK" = "$STATUS_SUCCESS" ]; then
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

echo "************************************"
echo " Delete cert manager"
echo "************************************"
deleteCertManager

echo "************************************"
echo " All delete commands were executed"
echo "************************************"