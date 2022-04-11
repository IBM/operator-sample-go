#!/bin/bash

ROOT_FOLDER=$(cd $(dirname $0); cd ..; pwd)

cd $ROOT_FOLDER/operator-application
kubectl delete -f config/samples/application.sample_v1beta1_application.yaml
kubectl delete -f config/samples/application.sample_v1alpha1_application.yaml

make undeploy IMG="$REGISTRY/$ORG/$IMAGE_APPLICATION_OPERATOR"
operator-sdk cleanup operator-application -n operators --delete-all

kubectl delete catalogsource operator-application-catalog -n operators 
kubectl delete subscriptions operator-application-v0-0-1-sub -n operators 
kubectl delete csv operator-application.v0.0.1 -n operators
kubectl delete operators operator-application.operators -n operators
kubectl delete installplans -n operators --all

kubectl delete namespace application-alpha
kubectl delete namespace application-beta
kubectl delete all --all -n operator-application-system
kubectl delete namespace operator-application-system

cd $ROOT_FOLDER/operator-database
kubectl delete -f config/samples/database.sample_v1alpha1_database.yaml

make undeploy IMG="$REGISTRY/$ORG/$IMAGE_DATBASE_OPERATOR"
operator-sdk cleanup operator-database -n operators --delete-all

kubectl delete namespace database
kubectl delete all --all -n operator-database-system
kubectl delete namespace operator-database-system

cd $ROOT_FOLDER
kubectl delete -f prometheus/prometheus/
kubectl delete -f prometheus/operator/

operator-sdk olm uninstall

kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.2/cert-manager.yaml