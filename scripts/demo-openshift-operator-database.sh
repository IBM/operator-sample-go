#!/bin/bash

# **********************************************************************************
# Set global variables using parameters
# **********************************************************************************

echo "************************************"
echo " Display parameter"
echo "************************************"
echo ""
echo "Parameter count : $@"
echo "Parameter zero 'name of the script': $0"
echo "---------------------------------"
echo "CI Configuration         : $1"
echo "Reset                    : $2"
echo "-----------------------------"

# **************** Global variables

export ROOT_FOLDER=$(cd $(dirname $0); cd ..; pwd)
export NAMESPACE=openshift-operators
export CI_CONFIG=$1
export RESET=$2
export VERSIONS_FILE=""
export DATABASE_TEMPLATE_FOLDER=$ROOT_FOLDER/scripts/database-operator-templates
export LOGFILE_NAME=demo-script-automation-openshift.log
export TEMP_FOLDER=temp
export SCRIPT_NAME=demo-openshift-operator-database.sh

# **********************************************************************************
# Functions
# **********************************************************************************

function customLog () {
    echo "Log parameter: $1"
    echo "Log parameter: $2"
    LOG_TYPE="$1"
    LOG_MESSAGE="$2"
    echo "$(date +'%F %H:%M:%S'): $LOG_TYPE" >> $ROOT_FOLDER/scripts/$LOGFILE_NAME
    echo "$LOG_MESSAGE" >> $ROOT_FOLDER/scripts/$LOGFILE_NAME
    echo "$(date +'%F %H:%M:%S'): ********************************************************" >> $ROOT_FOLDER/scripts/$LOGFILE_NAME
}

function logBuild () {
    TYPE="$1"
    INPUTFILE="$2"
    echo "*** Input: $INPUTFILE"

    INFO=$(cat "$INPUTFILE" | grep "Successfully" | awk '{print $1;}')
    if [[ $INFO == "Successfully" ]] ; then
      echo $INFO
      customLog "$TYPE" "$INFO"
    else 
      INFO=$(cat "$INPUTFILE")
      echo $INFO
      customLog "$TYPE" "$INFO"
      exit 1
    fi
}

function logInit () {
    TYPE="script"
    INFO="script: $SCRIPT_NAME"
    customLog "$TYPE" "$INFO"
}

function setEnvironmentVariables () {
 
    if [[ $CI_CONFIG == "local" ]]; then
        echo "*** Set versions_local.env file as input"
        source $ROOT_FOLDER/versions_local.env
        INFO="*** Using following registry: $REGISTRY/$ORG"
        echo $INFO
        customLog "$CI_CONFIG" "$INFO"
    elif [[ $CI_CONFIG == "demo" ]]; then
        echo "*** Set versions.env file as input"        
        source $ROOT_FOLDER/versions.env
        INFO="*** Using following registry: $REGISTRY/$ORG"
        echo $INFO
        customLog "$CI_CONFIG" "$INFO"
    else 
        echo "*** Please select a valid option to run!"
        echo "*** Use 'local' for your local test."
        echo "*** Use 'demo' for your demo test."
        echo "*** Example:"
        echo "*** sh $SCRIPT_NAME demo"
        exit 1
    fi
}

function resetAll () {

    if [[ $RESET == "reset" ]]; then
        echo "*** RESET OpenShift environment!"
        echo "*** DELETE all OpenShift compoments!"
        cd $ROOT_FOLDER/scripts
        bash $ROOT_FOLDER/scripts/delete-everything-openshift.sh
        
        sleep 2
        
        echo "*** Install required OpenShift compoments!"
        cd $ROOT_FOLDER/scripts
        bash $ROOT_FOLDER/scripts/install-required-openshift-components.sh
    fi
}

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
                echo "$(date +'%F %H:%M:%S') Please run `install-required-openshift-components.sh`first!"
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

function configureCRs_DatabaseOperator () {

    # Backup CR files
    cp $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasebackup.yaml $DATABASE_TEMPLATE_FOLDER/database.sample_v1alpha1_databasebackup.yaml-BACKUP
    cp $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasecluster.yaml $DATABASE_TEMPLATE_FOLDER/database.sample_v1alpha1_databasecluster.yaml-backup
   
    #Backup
    IMAGE_NAME="$REGISTRY/$ORG/$IMAGE_DATABASE_BACKUP"
    echo $IMAGE_NAME
    sed "s+DATABASE_BACKUP_IMAGE+$IMAGE_NAME+g" "$DATABASE_TEMPLATE_FOLDER/database.sample_v1alpha1_databasebackup-TEMPLATE.yaml" > "$ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasebackup.yaml"
    cat $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasebackup.yaml | grep "$IMAGE_DATABASE_BACKUP"
    IMAGE_NAME="$REGISTRY/$ORG/$IMAGE_DATABASE_SERVICE"
    
    #Cluster
    IMAGE_NAME="$REGISTRY/$ORG/$IMAGE_DATABASE_SERVICE" 
    echo $IMAGE_NAME
    sed "s+DATABASE_SERVICE_IMAGE+$IMAGE_NAME+g" $DATABASE_TEMPLATE_FOLDER/database.sample_v1alpha1_databasecluster-TEMPLATE.yaml > $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasecluster.yaml
    cat $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasecluster.yaml | grep "$IMAGE_DATABASE_BACKUP"
    
    # Put back backup files and delete backup
    cp $DATABASE_TEMPLATE_FOLDER/database.sample_v1alpha1_databasebackup.yaml-BACKUP $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasebackup.yaml 
    cp $DATABASE_TEMPLATE_FOLDER/database.sample_v1alpha1_databasecluster.yaml-backup $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasecluster.yaml
    rm -f $DATABASE_TEMPLATE_FOLDER/database.sample_v1alpha1_databasebackup.yaml-BACKUP
    rm -f $DATABASE_TEMPLATE_FOLDER/database.sample_v1alpha1_databasecluster.yaml-backup
}

function createOLMDatabaseOperatorYAMLs () {
    CATALOG_NAME="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_CATALOG"
    sed "s+DATABASE_CATALOG_IMAGE+$CATALOG_NAME+g" $DATABASE_TEMPLATE_FOLDER/openshift-database-catalogsource-TEMPLATE.yaml > $ROOT_FOLDER/scripts/openshift-database-catalogsource.yaml
    cp -nf $DATABASE_TEMPLATE_FOLDER/openshift-database-subscription-TEMPLATE.yaml $ROOT_FOLDER/scripts/openshift-database-subscription.yaml 
}

function deployDatabaseOperatorOLM () {
    kubectl create -f $ROOT_FOLDER/scripts/openshift-database-catalogsource.yaml 
    kubectl create -f $ROOT_FOLDER/scripts/openshift-database-subscription.yaml

    namespace=openshift-marketplace
    kubectl get catalogsource operator-database-catalog -n $namespace -oyaml
    kubectl get pods -n $namespace
    kubectl get all -n $namespace

    namespace=openshift-operators
    kubectl get subscriptions operator-database-v0-0-1-sub -n $namespace -oyaml
    kubectl get installplans -n $namespace
    kubectl get pods -n $namespace
    kubectl get all -n $namespace

    array=("operator-database-catalog")
    namespace=openshift-marketplace
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
                    Unable
                    echo "$(date +'%F %H:%M:%S') Status: $FIND($STATUS_CHECK)"
                    echo "------------------------------------------------------------------------"
                fi
                sleep 3
            done
        done

    array=("operator-database.v0.0.1")
    namespace=openshift-operators
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
    namespace=openshift-operators
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
    kubectl create ns database   
    kubectl create -f $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_database.yaml
    kubectl create -f $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasecluster.yaml
    kubectl get pods -n database
    
    array=("database-cluster-0" "database-cluster-1")
    namespace=database
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
    
    kubectl get databases/database -n database -oyaml
    
    rm -f $ROOT_FOLDER/scripts/temp.log
    kubectl get databases.database.sample.third.party/database -n database -oyaml > $ROOT_FOLDER/scripts/temp.log
    TYPE="*** Database operator info"
    INFO=$(cat  $ROOT_FOLDER/scripts/temp.log)
    echo $INFO
    customLog "$TYPE" "$INFO" 
}

function verifyDatabase() {
    TYPE="*** verify database - Database operator"
    rm -f $ROOT_FOLDER/scripts/temp.log
    kubectl exec -n database database-cluster-1 -- curl -s http://localhost:8089/persons > $ROOT_FOLDER/scripts/temp.log
    INFO=$(cat  $ROOT_FOLDER/scripts/temp.log)
    echo $INFO
    customLog "$TYPE" "$INFO"  
    kubectl exec -n database database-cluster-0 -- curl -s http://localhost:8089/api/leader > $ROOT_FOLDER/scripts/temp.log
    echo $INFO
    INFO=$(cat  $ROOT_FOLDER/scripts/temp.log)
    customLog "$TYPE" "$INFO"
    rm -f $ROOT_FOLDER/scripts/temp.log
}

# **********************************************************************************
# Execution
# **********************************************************************************

echo "************************************"
echo " Set context"
echo "************************************"
logInit
setEnvironmentVariables

resetAll

echo "************************************"
echo " Verify prerequisites"
echo "************************************"
verifyPreReqs

echo "************************************"
echo " Configure CR samples for the 'database operator'"
echo "************************************"
configureCRs_DatabaseOperator

echo "************************************"
echo " Create OLM yamls"
echo "************************************"
createOLMDatabaseOperatorYAMLs

echo "************************************"
echo " Deploy Database Operator OLM"
echo "************************************"
deployDatabaseOperatorOLM

echo "************************************"
echo " Create Database Instance"
echo "************************************"
createDatabaseInstance

echo "************************************"
echo " Verify Database Instance"
echo "************************************"
verifyDatabase