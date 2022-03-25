package v1beta1

import (
	"k8s.io/apimachinery/pkg/runtime"
	ctrl "sigs.k8s.io/controller-runtime"
	logf "sigs.k8s.io/controller-runtime/pkg/log"
	"sigs.k8s.io/controller-runtime/pkg/webhook"
)

var applicationlog = logf.Log.WithName("application-resource")

func (r *Application) SetupWebhookWithManager(mgr ctrl.Manager) error {
	return ctrl.NewWebhookManagedBy(mgr).
		For(r).
		Complete()
}

//+kubebuilder:webhook:path=/mutate-application-sample-ibm-com-v1beta1-application,mutating=true,failurePolicy=fail,sideEffects=None,groups=application.sample.ibm.com,resources=applications,verbs=create;update,versions=v1beta1,name=mapplication.kb.io,admissionReviewVersions={v1alpha1,v1beta1}

var _ webhook.Defaulter = &Application{}

func (r *Application) Default() {
	applicationlog.Info("default", "name", r.Name)
	if r.Spec.DatabaseName == "" {
		r.Spec.DatabaseName = "database"
	}
}

//+kubebuilder:webhook:path=/validate-application-sample-ibm-com-v1beta1-application,mutating=false,failurePolicy=fail,sideEffects=None,groups=application.sample.ibm.com,resources=applications,verbs=create;update,versions=v1beta1,name=vapplication.kb.io,admissionReviewVersions={v1alpha1,v1beta1}

var _ webhook.Validator = &Application{}

func (r *Application) ValidateCreate() error {
	applicationlog.Info("validate create", "name", r.Name)
	return nil
}

func (r *Application) ValidateUpdate(old runtime.Object) error {
	applicationlog.Info("validate update", "name", r.Name)
	return nil
}

func (r *Application) ValidateDelete() error {
	applicationlog.Info("validate delete", "name", r.Name)
	return nil
}
