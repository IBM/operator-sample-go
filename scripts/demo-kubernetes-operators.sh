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
echo "Demo Configuration       : $2"
echo "Reset                    : $3"
echo "-----------------------------"

# **************** Global variables

export ROOT_FOLDER=$(cd $(dirname $0); cd ..; pwd)
export NAMESPACE=operators
export RUN=$1
export CI_CONFIG=$2
export RESET=$3
export SCRIPT_DURATION=""
export start=$(date +%s)
export LOGFILE_NAME=demo-script-automation-kubernetes.log
export SCRIPT_NAME=demo-kubernetes-operators.sh
export SCRIPT_DATABASE=demo-kubernetes-operator-database.sh
export SCRIPT_APPLICATION=demo-kubernetes-operator-application.sh

# **********************************************************************************
# Functions
# **********************************************************************************

function initLog () {
    echo "$(date +'%F %H:%M:%S'): Init Script '$SCRIPT_NAME Automation' Log" > $ROOT_FOLDER/scripts/$LOGFILE_NAME
    echo "$(date +'%F %H:%M:%S'): Parameters: [$RUN] [$CI_CONFIG] [$RESET]" >> $ROOT_FOLDER/scripts/$LOGFILE_NAME
    echo "$(date +'%F %H:%M:%S'): ********************************************************" >> $ROOT_FOLDER/scripts/$LOGFILE_NAME
}

function customLog () {
    LOG_TYPE="$1"
    LOG_MESSAGE="$2"
    echo "$(date +'%F %H:%M:%S'): $LOG_TYPE" >> $ROOT_FOLDER/scripts/$LOGFILE_NAME
    echo "$LOG_MESSAGE" >> $ROOT_FOLDER/scripts/$LOGFILE_NAME
    echo "$(date +'%F %H:%M:%S'): ********************************************************" >> $ROOT_FOLDER/scripts/$LOGFILE_NAME
}

function setupDatabase () {
    bash "$ROOT_FOLDER/scripts/$SCRIPT_DATABASE" $CI_CONFIG $RESET
    if [ $? == "1" ]; then
        echo "*** The setup of the database-operator failed !"
        echo "*** The script '$SCRIPT_DATABASE' ends here!"
        TYPE="*** Error"
        MESSAGE="*** The setup of the database-operator failed !"
        customLog "$TYPE" "$MESSAGE"
        exit 1
    fi
}

function setupApplication () {
    bash "$ROOT_FOLDER/scripts/$SCRIPT_APPLICATION" $CI_CONFIG $RESET
        if [ $? == "1" ]; then
        echo "*** The setup of the applicatior-operator failed !"
        echo "*** The script '$SCRIPT_APPLICATION' ends here!"
        TYPE="*** Error"
        MESSAGE="*** The setup of the applicatior-operator failed !"
        customLog "$TYPE" "$MESSAGE"
        exit 1
    fi
}

function run () {
    if [[ $RUN == "database" ]]; then
        echo "*** Setup database only:"
        echo "*** $CI_CONFIG "
        echo "*** $RESET "
        setupDatabase       
    elif [[ $RUN == "app" ]]; then
        echo "*** Setup database and app:"
        echo "*** $CI_CONFIG "
        echo "*** $RESET "   
        setupDatabase
        setupApplication
    else 
        echo "*** Please select a valid option to run!"
        echo "*** Use 'database' for the database operator."
        echo "*** Use 'app' for the database and application operator."
        echo "*** Example:"
        echo "*** sh scripts/$SCRIPT_NAME database local reset"
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
    echo "*** Duration Formatted: $SCRIPT_DURATION"
    
}

# **********************************************************************************
# Execution
# **********************************************************************************

echo "************************************"
echo "Init log"
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
