#!/bin/bash

# **********************************************************************************
# Set global variables using parameters
# **********************************************************************************

export ROOT_FOLDER=$(cd $(dirname $0); cd ..; pwd)

# **********************************************************************************
# Functions
# **********************************************************************************

function resetPodman () {
    
       echo "************************************"
       echo " Reset podman"
       echo "************************************"
       podman machine start
       podman version
       podman machine stop
       podman machine list
       podman machine rm -f podman-machine-default
       cd $ROOT_FOLDER/scripts   
       curl -L -O https://builds.coreos.fedoraproject.org/prod/streams/next/builds/36.20220507.1.0/x86_64/fedora-coreos-36.20220507.1.0-qemu.x86_64.qcow2.xz
       cd $ROOT_FOLDER
       # podman machine init --disk-size 15
       podman machine init --image-path=$ROOT_FOLDER/scripts/fedora-coreos-36.20220507.1.0-qemu.x86_64.qcow2.xz --disk-size 15
       podman machine start > $ROOT_FOLDER/scripts/temp.log
       INFO=$(cat  $ROOT_FOLDER/scripts/temp.log)
       customLog "podman_reset" "$INFO"
        sleep 2
       rm -f $ROOT_FOLDER/scripts/temp.log
}

function checkPodmanRunning () {
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
    else 
      echo "*** Podman is running!"
      rm -f $ROOT_FOLDER/scripts/check_podman.log
    fi
}

# **********************************************************************************
# Execution
# **********************************************************************************

resetPodman
checkPodmanRunning