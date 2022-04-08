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

func (reconciler *DatabaseBackupReconciler) defineClusterRole(databasebackup *databasesamplev1alpha1.DatabaseBackup) *v1.ClusterRole {
	labels := map[string]string{variables.LabelKey: variables.LabelValue}

	clusterRole := &v1.ClusterRole{
		TypeMeta:   metav1.TypeMeta{APIVersion: "v1", Kind: "ClusterRole"},
		ObjectMeta: metav1.ObjectMeta{Name: variables.BackupRoleName, Namespace: databasebackup.Namespace, Labels: labels},
		Rules: []v1.PolicyRule{{
			APIGroups: []string{"database.sample.third.party"},
			Verbs:     []string{"get", "list", "watch", "create", "delete", "patch", "update"},
			Resources: []string{"databasebackups"},
		}, {
			APIGroups: []string{"database.sample.third.party"},
			Verbs:     []string{"get", "list", "watch", "create", "delete", "patch", "update"},
			Resources: []string{"databasebackups/status"},
		}},
	}

	ctrl.SetControllerReference(databasebackup, clusterRole, reconciler.Scheme)
	return clusterRole
}

func (reconciler *DatabaseBackupReconciler) reconcileClusterRole(ctx context.Context, databasebackup *databasesamplev1alpha1.DatabaseBackup) (ctrl.Result, error) {
	log := log.FromContext(ctx)
	clusterRoleDefinition := reconciler.defineClusterRole(databasebackup)
	clusterRole := &v1.ClusterRole{}
	err := reconciler.Get(ctx, types.NamespacedName{Name: variables.BackupRoleName, Namespace: databasebackup.Namespace}, clusterRole)
	if err != nil {
		if errors.IsNotFound(err) {
			log.Info("ClusterRole resource " + variables.BackupRoleName + " not found. Creating or re-creating ClusterRole")
			err = reconciler.Create(ctx, clusterRoleDefinition)
			if err != nil {
				log.Info("Failed to create ClusterRole resource. Re-running reconcile.")
				return ctrl.Result{}, err
			}
		} else {
			log.Info("Failed to get ClusterRole resource " + variables.BackupRoleName + ". Re-running reconcile.")
			return ctrl.Result{}, err
		}
	} else {
		// Note: For simplication purposes services are not updated - see deployment section
	}
	return ctrl.Result{}, nil
}
