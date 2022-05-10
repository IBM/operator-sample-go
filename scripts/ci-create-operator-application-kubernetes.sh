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
NAMESPACE=operators
export CI_CONFIG=$1
export VERSIONS_FILE=""
export APPLICATION_TEMPLATE_FOLDER=$ROOT_FOLDER/scripts/application-operator-templates


# **********************************************************************************
# Functions
# **********************************************************************************

function setEnvironmentVariables () {

    if [[ $CI_CONFIG == "local" ]]; then
        echo "*** Set versions_local.env file a input"
        source $ROOT_FOLDER/versions_local.env
    elif [[ $CI_CONFIG == "ci" ]]; then
        echo "*** Set versions.env file a input"        
        source $ROOT_FOLDER/versions.env
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
    podman build -t "$REGISTRY/$ORG/$IMAGE_MICROSERVICE" .
    podman login $REGISTRY
    podman push "$REGISTRY/$ORG/$IMAGE_MICROSERVICE"
}

function buildApplicationScaler () {
    cd $ROOT_FOLDER/operator-application-scaler
    podman build -t "$REGISTRY/$ORG/$IMAGE_APPLICATION_SCALER" .
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
    podman build -t "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR" .
    # Push container
    podman login $REGISTRY
    podman push "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR"
}

function buildApplicationOperatorBundle () {
    cd $ROOT_FOLDER/operator-application
    
    # Build bundle
    make bundle IMG="$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR"
    # Replace CSV and RBAC generate files with customized versions
    cp -nf $APPLICATION_TEMPLATE_FOLDER/operator-application.clusterserviceversion-TEMPLATE.yaml $ROOT_FOLDER/operator-application/bundle/manifests/operator-application.clusterserviceversion.yaml
    OPERATOR_NAMESPACE=operators
    sed "s+OPERATOR_NAMESPACE+$OPERATOR_NAMESPACE+g" $APPLICATION_TEMPLATE_FOLDER/operator-database-role_binding_patch_TEMPLATE.yaml > $ROOT_FOLDER/operator-database/config/rbac/role_binding.yaml
    cp -nf $APPLICATION_TEMPLATE_FOLDER/operator-application-role_patch_TEMPLATE.yaml $ROOT_FOLDER/operator-application/config/rbac/role.yaml
    
    # make bundle-build BUNDLE_IMG="$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_BUNDLE"
    podman build -f bundle.Dockerfile -t "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_BUNDLE" .
    
    # Push container
    podman login $REGISTRY
    podman push "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_BUNDLE"
}

function buildApplicationOperatorCatalog () {
    cd $ROOT_FOLDER/operator-application
    # make catalog-build CATALOG_IMG="$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_CATALOG" BUNDLE_IMGS="$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_BUNDLE"
    $ROOT_FOLDER/operator-application/bin/opm index add --build-tool podman --mode semver --tag "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_CATALOG" --bundles "$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_BUNDLE"
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
    kubectl apply -f $ROOT_FOLDER/operator-application/config/samples/application.sample_v1beta1_application.yaml
}

function verifyApplication() {
    echo "*** verify database"

    kubectl get databasecluster/databasecluster-sample -oyaml
    
    kubectl exec -n database database-cluster-1 -- curl -s http://localhost:8089/persons
    LOG="Database operator:"
    echo $LOG > $ROOT_FOLDER/scripts/script-automation.log
    LOG="******************"
    echo $LOG >> $ROOT_FOLDER/scripts/script-automation.log
    LOG=""
    echo $LOG >> $ROOT_FOLDER/scripts/script-automation.log
    LOG=$(kubectl exec -n database database-cluster-1 -- curl -s http://localhost:8089/persons)
    echo $LOG >> $ROOT_FOLDER/scripts/script-automation.log
    kubectl exec -n database database-cluster-0 -- curl -s http://localhost:8089/api/leader
    LOG=$(kubectl exec -n database database-cluster-0 -- curl -s http://localhost:8089/api/leader)
    echo $LOG >> $ROOT_FOLDER/scripts/script-automation.log

    echo "*** verify application"
    LOG="Application operator:"
    echo $LOG >> $ROOT_FOLDER/scripts/script-automation.log
    LOG="******************"
    echo $LOG >> $ROOT_FOLDER/scripts/script-automation.log
    LOG=""
    echo $LOG >> $ROOT_FOLDER/scripts/script-automation.log
    kubectl exec -n application-beta $(kubectl get pods -n application-beta | awk '/application-deployment-microservice/ {print $1;exit}') --container application-microservice -- curl http://localhost:8081/hello
    LOG=$(kubectl exec -n application-beta $(kubectl get pods -n application-beta | awk '/application-deployment-microservice/ {print $1;exit}') --container application-microservice -- curl http://localhost:8081/hello)
    echo $LOG >> $ROOT_FOLDER/scripts/script-automation.log
    kubectl logs -n $NAMESPACE $(kubectl get pods -n $NAMESPACE | awk '/operator-application-controller-manager/ {print $1;exit}') -c manager
    LOG=$(kubectl logs -n $NAMESPACE $(kubectl get pods -n $NAMESPACE | awk '/operator-application-controller-manager/ {print $1;exit}') -c manager)
    echo $LOG >> $ROOT_FOLDER/scripts/script-automation.log
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