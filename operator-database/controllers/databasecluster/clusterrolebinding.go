package databaseclustercontroller

import (
	"context"

	databasesamplev1alpha1 "github.com/ibm/operator-sample-go/operator-database/api/v1alpha1"
	variables "github.com/ibm/operator-sample-go/operator-database/variablesdatabasecluster"

	v1 "k8s.io/api/rbac/v1"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

	"k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/types"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/log"
)

func (reconciler *DatabaseClusterReconciler) defineClusterRoleBinding(databasecluster *databasesamplev1alpha1.DatabaseCluster) *v1.ClusterRoleBinding {
	labels := map[string]string{variables.LabelKey: variables.LabelValue}

	clusterRoleBinding := &v1.ClusterRoleBinding{
		TypeMeta:   metav1.TypeMeta{APIVersion: "v1", Kind: "ClusterRoleBinding"},
		ObjectMeta: metav1.ObjectMeta{Name: variables.ClusterRoleBindingName, Namespace: databasecluster.Namespace, Labels: labels},
		Subjects: []v1.Subject{{
			Kind:      "ServiceAccount",
			Name:      variables.RoleBindingServiceAccount,
			Namespace: databasecluster.Namespace,
		}},
		RoleRef: v1.RoleRef{
			APIGroup: "rbac.authorization.k8s.io",
			Kind:     "ClusterRole",
			Name:     variables.ClusterRoleName,
		},
	}

	ctrl.SetControllerReference(databasecluster, clusterRoleBinding, reconciler.Scheme)
	return clusterRoleBinding
}

func (reconciler *DatabaseClusterReconciler) reconcileClusterRoleBinding(ctx context.Context, databasecluster *databasesamplev1alpha1.DatabaseCluster) (ctrl.Result, error) {
	log := log.FromContext(ctx)
	clusterRoleBindingDefinition := reconciler.defineClusterRoleBinding(databasecluster)
	clusterRoleBinding := &v1.ClusterRoleBinding{}
	err := reconciler.Get(ctx, types.NamespacedName{Name: variables.ClusterRoleBindingName, Namespace: databasecluster.Namespace}, clusterRoleBinding)
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
	}
	return ctrl.Result{}, nil
}
