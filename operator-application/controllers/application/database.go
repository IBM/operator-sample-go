package applicationcontroller

import (
	"context"
	"time"

	applicationsamplev1beta1 "github.com/nheidloff/operator-sample-go/operator-application/api/v1beta1"
	databasesamplev1alpha1 "github.com/nheidloff/operator-sample-go/operator-database/api/v1alpha1"
	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/types"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/log"
)

func (reconciler *ApplicationReconciler) defineDatabase(application *applicationsamplev1beta1.Application) *databasesamplev1alpha1.Database {
	database := &databasesamplev1alpha1.Database{
		ObjectMeta: metav1.ObjectMeta{
			Name:      application.Spec.DatabaseName,
			Namespace: application.Spec.DatabaseNamespace,
		},
		Spec: databasesamplev1alpha1.DatabaseSpec{
			User:        databaseUser,
			Password:    databasePassword,
			Url:         databaseUrl,
			Certificate: databaseCertificate,
		},
	}

	// Note: Possible, but not used in this scenario
	//ctrl.SetControllerReference(application, database, reconciler.Scheme)
	return database
}

func (reconciler *ApplicationReconciler) reconcileDatabase(ctx context.Context, application *applicationsamplev1beta1.Application) (ctrl.Result, error) {
	log := log.FromContext(ctx)
	database := &databasesamplev1alpha1.Database{}
	databaseDefinition := reconciler.defineDatabase(application)
	err := reconciler.Get(ctx, types.NamespacedName{Name: application.Spec.DatabaseName, Namespace: application.Spec.DatabaseNamespace}, database)
	if err != nil {
		if errors.IsNotFound(err) {
			log.Info("Database resource " + application.Spec.DatabaseName + " not found. Creating or re-creating database")
			err = reconciler.setConditionDatabaseExists(ctx, application, CONDITION_STATUS_FALSE)
			if err != nil {
				return ctrl.Result{}, err
			}
			// Note: Creating external resources from controllers is not always recommended for encapsulation and security reasons
			err = reconciler.Create(ctx, databaseDefinition)
			if err != nil {
				log.Info("Failed to create database resource. Re-running reconcile.")
				return ctrl.Result{}, err
			} else {
				// Note: Delay the next loop run since database creation can take time
				return ctrl.Result{RequeueAfter: time.Second * 1}, nil
			}
		} else {
			log.Info("Failed to get database resource " + application.Spec.DatabaseName + ". Re-running reconcile.")
			return ctrl.Result{}, err
		}
	}
	return ctrl.Result{}, nil
}
