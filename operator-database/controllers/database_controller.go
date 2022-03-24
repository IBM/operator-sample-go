package controllers

import (
	"context"

	"k8s.io/apimachinery/pkg/runtime"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/log"

	databasesamplev1alpha1 "github.com/ibm/operator-sample-go/operator-database/api/v1alpha1"
)

type DatabaseReconciler struct {
	client.Client
	Scheme *runtime.Scheme
}

//+kubebuilder:rbac:groups=database.sample.third.party,resources=databases,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups=database.sample.third.party,resources=databases/status,verbs=get;update;patch
//+kubebuilder:rbac:groups=database.sample.third.party,resources=databases/finalizers,verbs=update
func (r *DatabaseReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	log := log.FromContext(ctx)

	log.Info("Reconcile started")

	return ctrl.Result{}, nil
}

func (r *DatabaseReconciler) SetupWithManager(mgr ctrl.Manager) error {
	return ctrl.NewControllerManagedBy(mgr).
		For(&databasesamplev1alpha1.Database{}).
		Complete(r)
}
