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
echo "Reset Podman             : $3"
echo "-----------------------------"

# **************** Global variables

export ROOT_FOLDER=$(cd $(dirname $0); cd ..; pwd)
export NAMESPACE=operators
export CI_CONFIG=$1
export RESET=$2
export RESET_PODMAN=$3
export VERSIONS_FILE=""
export DATABASE_TEMPLATE_FOLDER=$ROOT_FOLDER/scripts/database-operator-templates
export LOGFILE_NAME=script-automation-kubernetes.log
export SCRIPTNAME="ci-create-operator-database-kubernetes.sh"

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
    INFO="script: ci-create-operator-database-kubernetes.sh"
    customLog "$TYPE" "$INFO"
}

function startTimer() {
   export timerstart=$(date +%s)
   echo "*** Timer start: [$timerstart]"
   customLog "Timer start" "Start: [$timerstart]"
}

function endTimer() {

    timerend=$(date +%s)
    seconds=$(echo "$timerend - $timerstart" | bc)
    TIMER=$(awk -v t=$seconds 'BEGIN{t=int(t*1000); printf "%d:%02d:%02d\n", t/3600000, t/60000%60, t/1000%60}')
    echo "*** Timer end - duration: [$TIMER]"
    customLog "Timer end" "Timer duration [$TIMER]"
    
}

function setEnvironmentVariables () {
 
    if [[ $RESET_PODMAN == "podman_reset" ]] ; then
       echo "************************************"
       echo " Reset podman"
       echo "************************************"
       podman machine start
       podman version
       podman machine stop
       podman machine list
       podman machine rm -f podman-machine-default
       cd $ROOT_FOLDER/scripts   
       #curl -L -O https://builds.coreos.fedoraproject.org/prod/streams/next/builds/36.20220507.1.0/x86_64/fedora-coreos-36.20220507.1.0-qemu.x86_64.qcow2.xz
       cd $ROOT_FOLDER
       podman machine init --disk-size 15
       #podman machine init --image-path=$ROOT_FOLDER/scripts/fedora-coreos-36.20220507.1.0-qemu.x86_64.qcow2.xz --disk-size 15
       podman machine start > $ROOT_FOLDER/scripts/temp.log
       INFO=$(cat  $ROOT_FOLDER/scripts/temp.log)
       customLog "podman_reset" "$INFO"
        sleep 2
       rm -f $ROOT_FOLDER/scripts/temp.log
    fi

    echo "************************************"
    echo " Check if podman is running"
    echo "************************************"

    podman images &> $ROOT_FOLDER/scripts/check_podman.log

    CHECK=$(cat $ROOT_FOLDER/scripts/check_podman.log | grep 'Cannot connect to Podman' | awk '{print $1;}')
    echo "*** Podman check: $CHECK"
    
    if [[ $CHECK == "Cannot" ]]; then
       echo "*** Podman is not running! The script ends here."
       rm -f $ROOT_FOLDER/scripts/check_podman.log
       exit 1
    fi

    if [[ $CI_CONFIG == "local" ]]; then
        echo "*** Set versions_local.env file as input"
        source $ROOT_FOLDER/versions_local.env
        INFO="*** Using following registry: $REGISTRY/$ORG"
        echo $INFO
        customLog "$CI_CONFIG" "$INFO"
        rm -f $ROOT_FOLDER/scripts/check_podman.log
    elif [[ $CI_CONFIG == "ci" ]]; then
        echo "*** Set versions.env file as input"        
        source $ROOT_FOLDER/versions.env
        INFO="*** Using following registry: $REGISTRY/$ORG"
        echo $INFO
        customLog "$CI_CONFIG" "$INFO"
        rm -f $ROOT_FOLDER/scripts/check_podman.log
    else 
        echo "*** Please select a valid option to run!"
        echo "*** Use 'local' for your local test."
        echo "*** Use 'ci' for your the ci test."
        echo "*** Example:"
        echo "*** sh ci-operator-database-kubernetes.sh local"
        exit 1
    fi
}

function resetAll () {

    if [[ $RESET == "reset" ]]; then
        echo "*** RESET Kubernetes environment!"
        echo "*** DELETE all Kubernetes compoments!"
        cd $ROOT_FOLDER/scripts
        bash $ROOT_FOLDER/scripts/delete-everything-kubernetes.sh
        
        echo "*** Install required Kubernetes compoments!"
        cd $ROOT_FOLDER/scripts
        bash $ROOT_FOLDER/scripts/install-required-kubernetes-components.sh
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

function buildDatabaseService () {
    cd $ROOT_FOLDER/database-service
    rm -f $ROOT_FOLDER/scripts/temp.log
    podman build -t "$REGISTRY/$ORG/$IMAGE_DATABASE_SERVICE" . > $ROOT_FOLDER/scripts/temp.log
    TYPE="buildDatabaseService"
    logBuild "$TYPE" "$ROOT_FOLDER/scripts/temp.log"
    rm -f "$ROOT_FOLDER/scripts/temp.log"
    podman login $REGISTRY
    podman push "$REGISTRY/$ORG/$IMAGE_DATABASE_SERVICE"
}

function buildDatabaseBackup () {
    cd $ROOT_FOLDER/operator-database-backup
    rm -f $ROOT_FOLDER/scripts/temp.log
    podman build -t "$REGISTRY/$ORG/$IMAGE_DATABASE_BACKUP" . > $ROOT_FOLDER/scripts/temp.log
    TYPE="buildDatabaseBackup"
    logBuild "$TYPE" "$ROOT_FOLDER/scripts/temp.log"
    rm -f "$ROOT_FOLDER/scripts/temp.log"
    podman login $REGISTRY
    podman push "$REGISTRY/$ORG/$IMAGE_DATABASE_BACKUP"
}

function configureCRs_DatabaseOperator () {

    # Backup CR files
    cp -nf $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasebackup.yaml $DATABASE_TEMPLATE_FOLDER/database.sample_v1alpha1_databasebackup.yaml-BACKUP
    cp -nf $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasecluster.yaml $DATABASE_TEMPLATE_FOLDER/database.sample_v1alpha1_databasecluster.yaml-backup
 
    #Backup
    IMAGE_NAME="$REGISTRY/$ORG/$IMAGE_DATABASE_BACKUP"
    echo $IMAGE_NAME
    sed "s+DATABASE_BACKUP_IMAGE+$IMAGE_NAME+g" "$DATABASE_TEMPLATE_FOLDER/database.sample_v1alpha1_databasebackup-TEMPLATE.yaml" > "$ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasebackup.yaml"
    cat $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasecluster.yaml | grep "$IMAGE_DATABASE_BACKUP"
    IMAGE_NAME="$REGISTRY/$ORG/$IMAGE_DATABASE_SERVICE"
    
    #Cluster
    IMAGE_NAME="$REGISTRY/$ORG/$IMAGE_DATABASE_SERVICE" 
    echo $IMAGE_NAME
    sed "s+DATABASE_SERVICE_IMAGE+$IMAGE_NAME+g" $DATABASE_TEMPLATE_FOLDER/database.sample_v1alpha1_databasecluster-TEMPLATE.yaml > $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasecluster.yaml
    cat $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasebackup.yaml | grep "$IMAGE_DATABASE_BACKUP"
}

function buildDatabaseOperator () {
    cd $ROOT_FOLDER/operator-database
    
    # Backup Role
    cp -nf $ROOT_FOLDER/operator-database/config/rbac/role.yaml $DATABASE_TEMPLATE_FOLDER/role.yaml-BACKUP 

    make generate
    make manifests
    # Build container
    # make docker-build IMG="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"
    rm -f $ROOT_FOLDER/scripts/temp.log
    podman build -t "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR" . > $ROOT_FOLDER/scripts/temp.log
    TYPE="buildDatabaseOperator"
    logBuild "$TYPE" "$ROOT_FOLDER/scripts/temp.log"
    rm -f "$ROOT_FOLDER/scripts/temp.log"

    # Push container
    podman login $REGISTRY
    podman push "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"

    # Put back backup files and delete backup, when "local" was used
    if [[ $CI_CONFIG == "local" ]]; then
      cp -nf $DATABASE_TEMPLATE_FOLDER/role.yaml-BACKUP $ROOT_FOLDER/operator-database/config/rbac/role.yaml
    fi
    rm -f $DATABASE_TEMPLATE_FOLDER/role.yaml-BACKUP

}

function buildDatabaseOperatorBundle () {
    cd $ROOT_FOLDER/operator-database
    
    # Backup existing CVS, kustomization and Roles
    cp -nf $ROOT_FOLDER/operator-database/bundle/manifests/operator-database.clusterserviceversion.yaml $DATABASE_TEMPLATE_FOLDER/operator-database.clusterserviceversion.yaml-BACKUP
    cp -nf $ROOT_FOLDER/operator-database/config/rbac/role.yaml $DATABASE_TEMPLATE_FOLDER/role.yaml-backup
    cp -nf $ROOT_FOLDER/operator-database/config/rbac/role_binding.yaml $DATABASE_TEMPLATE_FOLDER/role_binding.yaml-backup
    cp -nf $ROOT_FOLDER/operator-database/config/manager/kustomization.yaml $DATABASE_TEMPLATE_FOLDER/kustomization.yaml-BACKUP
     
    # Build bundle
    make bundle IMG="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"
     
    # Replace CSV and RBAC generate files with customized versions
    DATABASE_OPERATOR_IMAGE="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"
    sed "s+DATABASE_OPERATOR_IMAGE+$DATABASE_OPERATOR_IMAGE+g" $DATABASE_TEMPLATE_FOLDER/operator-database.clusterserviceversion-TEMPLATE.yaml > $ROOT_FOLDER/operator-database/bundle/manifests/operator-database.clusterserviceversion.yaml
    OPERATOR_NAMESPACE=operators
    sed "s+OPERATOR_NAMESPACE+$OPERATOR_NAMESPACE+g" $DATABASE_TEMPLATE_FOLDER/operator-database-role_binding_patch_TEMPLATE.yaml > $ROOT_FOLDER/operator-database/config/rbac/role_binding.yaml
    cp -nf $DATABASE_TEMPLATE_FOLDER/operator-database-role_patch_TEMPLATE.yaml $ROOT_FOLDER/operator-database/config/rbac/role.yaml
    # make bundle-build BUNDLE_IMG="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE"  
    rm -f $ROOT_FOLDER/scripts/temp.log
 
    # Build image
    podman build -f bundle.Dockerfile -t "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE" . > $ROOT_FOLDER/scripts/temp.log
    TYPE="buildDatabaseOperatorBundle"
    logBuild "$TYPE" "$ROOT_FOLDER/scripts/temp.log"
    rm -f "$ROOT_FOLDER/scripts/temp.log"

    # Put back backup files and delete backup, when "local" was used
    if [[ $CI_CONFIG == "local" ]]; then
      cp -nf $DATABASE_TEMPLATE_FOLDER/operator-database.clusterserviceversion.yaml-BACKUP $ROOT_FOLDER/operator-database/bundle/manifests/operator-database.clusterserviceversion.yaml
      cp -nf $DATABASE_TEMPLATE_FOLDER/role.yaml-backup $ROOT_FOLDER/operator-database/config/rbac/role.yaml
      cp -nf $DATABASE_TEMPLATE_FOLDER/role_binding.yaml-backup $ROOT_FOLDER/operator-database/config/rbac/role_binding.yaml
      cp -nf $DATABASE_TEMPLATE_FOLDER/kustomization.yaml-BACKUP $ROOT_FOLDER/operator-database/config/manager/kustomization.yaml
    fi
    rm -f $DATABASE_TEMPLATE_FOLDER/operator-database.clusterserviceversion.yaml-BACKUP
    rm -f $DATABASE_TEMPLATE_FOLDER/role.yaml-backup
    rm -f $DATABASE_TEMPLATE_FOLDER/role_binding.yaml-backup
    rm -f $DATABASE_TEMPLATE_FOLDER/kustomization.yaml-BACKUP

    # Push container
    podman login $REGISTRY
    podman push "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE"
}

function buildDatabaseOperatorCatalog () {
    cd $ROOT_FOLDER/operator-database

    # make catalog-build CATALOG_IMG="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_CATALOG" BUNDLE_IMGS="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE"
    rm -f $ROOT_FOLDER/scripts/temp.log
    $ROOT_FOLDER/operator-database/bin/opm index add --build-tool podman --mode semver --tag "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_CATALOG" --bundles "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE" &> $ROOT_FOLDER/scripts/temp.log
    TYPE="buildDatabaseOperatorCatalog"
    INPUT=$(cat $ROOT_FOLDER/scripts/temp.log)
    echo $INPUT
    customLog "$TYPE" "$INPUT"
    rm -f $ROOT_FOLDER/scripts/temp.log

    podman login $REGISTRY
    podman push "$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_CATALOG" 
}

function createOLMDatabaseOperatorYAMLs () {
    CATALOG_NAME="$REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_CATALOG"
    sed "s+DATABASE_CATALOG_IMAGE+$CATALOG_NAME+g" $DATABASE_TEMPLATE_FOLDER/kubernetes-database-catalogsource-TEMPLATE.yaml > $ROOT_FOLDER/scripts/kubernetes-database-catalogsource.yaml
    cp -nf $DATABASE_TEMPLATE_FOLDER/kubernetes-database-subscription-TEMPLATE.yaml $ROOT_FOLDER/scripts/kubernetes-database-subscription.yaml
}

function deployDatabaseOperatorOLM () {
    
    kubectl create -f $ROOT_FOLDER/scripts/kubernetes-database-catalogsource.yaml
    export max_retrys=20
    j=0
    array=("operator-database-catalog")
    namespace=operators
    export STATUS_SUCCESS="Running"
    for i in "${array[@]}"
        do 
            echo ""
            echo "------------------------------------------------------------------------"
            echo "Check $i"
            while :
            do
                ((j++))
                FIND=$i
                STATUS_CHECK=$(kubectl get pods -n $namespace | grep "$FIND" | awk '{print $3;}' | sed 's/"//g' | sed 's/,//g')
                echo "Status: $STATUS_CHECK"
                kubectl get pods -n $namespace
                STATUS_VERIFICATION=$(echo "$STATUS_CHECK" | grep $STATUS_SUCCESS)
                if [ "$STATUS_VERIFICATION" = "$STATUS_SUCCESS" ]; then
                    echo "$(date +'%F %H:%M:%S') Status: $FIND is Ready"
                    echo "------------------------------------------------------------------------"
                    break
                elif [[ $j -eq $max_retrys ]]; then
                    echo "$(date +'%F %H:%M:%S') To many loops ($j) reached!"
                    echo "$(date +'%F %H:%M:%S') Stop the script ($SCRIPTNAME) here !"
                    echo "------------------------------------------------------------------------"
                    exit 1   
                else
                    echo "$(date +'%F %H:%M:%S') Status: $FIND($STATUS_CHECK)"
                    echo "------------------------------------------------------------------------"
                fi
                sleep 3
            done
        done
    kubectl get catalogsource operator-database-catalog -n $NAMESPACE -oyaml

    kubectl create -f $ROOT_FOLDER/scripts/kubernetes-database-subscription.yaml
    kubectl get subscriptions operator-database-v0-0-1-sub -n $NAMESPACE -oyaml
    kubectl get installplans -n $NAMESPACE
    kubectl get pods -n $NAMESPACE
    kubectl get all -n $NAMESPACE
    array=("operator-database.v0.0.1")
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
                    kubectl get $search -n $namespace
                    break
                else
                    kubectl get $search -n $namespace
                    echo "$(date +'%F %H:%M:%S') Status: $search($STATUS_CHECK)"
                    echo "------------------------------------------------------------------------"
                fi
                sleep 3
            done
        done

    array=("operator-database-controller-manager" )
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

    # Put back backup files and delete backup, when "local" was used
    if [[ $CI_CONFIG == "local" ]]; then
      cp -nf $DATABASE_TEMPLATE_FOLDER/database.sample_v1alpha1_databasebackup.yaml-BACKUP $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasebackup.yaml 
      cp -nf $DATABASE_TEMPLATE_FOLDER/database.sample_v1alpha1_databasecluster.yaml-backup $ROOT_FOLDER/operator-database/config/samples/database.sample_v1alpha1_databasecluster.yaml
    fi
    rm -f $DATABASE_TEMPLATE_FOLDER/database.sample_v1alpha1_databasebackup.yaml-BACKUP
    rm -f $DATABASE_TEMPLATE_FOLDER/database.sample_v1alpha1_databasecluster.yaml-backup
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
echo " Build 'database service'"
echo " Push image to $REGISTRY/$ORG/$IMAGE_DATABASE_SERVICE"
echo "************************************"
startTimer
buildDatabaseService
endTimer

echo "************************************"
echo " Build 'operator database backup'"
echo " Push image to $REGISTRY/$ORG/$IMAGE_DATABASE_BACKUP"
echo "************************************"
startTimer
buildDatabaseBackup
endTimer

echo "************************************"
echo " Configure CR samples for the 'database operator'"
echo "************************************"
startTimer
configureCRs_DatabaseOperator
endTimer

echo "************************************"
echo " Build 'database operator'"
echo " Push image to $REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR"
echo "************************************"
startTimer
buildDatabaseOperator
endTimer

echo "************************************"
echo " Build 'database operator bundle'"
echo " Push image to $REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_BUNDLE"
echo "************************************"
startTimer
buildDatabaseOperatorBundle
endTimer

echo "************************************"
echo " Build 'database operator catalog'"
echo " Push image to $REGISTRY/$ORG/$IMAGE_DATABASE_OPERATOR_CATALOG"
echo "************************************"
startTimer
buildDatabaseOperatorCatalog
endTimer

echo "************************************"
echo " Create OLM yamls"
echo "************************************"
startTimer
createOLMDatabaseOperatorYAMLs
endTimer

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