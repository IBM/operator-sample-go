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
export NAMESPACE=operators
export CI_CONFIG=$1
export VERSIONS_FILE=""
export APPLICATION_TEMPLATE_FOLDER=$ROOT_FOLDER/scripts/application-operator-templates
export LOGFILE_NAME=script-automation.log


# **********************************************************************************
# Functions
# **********************************************************************************

function customLog () {
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
      customLog "$TYPE" "$INFO"
    else 
      INFO=$(cat "$INPUTFILE")
      customLog "$TYPE" "$INFO"
      exit 1
    fi
}

function logInit () {
    TYPE="script"
    INFO="script: ci-create-operator-application-kubernetes.sh"
    customLog "$TYPE" "$INFO"
}

function setEnvironmentVariables () {
 
    if [[ $CI_CONFIG == "local" ]]; then
        echo "*** Set versions_local.env file as input"
        source $ROOT_FOLDER/versions_local.env
        INFO="*** Using following registry: $REGISTRY/$ORG"
        echo $INFO
        customLog "$CI_CONFIG" "$INFO"
    elif [[ $CI_CONFIG == "ci" ]]; then
        echo "*** Set versions.env file as input"        
        source $ROOT_FOLDER/versions.env
        INFO="*** Using following registry: $REGISTRY/$ORG"
        echo $INFO
        customLog "$CI_CONFIG" "$INFO"
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

function buildSimpleMicroservice () {
    cd $ROOT_FOLDER/simple-microservice
    podman build -t "$REGISTRY/$ORG/$IMAGE_MICROSERVICE" . > $ROOT_FOLDER/scripts/temp.log
    TYPE="buildSimpleMicroservice"
    INPUT="$ROOT_FOLDER/scripts/temp.log"
    logBuild "$TYPE" "$INPUT"
    rm -f $ROOT_FOLDER/scripts/temp.log
    podman login $REGISTRY
    podman push "$REGISTRY/$ORG/$IMAGE_MICROSERVICE" 
}

function buildApplicationScaler () {
    cd $ROOT_FOLDER/operator-application-scaler
    podman build -t "$REGISTRY/$ORG/$IMAGE_APPLICATION_SCALER" . > $ROOT_FOLDER/scripts/temp.log
    TYPE="buildApplicationScaler"
    INPUT="$ROOT_FOLDER/scripts/temp.log"
    logBuild "$TYPE" "$INPUT"
    rm -f $ROOT_FOLDER/scripts/temp.log
    podman login $REGISTRY
    podman push "$REGISTRY/$ORG/$IMAGE_APPLICATION_SCALER"
}

function configureCR_SimpleMicroservice () {
    IMAGE_NAME="$REGISTRY/$ORG/$IMAGE_MICROSERVICE"
    sed "s+SIMPLE_APPLICATION_IMAGE+$IMAGE_NAME+g" $APPLICATION_TEMPLATE_FOLDER/application.sample_v1alpha1_application-TEMPLATE.yaml > $ROOT_FOLDER/operator-application/config/samples/application.sample_v1alpha1_application.yaml
    sed "s+SIMPLE_APPLICATION_IMAGE+$IMAGE_NAME+g" $APPLICATION_TEMPLATE_FOLDER/application.sample_v1beta1_application-TEMPLATE.yaml > $ROOT_FOLDER/operator-application/config/samples/application.sample_v1beta1_application.yaml
}

function buildApplicationOperator () {
    cd $ROOT_FOLDER/operator-application
    make generate
    make manifests
    # Build container
    # make docker-build IMG="$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR"
    podman build -t "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR" . > $ROOT_FOLDER/scripts/temp.log
    TYPE="buildApplicationOperator"
    INPUT="$ROOT_FOLDER/scripts/temp.log"
    logBuild "$TYPE" "$INPUT"
    rm -f $ROOT_FOLDER/scripts/temp.log
    # Push container
    podman login $REGISTRY
    podman push "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR"
}

function buildApplicationOperatorBundle () {
    cd $ROOT_FOLDER/operator-application
    
    # Build bundle
    make bundle IMG="$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR"
    # Replace CSV and RBAC generate files with customized versions APPLICATION_OPERATOR_IMAGE 
    APPLICATION_OPERATOR_IMAGE="$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR"
    sed "s+APPLICATION_OPERATOR_IMAGE+$APPLICATION_OPERATOR_IMAGE+g" $APPLICATION_TEMPLATE_FOLDER/operator-application.clusterserviceversion-TEMPLATE.yaml > $ROOT_FOLDER/operator-application/bundle/manifests/operator-application.clusterserviceversion.yaml

    OPERATOR_NAMESPACE=operators
    sed "s+OPERATOR_NAMESPACE+$OPERATOR_NAMESPACE+g" $APPLICATION_TEMPLATE_FOLDER/operator-application-role_binding_patch_TEMPLATE.yaml > $ROOT_FOLDER/operator-database/config/rbac/role_binding.yaml
    cp -nf $APPLICATION_TEMPLATE_FOLDER/operator-application-role_patch_TEMPLATE.yaml $ROOT_FOLDER/operator-application/config/rbac/role.yaml
    
    # make bundle-build BUNDLE_IMG="$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_BUNDLE"
    podman build -f bundle.Dockerfile -t "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_BUNDLE" . > $ROOT_FOLDER/scripts/temp.log
    TYPE="buildApplicationBundleOperator"
    INPUT="$ROOT_FOLDER/scripts/temp.log"
    logBuild "$TYPE" "$INPUT"
    rm -f $ROOT_FOLDER/scripts/temp.log
    
    # Push container
    podman login $REGISTRY
    podman push "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_BUNDLE"
}

function buildApplicationOperatorCatalog () {
    cd $ROOT_FOLDER/operator-application
    # make catalog-build CATALOG_IMG="$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_CATALOG" BUNDLE_IMGS="$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_BUNDLE"
    $ROOT_FOLDER/operator-application/bin/opm index add --build-tool podman --mode semver --tag "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_CATALOG" --bundles "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_BUNDLE" > $ROOT_FOLDER/scripts/temp.log
    TYPE="buildApplicationOperatorCatalog"
    INPUT="$(cat $ROOT_FOLDER/scripts/temp.log)"
    customLog "$TYPE" "$INPUT"
    rm -f $ROOT_FOLDER/scripts/temp.log
    podman login $REGISTRY
    podman push "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_CATALOG"
}

function createOLMApplicationOperatorYAMLs () {
    CATALOG_NAME="$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_CATALOG"
    sed "s+APPLICATION_CATALOG_IMAGE+$CATALOG_NAME+g" $APPLICATION_TEMPLATE_FOLDER/kubernetes-application-catalogsource-TEMPLATE.yaml > $ROOT_FOLDER/scripts/kubernetes-application-catalogsource.yaml
}

function deployApplicationOperatorOLM () {
    kubectl create -f $ROOT_FOLDER/scripts/kubernetes-application-catalogsource.yaml
    kubectl create -f $ROOT_FOLDER/scripts/kubernetes-application-subscription.yaml

    kubectl get catalogsource operator-application-catalog -n $NAMESPACE -oyaml
    kubectl get subscriptions operator-application-v0-0-1-sub -n $NAMESPACE -oyaml
    kubectl get installplans -n $NAMESPACE
    kubectl get pods -n $NAMESPACE
    kubectl get all -n $NAMESPACE

    array=("operator-application-catalog")
    namespace=operators
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

    array=("operator-application.v0.0.1")
    namespace=operators
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

    array=("operator-application-controller-manager" )
    namespace=operators
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

function createApplicationInstance () {
    kubectl get pods -n operators | grep "application"
    kubectl apply -f $ROOT_FOLDER/operator-application/config/samples/application.sample_v1beta1_application.yaml
    kubectl get pods -n operators | grep "application-beta"
}

function verifyApplication() {
    
    TYPE="*** verify database - Database operator"
    kubectl exec -n database database-cluster-1 -- curl -s http://localhost:8089/persons > $ROOT_FOLDER/scripts/temp.log
    INFO=$(cat  $ROOT_FOLDER/scripts/temp.log)
    customLog "$TYPE" "$INFO"  
    kubectl exec -n database database-cluster-0 -- curl -s http://localhost:8089/api/leader > $ROOT_FOLDER/scripts/temp.log
    INFO=$(cat  $ROOT_FOLDER/scripts/temp.log)
    customLog "$TYPE" "$INFO"
    rm -f $ROOT_FOLDER/scripts/temp.log

    array=("application-deployment-microservice" )
    namespace=application-beta
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
    TYPE="*** verify application - Application operator"
    sleep 2
    kubectl exec -n application-beta $(kubectl get pods -n application-beta | awk '/application-deployment-microservice/ {print $1;exit}') --container application-microservice -- curl http://localhost:8081/hello > $ROOT_FOLDER/scripts/temp.log
    INFO=$(cat  $ROOT_FOLDER/scripts/temp.log)
    customLog "$TYPE" "$INFO"
    kubectl logs -n $NAMESPACE $(kubectl get pods -n $NAMESPACE | awk '/operator-application-controller-manager/ {print $1;exit}') -c manager > $ROOT_FOLDER/scripts/temp.log
    INFO=$(cat  $ROOT_FOLDER/scripts/temp.log)
    customLog "$TYPE" "$INFO"
}

# **********************************************************************************
# Execution
# **********************************************************************************

echo "************************************"
echo " Set context"
echo "************************************"
logInit
setEnvironmentVariables

echo "************************************"
echo " Verify prerequisites"
echo "************************************"
verifyPreReqs

echo "************************************"
echo " Build 'simple microserice'"
echo " Push image to $REGISTRY/$ORG/$IMAGE_MICROSERVICE"
echo "************************************"
buildSimpleMicroservice 

echo "************************************"
echo " Build 'application scaler'"
echo " Push image to $REGISTRY/$ORG/$IMAGE_APPLICATION_SCALER"
echo "************************************"
buildApplicationScaler

echo "************************************"
echo " Build 'application operator'"
echo " Push image to $REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR"
echo "************************************"
buildApplicationOperator

echo "************************************"
echo " Build 'application operator bundle'"
echo " Push image to $REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_BUNDLE"
echo "************************************"
buildApplicationOperatorBundle

echo "************************************"
echo " Build 'application operator catalog'"
echo " Push image to $REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_CATALOG"
echo "************************************"
buildApplicationOperatorCatalog

echo "************************************"
echo " Create OLM yamls"
echo "************************************"
createOLMApplicationOperatorYAMLs

echo "************************************"
echo " Deploy Application Operator OLM"
echo "************************************"
deployApplicationOperatorOLM

echo "************************************"
echo " Configure configure CR for Application Operator"
echo "************************************"
configureCR_SimpleMicroservice

echo "************************************"
echo " Create Application Instance"
echo "************************************"
createApplicationInstance

echo "************************************"
echo " Verify Application Instance"
echo "************************************"
verifyApplication