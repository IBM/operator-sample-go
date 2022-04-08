package databasebackupcontroller

import (
	"context"

	databasesamplev1alpha1 "github.com/ibm/operator-sample-go/operator-database/api/v1alpha1"
	variables "github.com/ibm/operator-sample-go/operator-database/variablesdatabasebackup"

	v1 "k8s.io/api/rbac/v1"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

	"k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/types"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/log"
)

func (reconciler *DatabaseBackupReconciler) defineClusterRoleBinding(databasebackup *databasesamplev1alpha1.DatabaseBackup) *v1.ClusterRoleBinding {
	labels := map[string]string{variables.LabelKey: variables.LabelValue}

	clusterRoleBinding := &v1.ClusterRoleBinding{
		TypeMeta:   metav1.TypeMeta{APIVersion: "v1", Kind: "ClusterRoleBinding"},
		ObjectMeta: metav1.ObjectMeta{Name: variables.BackupRoleBindingName, Namespace: databasebackup.Namespace, Labels: labels},
		Subjects: []v1.Subject{{
			Kind:      "ServiceAccount",
			Name:      variables.RoleBindingServiceAccount,
			Namespace: databasebackup.Namespace,
		}},
		RoleRef: v1.RoleRef{
			APIGroup: "rbac.authorization.k8s.io",
			Kind:     "ClusterRole",
			Name:     variables.BackupRoleName,
		},
	}

	ctrl.SetControllerReference(databasebackup, clusterRoleBinding, reconciler.Scheme)
	return clusterRoleBinding
}

func (reconciler *DatabaseBackupReconciler) reconcileClusterRoleBinding(ctx context.Context, databasebackup *databasesamplev1alpha1.DatabaseBackup) (ctrl.Result, error) {
	log := log.FromContext(ctx)
	clusterRoleBindingDefinition := reconciler.defineClusterRoleBinding(databasebackup)
	clusterRoleBinding := &v1.ClusterRoleBinding{}
	err := reconciler.Get(ctx, types.NamespacedName{Name: variables.BackupRoleBindingName, Namespace: databasebackup.Namespace}, clusterRoleBinding)
	if err != nil {
		if errors.IsNotFound(err) {
			log.Info("ClusterRoleBinding resource " + variables.BackupRoleBindingName + " not found. Creating or re-creating ClusterRoleBinding")
			err = reconciler.Create(ctx, clusterRoleBindingDefinition)
			if err != nil {
				log.Info("Failed to create ClusterRoleBinding resource. Re-running reconcile.")
				return ctrl.Result{}, err
			}
		} else {
			log.Info("Failed to get ClusterRoleBinding resource " + variables.BackupRoleBindingName + ". Re-running reconcile.")
			return ctrl.Result{}, err
		}
	} else {
		// Note: For simplication purposes services are not updated - see deployment section
	}
	return ctrl.Result{}, nil
}
