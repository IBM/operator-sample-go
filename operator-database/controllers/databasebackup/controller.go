package databasebackupcontroller

import (
	"context"

	"k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/runtime"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/log"

	variables "github.com/ibm/operator-sample-go/operator-database/variablesdatabasebackup"

	databasesamplev1alpha1 "github.com/ibm/operator-sample-go/operator-database/api/v1alpha1"
)

// DatabaseBackupReconciler reconciles a DatabaseBackup object
type DatabaseBackupReconciler struct {
	client.Client
	Scheme *runtime.Scheme
}

//+kubebuilder:rbac:groups=database.sample.third.party,resources=databasebackups,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups=database.sample.third.party,resources=databasebackups/status,verbs=get;update;patch
//+kubebuilder:rbac:groups=database.sample.third.party,resources=databasebackups/finalizers,verbs=update

// Reconcile is part of the main kubernetes reconciliation loop which aims to
// move the current state of the cluster closer to the desired state.
// TODO(user): Modify the Reconcile function to compare the state specified by
// the DatabaseBackup object against the actual cluster state, and then
// perform operations to make the cluster state reflect the state specified by
// the user.
//
// For more details, check Reconcile and its Result here:
// - https://pkg.go.dev/sigs.k8s.io/controller-runtime@v0.11.0/pkg/reconcile

func (reconciler *DatabaseBackupReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	log := log.FromContext(ctx)

	log.Info("Reconcile started for DatabaseBackup CRD")

	databasebackup := &databasesamplev1alpha1.DatabaseBackup{}
	err := reconciler.Get(ctx, req.NamespacedName, databasebackup)
	if err != nil {
		if errors.IsNotFound(err) {
			log.Info("DatabaseCluster resource not found. Ignoring since object must be deleted.")
			return ctrl.Result{}, nil
		}
		log.Info("Failed to get DatabaseCluster resource. Re-running reconcile.")
		return ctrl.Result{}, err
	}

	variables.SetGlobalVariables(databasebackup.Name)
	variables.PrintVariables(databasebackup.Name, databasebackup.Namespace, databasebackup.Spec.Repos, databasebackup.Spec.ManualTrigger, databasebackup.Spec.ScheduledTrigger)

	return ctrl.Result{}, nil
}

// SetupWithManager sets up the controller with the Manager.
func (r *DatabaseBackupReconciler) SetupWithManager(mgr ctrl.Manager) error {
	return ctrl.NewControllerManagedBy(mgr).
		For(&databasesamplev1alpha1.DatabaseBackup{}).
		Complete(r)
}
