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

export ROOT_FOLDER=$(cd $(dirname $0); cd ..; pwd)
export NAMESPACE=openshift-operators
export CI_CONFIG=$1
export VERSIONS_FILE=""
export APPLICATION_TEMPLATE_FOLDER=$ROOT_FOLDER/scripts/application-operator-templates
export LOGFILE_NAME=demo-script-automation-openshift.log
export TEMP_FOLDER=temp
export SCRIPT_NAME=demo-openshift-operator-application.sh


# **********************************************************************************
# Functions
# **********************************************************************************

function configurePrometheusOpenShiftForSimpleApplication () {

   oc label namespace application-beta openshift.io/cluster-monitoring="true"
   oc apply -f $ROOT_FOLDER/prometheus/openshift/
   
   mkdir "$ROOT_FOLDER/scripts/$TEMP_FOLDER"
   
   oc get secrets -n openshift-ingress | grep "router-metrics-certs-default"
   oc extract secret/router-metrics-certs-default --to="$ROOT_FOLDER/scripts/$TEMP_FOLDER" -n openshift-ingress
   kubectl create secret generic prometheus-cert-secret --from-file="$ROOT_FOLDER/scripts/$TEMP_FOLDER/tls.crt" -n application-beta
   
   oc sa get-token -n openshift-monitoring prometheus-k8s > "$ROOT_FOLDER/scripts/$TEMP_FOLDER/token.txt"
   kubectl create secret generic prometheus-token-secret --from-file="$ROOT_FOLDER/scripts/$TEMP_FOLDER/token.txt" -n application-beta
   
   rm -f -r "$ROOT_FOLDER/scripts/$TEMP_FOLDER"

}

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

function configureCR_SimpleMicroservice () {
    oc new-project application-alpha 
    oc new-project application-beta
    IMAGE_NAME="$REGISTRY/$ORG/$IMAGE_MICROSERVICE"

    # Backup CR files
    cp $ROOT_FOLDER/operator-application/config/samples/application.sample_v1alpha1_application.yaml $APPLICATION_TEMPLATE_FOLDER/application.sample_v1alpha1_application-BACKUP.yaml 
    cp $ROOT_FOLDER/operator-application/config/samples/application.sample_v1beta1_application.yaml $APPLICATION_TEMPLATE_FOLDER/application.sample_v1beta1_application-BACKUP.yaml

    sed "s+SIMPLE_APPLICATION_IMAGE+$IMAGE_NAME+g" $APPLICATION_TEMPLATE_FOLDER/application.sample_v1alpha1_application-TEMPLATE.yaml > $ROOT_FOLDER/operator-application/config/samples/application.sample_v1alpha1_application.yaml
    sed "s+SIMPLE_APPLICATION_IMAGE+$IMAGE_NAME+g" $APPLICATION_TEMPLATE_FOLDER/application.sample_v1beta1_application-TEMPLATE.yaml > $ROOT_FOLDER/operator-application/config/samples/application.sample_v1beta1_application.yaml
}

function createOLMApplicationOperatorYAMLs () {
    CATALOG_NAME="$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR_CATALOG"
    sed "s+APPLICATION_CATALOG_IMAGE+$CATALOG_NAME+g" $APPLICATION_TEMPLATE_FOLDER/openshift-application-catalogsource-TEMPLATE.yaml > $ROOT_FOLDER/scripts/openshift-application-catalogsource.yaml
    cp -nf $APPLICATION_TEMPLATE_FOLDER/openshift-application-subscription-TEMPLATE.yaml $ROOT_FOLDER/scripts/openshift-application-subscription.yaml 
}

function deployApplicationOperatorOLM () {
    # create catalog
    namespace=openshift-marketplace
    kubectl create -f $ROOT_FOLDER/scripts/openshift-application-catalogsource.yaml
    kubectl get catalogsource operator-application-catalog -n $namespace -oyaml

    kubectl get pods -n $namespace
    kubectl get all -n $namespace

    # create subscription
    namespace=openshift-operators
    kubectl create -f $ROOT_FOLDER/scripts/openshift-application-subscription.yaml
    kubectl get subscriptions operator-application-v0-0-1-sub -n $namespace -oyaml
    
    kubectl get pods -n $namespace
    kubectl get all -n $namespace

    array=("operator-application-catalog")
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
                echo "*** Status: $STATUS_CHECK"
                echo "*** Get pods $namespace"
                kubectl get pods -n $namespace
                echo "*** Get applications in $namespace"
                kubectl get application -n $namespace
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
    kubectl get pods -n $namespace
    kubectl get all -n $namespace
    
    array=("operator-application.v0.0.1")
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
                    echo "------------------------------------------------------------------------"
                    break
                else
                    echo "$(date +'%F %H:%M:%S') Status:  $i $search($STATUS_CHECK)"
                    echo "------------------------------------------------------------------------"
                fi
                sleep 3
            done
        done
     
    kubectl get pods -n $namespace
    kubectl get all -n $namespace

    array=("operator-application-controller-manager" )
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

function createApplicationInstance () {
    echo "*** create application instances"
    
    kubectl get pods -n openshift-operators | grep "application"
    kubectl create -f $ROOT_FOLDER/operator-application/config/samples/application.sample_v1beta1_application.yaml -n application-beta
    kubectl get pods -n application-beta | grep "application"
    #kubectl apply -f $ROOT_FOLDER/operator-application/config/samples/application.sample_v1alpha1_application.yaml
    #kubectl get pods -n application-alpha | grep "application"

    cp $APPLICATION_TEMPLATE_FOLDER/application.sample_v1alpha1_application-BACKUP.yaml $ROOT_FOLDER/operator-application/config/samples/application.sample_v1alpha1_application.yaml
    cp $APPLICATION_TEMPLATE_FOLDER/application.sample_v1beta1_application-BACKUP.yaml $ROOT_FOLDER/operator-application/config/samples/application.sample_v1beta1_application.yaml

}

function verifyApplication() {
    
    # verify database 
    TYPE="*** verify database - Database operator"
    kubectl exec -n database database-cluster-1 -- curl -s http://localhost:8089/persons > $ROOT_FOLDER/scripts/temp.log
    INFO=$(cat  $ROOT_FOLDER/scripts/temp.log)
    customLog "$TYPE" "$INFO"  
    kubectl exec -n database database-cluster-0 -- curl -s http://localhost:8089/api/leader > $ROOT_FOLDER/scripts/temp.log
    INFO=$(cat  $ROOT_FOLDER/scripts/temp.log)
    customLog "$TYPE" "$INFO"
    rm -f $ROOT_FOLDER/scripts/temp.log

    # verify application
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
                    while :
                    do
                        kubectl get pods -n $namespace
                        PODNAME=$(kubectl get pods -n $namespace | grep "$FIND" | awk '{print $1;}' | sed 's/"//g' | sed 's/,//g')
                        STATUS_CHECK='1/1'
                        STATUS_VERIFICATION=$(kubectl get pods -n $namespace | grep "$FIND" | awk '{print $2;}' | sed 's/"//g' | sed 's/,//g')
                        if [ "$STATUS_VERIFICATION" = "$STATUS_CHECK" ]; then
                            echo "$(date +'%F %H:%M:%S') Status: $PODNAME is Ready"
                            echo "------------------------------------------------------------------------"
                            break
                        else
                            echo "$(date +'%F %H:%M:%S') Status: $PODNAME($STATUS_VERIFICATION)"
                            echo "------------------------------------------------------------------------"
                        fi
                        sleep 3
                    done
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
    kubectl exec -n application-beta $(kubectl get pods -n application-beta | awk '/application-deployment-microservice/ {print $1;exit}') --container application-microservice -- curl http://localhost:8081/hello &> $ROOT_FOLDER/scripts/temp.log
    INFO=$(cat  $ROOT_FOLDER/scripts/temp.log)
    customLog "$TYPE" "$INFO"
    kubectl logs -n $NAMESPACE $(kubectl get pods -n $NAMESPACE | awk '/operator-application-controller-manager/ {print $1;exit}') -c manager &> $ROOT_FOLDER/scripts/temp.log
    INFO=$(cat  $ROOT_FOLDER/scripts/temp.log)
    customLog "$TYPE" "$INFO"

    #remove backup files
    rm $APPLICATION_TEMPLATE_FOLDER/application.sample_v1alpha1_application-BACKUP.yaml 
    rm $APPLICATION_TEMPLATE_FOLDER/application.sample_v1beta1_application-BACKUP.yaml
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
echo " Configure Prometheus instance"
echo "************************************"
configurePrometheusOpenShiftForSimpleApplication

echo "************************************"
echo " Create Application Instance"
echo "************************************"
createApplicationInstance

echo "************************************"
echo " Verify Application Instance"
echo "************************************"
verifyApplication