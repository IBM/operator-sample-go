package backup

import (
	"fmt"
	"os"
	"path/filepath"

	databaseoperatorv1alpha1 "github.com/ibm/operator-sample-go/operator-database/api/v1alpha1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/schema"
	"k8s.io/apimachinery/pkg/types"
	_ "k8s.io/client-go/plugin/pkg/client/auth/oidc"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/scheme"
)

func getBackupResource() error {
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
	var kubernetesClient client.Client
	var GroupVersion = schema.GroupVersion{Group: "database.sample.third.party", Version: "v1alpha1"}
	var SchemeBuilder = &scheme.Builder{GroupVersion: GroupVersion}
	var databaseOperatorScheme *runtime.Scheme
	databaseOperatorScheme, err = SchemeBuilder.Build()
	if err != nil {
		return err
	}
	err = databaseoperatorv1alpha1.AddToScheme(databaseOperatorScheme)
	if err != nil {
		return err
	}
	kubernetesClient, err = client.New(config, client.Options{Scheme: databaseOperatorScheme})
	if err != nil {
		return err
	}

	databaseBackupResource := &databaseoperatorv1alpha1.DatabaseBackup{}
	err = kubernetesClient.Get(applicationContext, types.NamespacedName{Name: backupResourceName, Namespace: namespace}, databaseBackupResource)
	if err != nil {
		return err
	}
	fmt.Println(databaseBackupResource.Name)
	fmt.Println(databaseBackupResource.Spec.ManualTrigger.Repo)

	return nil
}
