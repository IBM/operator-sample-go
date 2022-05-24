package applicationcontroller

import (
	"context"
	"fmt"

	applicationsamplev1beta1 "github.com/ibm/operator-sample-go/operator-application/api/v1beta1"
	"github.com/ibm/operator-sample-go/operator-application/variables"
	databasesamplev1alpha1 "github.com/ibm/operator-sample-go/operator-database/api/v1alpha1"
	"k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/types"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/controller/controllerutil"
)

func (reconciler *ApplicationReconciler) finalizeApplication(ctx context.Context, application *applicationsamplev1beta1.Application) error {
	database := &databasesamplev1alpha1.Database{}
	err := reconciler.Get(ctx, types.NamespacedName{Name: application.Spec.DatabaseName, Namespace: application.Spec.DatabaseNamespace}, database)
	if err != nil {
		if errors.IsNotFound(err) {
			return nil
		}
	}
	return fmt.Errorf("database not deleted yet")
}

func (reconciler *ApplicationReconciler) addFinalizer(ctx context.Context, application *applicationsamplev1beta1.Application) (ctrl.Result, error) {
	if !controllerutil.ContainsFinalizer(application, variables.Finalizer) {
		controllerutil.AddFinalizer(application, variables.Finalizer)
		err := reconciler.Update(ctx, application)
		if err != nil {
			return ctrl.Result{}, err
		}
	}
	return ctrl.Result{}, nil
}

func (reconciler *ApplicationReconciler) tryDeletions(ctx context.Context, application *applicationsamplev1beta1.Application) (ctrl.Result, error) {
	isApplicationMarkedToBeDeleted := application.GetDeletionTimestamp() != nil
	if isApplicationMarkedToBeDeleted {
		if controllerutil.ContainsFinalizer(application, variables.Finalizer) {
			if err := reconciler.finalizeApplication(ctx, application); err != nil {
				return ctrl.Result{}, err
			}

			controllerutil.RemoveFinalizer(application, variables.Finalizer)
			err := reconciler.Update(ctx, application)
			if err != nil {
				return ctrl.Result{}, err
			}
		}
		return ctrl.Result{}, nil
	}
	return ctrl.Result{}, nil
}
