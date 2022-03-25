kubectl delete -f config/samples/application.sample_v1beta1_application.yaml
kubectl delete -f config/samples/application.sample_v1alpha1_application.yaml
make undeploy IMG="$REGISTRY/$ORG/$IMAGE"

operator-sdk cleanup operator-application -n operators --delete-all

kubectl delete catalogsource operator-application-catalog -n operators 
kubectl delete subscriptions operator-application-v0-0-1-sub -n operators 
kubectl delete csv operator-application.v0.0.1 -n operators
kubectl delete operators operator-application.operators -n operators
kubectl delete installplans -n operators --all

kubectl apply -f ../operator-database/config/crd/bases/database.sample.third.party_databases.yaml
kubectl delete namespace application-alpha
kubectl delete namespace application-beta
kubectl delete all --all -n operator-application-system
kubectl delete namespace operator-application-system

operator-sdk olm uninstall