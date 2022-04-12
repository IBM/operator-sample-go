package scaler

import (
	"fmt"
	"os"
	"path/filepath"

	applicationoperatorv1beta1 "github.com/ibm/operator-sample-go/operator-application/api/v1beta1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/schema"
	"k8s.io/apimachinery/pkg/types"
	_ "k8s.io/client-go/plugin/pkg/client/auth/oidc"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/scheme"
)

func getApplicationResource() error {
	config, err := rest.InClusterConfig()
	if err != nil {
		kubeconfig := filepath.Join(
			os.Getenv("HOME"), ".kube", "config",
		)
		fmt.Println("Using kubeconfig file: ", kubeconfig)
		config, err = clientcmd.BuildConfigFromFlags("", kubeconfig)
		if err != nil {
			return err
		}
	}
	var GroupVersion = schema.GroupVersion{Group: "applications.application.sample.ibm.com", Version: "v1beta1"}
	var SchemeBuilder = &scheme.Builder{GroupVersion: GroupVersion}
	var databaseOperatorScheme *runtime.Scheme
	databaseOperatorScheme, err = SchemeBuilder.Build()
	if err != nil {
		return err
	}
	err = applicationoperatorv1beta1.AddToScheme(databaseOperatorScheme)
	if err != nil {
		return err
	}
	kubernetesClient, err = client.New(config, client.Options{Scheme: databaseOperatorScheme})
	if err != nil {
		return err
	}

	applicationResource = &applicationoperatorv1beta1.Application{}
	err = kubernetesClient.Get(applicationContext, types.NamespacedName{Name: applicationName, Namespace: applicationNamespace}, applicationResource)
	if err != nil {
		return err
	}

	return nil
}
