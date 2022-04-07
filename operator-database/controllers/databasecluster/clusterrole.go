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

func (reconciler *DatabaseClusterReconciler) defineClusterRole(databasecluster *databasesamplev1alpha1.DatabaseCluster) *v1.ClusterRole {
	labels := map[string]string{variables.LabelKey: variables.LabelValue}

	clusterRole := &v1.ClusterRole{
		TypeMeta:   metav1.TypeMeta{APIVersion: "v1", Kind: "ClusterRole"},
		ObjectMeta: metav1.ObjectMeta{Name: variables.ClusterRoleName, Namespace: databasecluster.Namespace, Labels: labels},
		Rules: []v1.PolicyRule{{
			APIGroups: []string{"rbac.authorization.k8s.io"},
			Verbs:     []string{"get", "list", "watch"},
			Resources: []string{"pods"},
		}},
	}

	ctrl.SetControllerReference(databasecluster, clusterRole, reconciler.Scheme)
	return clusterRole
}

func (reconciler *DatabaseClusterReconciler) reconcileClusterRole(ctx context.Context, databasecluster *databasesamplev1alpha1.DatabaseCluster) (ctrl.Result, error) {
	log := log.FromContext(ctx)
	clusterRoleDefinition := reconciler.defineClusterRole(databasecluster)
	clusterRole := &v1.ClusterRole{}
	err := reconciler.Get(ctx, types.NamespacedName{Name: variables.ClusterRoleName, Namespace: databasecluster.Namespace}, clusterRole)
	if err != nil {
		if errors.IsNotFound(err) {
			log.Info("ClusterRole resource " + variables.ClusterRoleName + " not found. Creating or re-creating ClusterRole")
			err = reconciler.Create(ctx, clusterRoleDefinition)
			if err != nil {
				log.Info("Failed to create ClusterRole resource. Re-running reconcile.")
				return ctrl.Result{}, err
			}
		} else {
			log.Info("Failed to get ClusterRole resource " + variables.ClusterRoleName + ". Re-running reconcile.")
			return ctrl.Result{}, err
		}
	} else {
		// Note: For simplication purposes services are not updated - see deployment section
	}
	return ctrl.Result{}, nil
}
