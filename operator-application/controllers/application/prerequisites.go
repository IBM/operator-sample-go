package applicationcontroller

import (
	"fmt"

	"k8s.io/client-go/discovery"
)

var kubernetesServerVersion string
var runsOnOpenShift bool = false

func (reconciler *ApplicationReconciler) checkPrerequisites() bool {
	discoveryClient, err := discovery.NewDiscoveryClientForConfig(managerConfig)
	if err == nil {
		serverVersion, err := discoveryClient.ServerVersion()
		if err == nil {
			kubernetesServerVersion = serverVersion.String()
			fmt.Println("Kubernetes Server Version: " + kubernetesServerVersion)

			apiGroup, _, err := discoveryClient.ServerGroupsAndResources()
			if err == nil {
				for i := 0; i < len(apiGroup); i++ {
					if apiGroup[i].Name == "route.openshift.io" {
						runsOnOpenShift = true
					}
				}
			}
		}
	}
	// TODO: Check correct Kubernetes version and distro

	// Note: This function could also check whether external resources exist if the external resource is not created/owned by this controller
	return true
}
