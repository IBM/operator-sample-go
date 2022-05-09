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

ROOT_FOLDER=$(cd $(dirname $0); cd ..; pwd)
NAMESPACE=operators
export RUN=$1
export CI_CONFIG=$2
export RESET=$3
export RESET_PODMAN=$4
export start=$(date +%s)

# **********************************************************************************
# Functions
# **********************************************************************************

function setupDatabase () {
    bash "$ROOT_FOLDER/scripts/ci-create-operator-database-kubernetes.sh" $CI_CONFIG $RESET $RESET_PODMAN
}

function setupApplication () {
    bash "$ROOT_FOLDER/scripts/ci-create-operator-application-kubernetes.sh" $CI_CONFIG $RESET $RESET_PODMAN
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
        echo "*** sh scripts/ci-create-operators-kubernetes.sh database local reset"
        exit 1
    fi
}
function duration() {

    end=$(date +%s)
    echo "*** Duration Start: $start to End: $end"
    echo "*** End: $end"
    seconds=$(echo "$end - $start" | bc)
    echo $seconds' sec'
    echo 'Formatted:'
    awk -v t=$seconds 'BEGIN{t=int(t*1000); printf "%d:%02d:%02d\n", t/3600000, t/60000%60, t/1000%60}'
}

# **********************************************************************************
# Execution
# **********************************************************************************

echo "Starting: $start"
echo "************************************"
echo " Run setup for $RUN"
echo "************************************"
run
duration


