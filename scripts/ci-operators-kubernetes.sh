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
echo "-----------------------------"

# **************** Global variables

ROOT_FOLDER=$(cd $(dirname $0); cd ..; pwd)
export CI_CONFIG=$1
export VERSIONS_FILE=""

# **********************************************************************************
# Functions
# **********************************************************************************

function setEnvironmentVariables () {

    if [[ $CI_CONFIG == "local" ]]; then
        echo "*** Set versions_local.env file a input"
        source $ROOT_FOLDER/versions_local.env
        break
    elif [[ $CI_CONFIG == "ci" ]]; then
        echo "*** Set versions.env file a input"
        VERSIONS_FILE=versions_local.env
        break
    else 
        echo "*** Please select a valid option to run!"
        echo "*** Use 'local' for your local test."
        echo "*** Use 'ci' for your the ci test."
        echo "*** Example:"
        echo "*** sh ci-operators-kubernetes.sh local"
        exit 1
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
                echo "$(date +'%F %H:%M:%S') Please run `install-required-kubernetes-components.sh`first!"
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

  array=("catalog-operator" "olm-operator" "operatorhubio-catalog" )
  namespace=olm
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
                echo "$(date +'%F %H:%M:%S') Please run `install-required-kubernetes-components.sh`first!"
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

  array=("prometheus-operator" )
  namespace=monitoring
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
                echo "$(date +'%F %H:%M:%S') Please run `install-required-kubernetes-components.sh`first!"
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

function buildDatabaseOperator () {
    cd $ROOT_FOLDER/operator-database
    make generate
    make manifests
    # Build container
    make docker-build IMG="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"
    # Push container
    podman login $REGISTRY
    podman push "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"
}

function buildDatabaseOperatorBundle () {
    cd $ROOT_FOLDER/operator-database
    # Build bundle
    make bundle IMG="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"
    make bundle-build BUNDLE_IMG="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE"
    # Push container
    podman login $REGISTRY
    podman push "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE"
}

# **********************************************************************************
# Execution
# **********************************************************************************

echo "************************************"
echo " Set context"
echo "************************************"
setEnvironmentVariables

echo "************************************"
echo " Verify prerequisites"
echo "************************************"
verifyPreReqs

echo "************************************"
echo " Build 'database operator'"
echo " Push image to $REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"
echo "************************************"
buildDatabaseOperator

echo "************************************"
echo " Build 'database operator bundle'"
echo " Push image to $REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE"
echo "************************************"
buildDatabaseOperatorBundle