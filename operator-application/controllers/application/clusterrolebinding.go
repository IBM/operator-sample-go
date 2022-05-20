package applicationcontroller

import (
	"context"

	applicationsamplev1beta1 "github.com/ibm/operator-sample-go/operator-application/api/v1beta1"
	variables "github.com/ibm/operator-sample-go/operator-application/variables"

	v1 "k8s.io/api/rbac/v1"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

	"k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/types"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/log"
)

func (reconciler *ApplicationReconciler) defineClusterRoleBinding(application *applicationsamplev1beta1.Application) *v1.ClusterRoleBinding {
	labels := map[string]string{variables.LabelKey: variables.LabelValue}

	clusterRoleBinding := &v1.ClusterRoleBinding{
		TypeMeta:   metav1.TypeMeta{APIVersion: "v1", Kind: "ClusterRoleBinding"},
		ObjectMeta: metav1.ObjectMeta{Name: variables.ClusterRoleBindingName, Namespace: application.Namespace, Labels: labels},
		Subjects: []v1.Subject{{
			Kind:      "ServiceAccount",
			Name:      variables.RoleBindingServiceAccount,
			Namespace: application.Namespace,
		}},
		RoleRef: v1.RoleRef{
			APIGroup: "rbac.authorization.k8s.io",
			Kind:     "ClusterRole",
			Name:     variables.ClusterRoleName,
		},
	}

	ctrl.SetControllerReference(application, clusterRoleBinding, reconciler.Scheme)
	return clusterRoleBinding
}

func (reconciler *ApplicationReconciler) reconcileClusterRoleBinding(ctx context.Context, application *applicationsamplev1beta1.Application) (ctrl.Result, error) {
	log := log.FromContext(ctx)
	clusterRoleBindingDefinition := reconciler.defineClusterRoleBinding(application)
	clusterRoleBinding := &v1.ClusterRoleBinding{}
	err := reconciler.Get(ctx, types.NamespacedName{Name: variables.ClusterRoleBindingName, Namespace: application.Namespace}, clusterRoleBinding)
	if err != nil {
		if errors.IsNotFound(err) {
			log.Info("ClusterRoleBinding resource " + variables.ClusterRoleBindingName + " not found. Creating or re-creating ClusterRoleBinding")
			err = reconciler.Create(ctx, clusterRoleBindingDefinition)
			if err != nil {
				log.Info("Failed to create ClusterRoleBinding resource. Re-running reconcile.")
				return ctrl.Result{}, err
			}
		} else {
			log.Info("Failed to get ClusterRoleBinding resource " + variables.ClusterRoleBindingName + ". Re-running reconcile.")
			return ctrl.Result{}, err
		}
	} else {
		// Note: For simplication purposes services are not updated - see deployment section
		log.Info("")
	}
	return ctrl.Result{}, nil
}
