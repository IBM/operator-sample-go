package applicationcontroller

import (
	"context"
	"fmt"
	"time"

	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	"k8s.io/client-go/rest"

	"k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/runtime"

	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/log"
	"sigs.k8s.io/controller-runtime/pkg/metrics"

	applicationsamplev1beta1 "github.com/ibm/operator-sample-go/operator-application/api/v1beta1"
	"github.com/ibm/operator-sample-go/operator-application/variables"
	monitoringv1 "github.com/prometheus-operator/prometheus-operator/pkg/apis/monitoring/v1"
	"github.com/prometheus/client_golang/prometheus"
)

var managerConfig *rest.Config

var countReconcileLaunched = prometheus.NewCounter(
	prometheus.CounterOpts{
		Name: "reconcile_launched_total",
		Help: "reconcile_launched_total",
	},
)

type ApplicationReconciler struct {
	client.Client
	Scheme *runtime.Scheme
}

//+kubebuilder:rbac:groups=database.sample.third.party,resources=databases,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups=application.sample.ibm.com,resources=applications,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups=application.sample.ibm.com,resources=applications/status,verbs=get;update;patch
//+kubebuilder:rbac:groups=application.sample.ibm.com,resources=applications/finalizers,verbs=update
//+kubebuilder:rbac:groups=apps,resources=deployments,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups=core,resources=pods,verbs=get;list;watch
//+kubebuilder:rbac:groups="",resources=secrets,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups="",resources=services,verbs=get;list;watch;create;update;patch;delete

//+kubebuilder:rbac:groups="",resources=clusterrolebindings,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups="",resources=clusterroles,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups="",resources=cronjobs,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups="",resources=jobs,verbs=get;list;watch;create;update;patch;delete

func (reconciler *ApplicationReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	log := log.FromContext(ctx)
	log.Info("Reconcile started")
	countReconcileLaunched.Inc()

	application := &applicationsamplev1beta1.Application{}
	err := reconciler.Get(ctx, req.NamespacedName, application)
	if err != nil {
		if errors.IsNotFound(err) {
			log.Info("Application resource not found. Ignoring since object must be deleted.")
			return ctrl.Result{}, nil
		}
		log.Info("Failed to getyApplication resource. Re-running reconcile.")
		return ctrl.Result{}, err
	}
	err = reconciler.setConditionResourceFound(ctx, application)
	if err != nil {
		return ctrl.Result{}, err
	}

	if !reconciler.checkPrerequisites() {
		log.Info("Prerequisites not fulfilled")
		err = reconciler.setConditionFailed(ctx, application, CONDITION_REASON_FAILED_INSTALL_READY)
		if err != nil {
			return ctrl.Result{}, err
		}
		return ctrl.Result{RequeueAfter: time.Second * 60}, fmt.Errorf("prerequisites not fulfilled")
	}
	err = reconciler.setConditionInstallReady(ctx, application)
	if err != nil {
		return ctrl.Result{}, err
	}

	variables.SetGlobalVariables(application.Name, application.Spec.Image)
	variables.PrintVariables(application.Name, application.Namespace, application.Spec.Version, application.Spec.AmountPods, application.Spec.DatabaseName, application.Spec.DatabaseNamespace)

	_, err = reconciler.tryDeletions(ctx, application)
	if err != nil {
		return ctrl.Result{}, err
	}

	_, err = reconciler.reconcileDatabase(ctx, application)
	if err != nil {
		return ctrl.Result{}, err
	}

	// TODO: Create schema and sample data and check if data from the database can be accessed
	// see https://github.com/IBM/multi-tenancy/blob/a181c562b788f7b5fad99e09b441f93e4489b72f/operator/ecommerceapplication/postgresHelper/postgresHelper.go
	// see http://heidloff.net/article/creating-database-schemas-kubernetes-operators/

	err = reconciler.setConditionDatabaseExists(ctx, application, CONDITION_STATUS_TRUE)
	if err != nil {
		return ctrl.Result{}, err
	}

	_, err = reconciler.reconcileSecret(ctx, application)
	if err != nil {
		return ctrl.Result{}, err
	}

	_, err = reconciler.reconcileDeployment(ctx, application)
	if err != nil {
		return ctrl.Result{}, err
	}

	_, err = reconciler.reconcileService(ctx, application)
	if err != nil {
		return ctrl.Result{}, err
	}

	_, err = reconciler.reconcileMonitor(ctx, application)
	if err != nil {
		return ctrl.Result{}, err
	}

	// Roles for both IKS and OpenShift
	_, err = reconciler.reconcileClusterRole(ctx, application)
	if err != nil {
		return ctrl.Result{}, err
	}

	_, err = reconciler.reconcileClusterRoleBinding(ctx, application)
	if err != nil {
		return ctrl.Result{}, err
	}

	// Additional roles for OpenShift only.
	if runsOnOpenShift {
		_, err = reconciler.reconcileClusterRoleOCP(ctx, application)
		if err != nil {
			return ctrl.Result{}, err
		}

		_, err = reconciler.reconcileClusterRoleBindingOCP(ctx, application)
		if err != nil {
			return ctrl.Result{}, err
		}

	}

	//CronJob - to be beutified
	if !runsOnOpenShift {
		_, err = reconciler.reconcileCronJob(ctx, application)
		if err != nil {
			return ctrl.Result{}, err
		}
	}

	if runsOnOpenShift {
		_, err = reconciler.reconcileCronJobOCP(ctx, application)
		if err != nil {
			return ctrl.Result{}, err
		}
	}

	err = reconciler.setConditionSucceeded(ctx, application)
	if err != nil {
		return ctrl.Result{}, err
	}

	// should put role-all code for K8s and OCP here

	// Note: Commented out for dev productivity only
	/*
		_, err = reconciler.addFinalizer(ctx, application)
		if err != nil {
			return ctrl.Result{}, err
		}
	*/

	return ctrl.Result{}, nil
}

func (reconciler *ApplicationReconciler) SetupWithManager(mgr ctrl.Manager) error {
	managerConfig = mgr.GetConfig()
	metrics.Registry.MustRegister(countReconcileLaunched)

	return ctrl.NewControllerManagedBy(mgr).
		For(&applicationsamplev1beta1.Application{}).
		Owns(&appsv1.Deployment{}).
		Owns(&corev1.Service{}).
		Owns(&corev1.Secret{}).
		Owns(&monitoringv1.ServiceMonitor{}).
		// Note: Possible, but not used in this scenario
		//Owns(&databasesamplev1alpha1.Database{}).
		Complete(reconciler)
}
