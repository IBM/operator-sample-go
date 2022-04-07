package databaseclustercontroller

import (
	"context"

	variables "github.com/ibm/operator-sample-go/operator-database/variablesdatabasecluster"
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	v1 "k8s.io/api/rbac/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/runtime"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/log"

	databaseclustersamplev1alpha1 "github.com/ibm/operator-sample-go/operator-database/api/v1alpha1"
)

// DatabaseClusterReconciler reconciles a DatabaseCluster object
type DatabaseClusterReconciler struct {
	client.Client
	Scheme *runtime.Scheme
}

//+kubebuilder:rbac:groups=database.sample.third.party,resources=databaseclusters,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups=database.sample.third.party,resources=databaseclusters/status,verbs=get;update;patch
//+kubebuilder:rbac:groups=database.sample.third.party,resources=databaseclusters/finalizers,verbs=update

//+kubebuilder:rbac:groups=apps,resources=statefulsets,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups=core,resources=pods,verbs=get;list;watch
//+kubebuilder:rbac:groups="",resources=secrets,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups="",resources=services,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups="",resources=clusterrolebindings,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups="",resources=clusterroles,verbs=get;list;watch;create;update;patch;delete

// Reconcile is part of the main kubernetes reconciliation loop which aims to
// move the current state of the cluster closer to the desired state.
// TODO(user): Modify the Reconcile function to compare the state specified by
// the DatabaseCluster object against the actual cluster state, and then
// perform operations to make the cluster state reflect the state specified by
// the user.
//
// For more details, check Reconcile and its Result here:
// - https://pkg.go.dev/sigs.k8s.io/controller-runtime@v0.11.0/pkg/reconcile

func (reconciler *DatabaseClusterReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	log := log.FromContext(ctx)

	log.Info("Reconcile started for DatabaseCluster CRD")

	databasecluster := &databaseclustersamplev1alpha1.DatabaseCluster{}
	err := reconciler.Get(ctx, req.NamespacedName, databasecluster)
	if err != nil {
		if errors.IsNotFound(err) {
			log.Info("DatabaseCluster resource not found. Ignoring since object must be deleted.")
			return ctrl.Result{}, nil
		}
		log.Info("Failed to get DatabaseCluster resource. Re-running reconcile.")
		return ctrl.Result{}, err
	}

	variables.SetGlobalVariables(databasecluster.Name)
	variables.PrintVariables(databasecluster.Name, databasecluster.Namespace, databasecluster.Spec.AmountPods)

	_, err = reconciler.reconcileService(ctx, databasecluster)
	if err != nil {
		return ctrl.Result{}, err
	}

	_, err = reconciler.reconcileClusterRole(ctx, databasecluster)
	if err != nil {
		return ctrl.Result{}, err
	}

	_, err = reconciler.reconcileClusterRoleBinding(ctx, databasecluster)
	if err != nil {
		return ctrl.Result{}, err
	}

	_, err = reconciler.reconcileStatefulSet(ctx, databasecluster)
	if err != nil {
		return ctrl.Result{}, err
	}

	return ctrl.Result{}, nil
}

// SetupWithManager sets up the controller with the Manager.
func (reconciler *DatabaseClusterReconciler) SetupWithManager(mgr ctrl.Manager) error {
	return ctrl.NewControllerManagedBy(mgr).
		For(&databaseclustersamplev1alpha1.DatabaseCluster{}).
		Owns(&corev1.Service{}).
		Owns(&appsv1.StatefulSet{}).
		Owns(&v1.ClusterRole{}).
		Owns(&v1.ClusterRoleBinding{}).
		Complete(reconciler)
}
