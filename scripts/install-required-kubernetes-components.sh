#!/bin/bash

# **************** Global variables

export ROOT_FOLDER=$(cd $(dirname $0); cd ..; pwd)
export LOGFILE_NAME="install-required-kubernetes.log"
export SCRIPTNAME="install-required-kubernetes.sh"

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

function verifyDeletion () {

  TYPE='function'
  INFO="verifyDeletion"
  customLog $TYPE $INFO
  
  export max_retrys=2
  j=0
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
                echo "$(date +'%F %H:%M:%S') Please run 'delete-everything-kubernetes.sh' first!"
                echo "$(date +'%F %H:%M:%S') Prereqs aren't ready!"
                echo "------------------------------------------------------------------------"
                exit 1              
            else
                echo "$(date +'%F %H:%M:%S') Status: $FIND($STATUS_CHECK)"
                echo "------------------------------------------------------------------------"
            fi
            sleep 3
        done
    done 
}

function installCertManager () {

  TYPE='function'
  INFO="installCertManager"
  customLog $TYPE $INFO

  kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.2/cert-manager.yaml
  kubectl get pods -n cert-manager

  array=("cert-manager-cainjector" "cert-manager-webhook")
  export STATUS_SUCCESS="Running"
  for i in "${array[@]}"
    do 
        echo ""
        echo "------------------------------------------------------------------------"
        echo "Check $i"
        while :
        do
            FIND=$i
            STATUS_CHECK=$(kubectl get pods -n cert-manager | grep "$FIND" | awk '{print $3;}' | sed 's/"//g' | sed 's/,//g')
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

function installOLM () {

  TYPE='function'
  INFO="installOLM"
  customLog $TYPE $INFO

  curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.20.0/install.sh | bash -s v0.20.0
  kubectl get pods -n operators
  kubectl get pods -n olm

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
            STATUS_CHECK=$(kubectl get pods -n $namespace | grep "$FIND" | awk '{print $3;}' | sed 's/"//g' | sed 's/,//g')
            echo "Status: ($STATUS_CHECK)"
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

function installPrometheusOperator () {
  
  TYPE='function'
  INFO="installPrometheusOperator"
  customLog $TYPE $INFO

  kubectl create -f $ROOT_FOLDER/prometheus/kubernetes/operator/
  kubectl get pods -n monitoring | grep 'prom'

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

function createPrometheusInstance () {

  TYPE='function'
  INFO="createPrometheusInstance"
  customLog $TYPE $INFO
    
  kubectl create -f $ROOT_FOLDER/prometheus/kubernetes/instance

  kubectl get clusterrolebinding -n monitoring | grep 'prom'
  kubectl get clusterrole -n monitoring | grep 'prom'
  kubectl get prometheus -n monitoring 
  kubectl get pods -n monitoring

  array=("prometheus-prometheus-instance" )
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

function verifyPrometheusInstance () {
    
   TYPE='function'
   INFO="verifyPrometheusInstance"
   customLog $TYPE $INFO

   kubectl get service -n monitoring
   #kubectl port-forward service/prometheus-instance -n monitoring 9090
}

# **********************************************************************************
# Execution
# **********************************************************************************

initLog

echo "************************************"
echo " Verify deletion"
echo "************************************"
verifyDeletion

echo "************************************"
echo " Install cert manager"
echo "************************************"
installCertManager

echo "************************************"
echo " Install olm"
echo "************************************"
installOLM

echo "************************************"
echo " Install prometheus operator"
echo "************************************"
installPrometheusOperator

echo "************************************"
echo " Create prometheus instance"
echo "************************************"
createPrometheusInstance

echo "************************************"
echo " Verify prometheus instance"
echo "************************************"
verifyPrometheusInstance
