#!/bin/bash

# **************** Global variables
export REGISTRY='quay.io'
export ORG='tsuedbroecker'
export OPERATOR_IMAGE='myproblemfix-operator-image'
export BUNDLE_IMAGE='myproblemfix-bundle-image'
export CATALOG_IMAGE='myproblemfix-catalog-image'
export COMMON_TAG='v1.0.36'
export FIND="docker"
export REPLACE="podman"
export OPERATOR_SDK_VERSION="v1.19.1"
export ROOT_FOLDER=$(cd $(dirname $0); cd ..; pwd)

# **********************************************************************************
# Functions
# **********************************************************************************

function showVersions () {
    podman version
    operator-sdk version
}

function createOperatorSDKProjectFolder () {

    mkdir $ROOT_FOLDER/scripts/fixproblem
    cd  $ROOT_FOLDER/scripts/fixproblem
    pwd

}

function creatOperatorSDKProject () {
   operator-sdk init --domain myproblemfix.net --repo github.com/myproblemfix/myproblemfix
}

function creatOperatorSDKAPI () {
   pwd
   operator-sdk create api --group myproblemfix --version v1alpha1 --kind Myproblemfix --resource --controller
}

function modifyMakefile () {
    pwd
    sed "s+$FIND+$REPLACE+g" ./Makefile > ./Makefile-temp
    cp -nf ./Makefile-temp ./Makefile
    # cat Makefile
}

function createGoApplication () {
    pwd
    make generate
    echo "***  Bin folder status"
    cd ./bin
    pwd
    ls
    cd ..
}

function createKubernetesManifests () {
    make manifests
    echo "***  Bin folder status"
    cd ./bin
    pwd
    ls
    cd ..
}

function createOperatorImage () {
    make podman-build IMG="$REGISTRY/$ORG/$OPERATOR_IMAGE:$COMMON_TAG"
    echo "***  Bin folder status"
    cd ./bin
    pwd
    ls
    cd ..
}

function createBundle () {
    make bundle IMG="$REGISTRY/$ORG/$OPERATOR_IMAGE:$COMMON_TAG"
    echo "***  Bin folder status"
    cd ./bin
    pwd
    ls
    cd ..
}

function getOPMandCopyBin () {
    cd ./bin
    pwd
    OS=$(go env $GOOS) 
    ARCH=$(go env $GOARCH)
    curl -L -O https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest-4.9/opm-mac.tar.gz
    tar -xf opm-mac.tar.gz
    cp darwin-amd64-opm opm     
    chmod +x opm
    rm -f darwin-amd64-opm 
    rm -f opm-mac.tar.gz
    echo "***  Bin folder status"
    ls
    cd $ROOT_FOLDER/scripts/fixproblem/bin/
    pwd
    cp -r . ../../../operator-database/bin
    cp -r . ../../../operator-application/bin
    # delete the `fixproblem` project
    rm -rf $ROOT_FOLDER/scripts/fixproblem
    echo "***  Bin folder status: operator-database"
    cd $ROOT_FOLDER/operator-application/bin
    ls
    echo "***  Bin folder status: operator-database"
    cd $ROOT_FOLDER/operator-database/bin
    ls
    
    echo "************************************"
    echo "*** The OPM version was copied to your operator-sdk projects!"
    echo "*** You can verfy that manually, if you want."
    echo "************************************"
}


# **********************************************************************************
# Execution
# **********************************************************************************

echo "************************************"
echo "*** 1. Show tools versions"
echo "************************************"

showVersions

echo "************************************"
echo "*** 2. Create operator-sdk project folder"
echo "************************************"

createOperatorSDKProjectFolder

echo "************************************"
echo "*** 3. Create operator-sdk project"
echo "************************************"

creatOperatorSDKProject

echo "************************************"
echo "*** 4. Create operator-sdk api"
echo "************************************"

creatOperatorSDKAPI

echo "************************************"
echo "*** 5. Modify Makefile to use podman"
echo "************************************"

modifyMakefile

echo "************************************"
echo "*** 6. Create go application"
echo "************************************"

createGoApplication

echo "************************************"
echo "*** 7. Build Kubernetes manifests"
echo "************************************"

createKubernetesManifests

echo "************************************"
echo "*** 8. Build operator container image"
echo "************************************"

createOperatorImage

echo "************************************"
echo "*** 9. Create bundle with link to operator image"
echo " Kustomize will create the 'Custer Service Version' file"
echo "*** Copy and past to questions:"
echo "*** ---------------------------"
echo "*** Display name   : myproblemfix"
echo "*** Description    : myproblemfix"
echo "*** Provider's name: myproblemfix"
echo "*** Any relevant URL: "
echo "*** Comma-separated keywords   : myproblemfix"
echo "*** Comma-separated maintainers: myproblemfix@myproblemfix.net"
echo "************************************"

createBundle

echo "************************************"
echo "*** 10. Get OPM and copy bin to operator-sdk projects"
echo "************************************"

getOPMandCopyBin





