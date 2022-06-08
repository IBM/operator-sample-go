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
echo "Run configuration        : $1"
echo "CI Configuration         : $2"
echo "Reset                    : $3"
echo "Reset Podman             : $4"
echo "-----------------------------"

# **************** Global variables

export ROOT_FOLDER=$(cd $(dirname $0); cd ..; pwd)
export NAMESPACE=openshift-operators
export RUN=$1
export CI_CONFIG=$2
export RESET=$3
export RESET_PODMAN=$4
export SCRIPT_DURATION=""
export start=$(date +%s)
export LOGFILE_NAME=script-automation-openshift.log
export SCRIPT_NAME=ce-create-operators-openshift.sh
export SCRIPT_DATABASE=ci-create-operator-database-openshift.sh
export SCRIPT_APPLICATION=ci-create-operator-application-openshift.sh

# **********************************************************************************
# Functions
# **********************************************************************************

function initLog () {
    echo "$(date +'%F %H:%M:%S'): Init Script Automation Log" > $ROOT_FOLDER/scripts/$LOGFILE_NAME
    echo "$(date +'%F %H:%M:%S'): Parameters: [$RUN] [$CI_CONFIG] [$RESET] [$RESET_PODMAN]" >> $ROOT_FOLDER/scripts/$LOGFILE_NAME
    echo "$(date +'%F %H:%M:%S'): ********************************************************" >> $ROOT_FOLDER/scripts/$LOGFILE_NAME
}

function customLog () {
    LOG_TYPE="$1"
    LOG_MESSAGE="$2"
    echo "$(date +'%F %H:%M:%S'): $LOG_TYPE" >> $ROOT_FOLDER/scripts/$LOGFILE_NAME
    echo "$LOG_MESSAGE" >> $ROOT_FOLDER/scripts/$LOGFILE_NAME
    echo "$(date +'%F %H:%M:%S'): ********************************************************" >> $ROOT_FOLDER/scripts/$LOGFILE_NAME
}

function startTimer () {
   export timerstart=$(date +%s)
   echo "*** Timer start: [$timerstart]"
   customLog "Timer start" "Start: [$timerstart]"
}

function endTimer () {

    timerend=$(date +%s)
    seconds=$(echo "$timerend - $timerstart" | bc)
    TIMER=$(awk -v t=$seconds 'BEGIN{t=int(t*1000); printf "%d:%02d:%02d\n", t/3600000, t/60000%60, t/1000%60}')
    echo "*** Timer end - duration: [$TIMER]"
    customLog "Timer end" "Timer duration [$TIMER]"
    
}

function setupDatabase () {
    bash "$ROOT_FOLDER/scripts/$SCRIPT_DATABASE" $CI_CONFIG $RESET $RESET_PODMAN
    if [ $? == "1" ]; then
        echo "*** The setup of the database-operator failed !"
        echo "*** The script $SCRIPT_NAME ends here!"
        TYPE="*** Error"
        MESSAGE="*** The setup of the database-operator failed !"
        customLog "$TYPE" "$MESSAGE"
        exit 1
    else
        echo "Delete back-up files."
        rm -f $ROOT_FOLDER/scripts/openshift-database-catalogsource.yaml
        rm -f $ROOT_FOLDER/scripts/openshift-database-subscription.yaml 
    fi
}

function setupApplication () {
    bash "$ROOT_FOLDER/scripts/$SCRIPT_APPLICATION" $CI_CONFIG $RESET $RESET_PODMAN
    if [ $? == "1" ]; then
        echo "*** The setup of the application-operator failed !"
        echo "*** The script $SCRIPT_NAME ends here!"
        TYPE="*** Error"
        MESSAGE="*** The setup of the application-operator failed !"
        customLog "$TYPE" "$MESSAGE"
        exit 1
    else
        echo "Delete back-up files."
        rm -f $ROOT_FOLDER/scripts/openshift-application-catalogsource.yaml
        rm -f $ROOT_FOLDER/scripts/openshift-application-subscription.yaml
    fi
}

function run () {
    if [[ $RUN == "database" ]]; then
        echo "*** Setup database only:"
        echo "*** $CI_CONFIG "
        echo "*** $RESET "
        echo "*** $RESET_PODMAN "
        setupDatabase       
    elif [[ $RUN == "app" ]]; then
        echo "*** Setup database and app:"
        echo "*** $CI_CONFIG "
        echo "*** $RESET "
        echo "*** $RESET_PODMAN "    
        setupDatabase
        setupApplication
    else 
        echo "*** Please select a valid option to run!"
        echo "*** Use 'database' for the database operator."
        echo "*** Use 'app' for the database and application operator."
        echo "*** Example:"
        echo "*** sh scripts/ci-create-operators-openshift.sh database local reset"
        exit 1
    fi
}

function duration() {

    end=$(date +%s)
    echo "*** Duration: (Start: $start) to (End: $end)"
    #echo "*** End: $end"
    seconds=$(echo "$end - $start" | bc)
    #echo $seconds' sec'
    export SCRIPT_DURATION=$(awk -v t=$seconds 'BEGIN{t=int(t*1000); printf "%d:%02d:%02d\n", t/3600000, t/60000%60, t/1000%60}')
    echo "*** Duration: $SCRIPT_DURATION"
    
}

function tag () {
    export commit_id=$(git rev-parse --short HEAD)
    echo "Commint ID: $commit_id"
    echo "Date: $(date +'%Y-%m-%d_%H-%M')"
    export tag_date=$(date +'%Y-%m-%d_%H-%M')
    export tag_new="verify_scripts_automation_openshift_$(echo $tag_date)_$(echo $commit_id)"
    
    git tag -l | grep "$tag_new"
    CHECK_TAG=$(git tag -l | grep "$tag_new")
    if [[ $tag_new == $CHECK_TAG ]]; then
        echo "*** The tag $tag_new exists."
        echo "*** No tag will be added"
    else 
       echo "*** Create tag: $tag_new "
       loginfo=$(cat $ROOT_FOLDER/scripts/$LOGFILE_NAME)
       git tag -a $tag_new $commit_id -m "Script configuration: [$RUN] [$CI_CONFIG] [$RESET] [$RESET_PODMAN] - Script duration: [$SCRIPT_DURATION] - $loginfo"
       git push origin $tag_new
    fi
}

# **********************************************************************************
# Execution
# **********************************************************************************

echo "************************************"
echo "Starting time in sec: $start"
echo "************************************"
initLog
echo "************************************"
echo " Starting setup for: $RUN"
echo "************************************"
run
echo "************************************"
echo " Calculate duration"
echo "************************************"
duration
echo "************************************"
echo " Add tag related to current automation "
echo "************************************"
tag

