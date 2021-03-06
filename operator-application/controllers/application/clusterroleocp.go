package applicationcontroller

import (
	"context"

	applicationsamplev1beta1 "github.com/ibm/operator-sample-go/operator-application/api/v1beta1"
	"github.com/ibm/operator-sample-go/operator-application/variables"

	v1 "k8s.io/api/rbac/v1"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

	"k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/types"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/log"
)

func (reconciler *ApplicationReconciler) defineClusterRoleOCP(application *applicationsamplev1beta1.Application) *v1.ClusterRole {
	labels := map[string]string{variables.LabelKey: variables.LabelValue}

	clusterRole := &v1.ClusterRole{
		TypeMeta: metav1.TypeMeta{APIVersion: "v1", Kind: "ClusterRole"},

		ObjectMeta: metav1.ObjectMeta{Name: variables.ClusterRoleNameOCP, Namespace: variables.OCPClusterRoleNamespace, Labels: labels},
		Rules: []v1.PolicyRule{{
			APIGroups: []string{""},
			Verbs:     []string{"get", "list", "watch"},
			Resources: []string{"endpoints", "pods", "services", "nodes", "secrets"},
		}},
	}

	ctrl.SetControllerReference(application, clusterRole, reconciler.Scheme)
	return clusterRole
}

func (reconciler *ApplicationReconciler) reconcileClusterRoleOCP(ctx context.Context, application *applicationsamplev1beta1.Application) (ctrl.Result, error) {
	log := log.FromContext(ctx)
	clusterRoleDefinition := reconciler.defineClusterRoleOCP(application)
	clusterRole := &v1.ClusterRole{}
	err := reconciler.Get(ctx, types.NamespacedName{Name: variables.ClusterRoleNameOCP, Namespace: variables.OCPClusterRoleNamespace}, clusterRole)
	if err != nil {
		if errors.IsNotFound(err) {
			log.Info("ClusterRole resource " + variables.ClusterRoleNameOCP + " not found. Creating or re-creating ClusterRole")
			err = reconciler.Create(ctx, clusterRoleDefinition)
			if err != nil {
				log.Info("Failed to create ClusterRole resource. Re-running reconcile.")
				return ctrl.Result{}, err
			}
		} else {
			log.Info("Failed to get ClusterRole resource " + variables.ClusterRoleNameOCP + ". Re-running reconcile.")
			return ctrl.Result{}, err
		}
	} else {
		// Note: For simplication purposes services are not updated - see deployment section
		log.Info("")
	}
	return ctrl.Result{}, nil
}
