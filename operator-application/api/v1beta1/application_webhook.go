package v1beta1

import (
	"strings"

	"github.com/ibm/operator-sample-go/operator-application/variables"
	apierrors "k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/schema"
	validationutils "k8s.io/apimachinery/pkg/util/validation"
	"k8s.io/apimachinery/pkg/util/validation/field"
	ctrl "sigs.k8s.io/controller-runtime"
	logf "sigs.k8s.io/controller-runtime/pkg/log"
	"sigs.k8s.io/controller-runtime/pkg/webhook"
)

var applicationlog = logf.Log.WithName("application-resource")

func (reconciler *Application) SetupWebhookWithManager(mgr ctrl.Manager) error {
	return ctrl.NewWebhookManagedBy(mgr).
		For(reconciler).
		Complete()
}

//+kubebuilder:webhook:path=/mutate-application-sample-ibm-com-v1beta1-application,mutating=true,failurePolicy=fail,sideEffects=None,groups=application.sample.ibm.com,resources=applications,verbs=create;update,versions=v1beta1,name=mapplication.kb.io,admissionReviewVersions={v1alpha1,v1beta1}
var _ webhook.Defaulter = &Application{}

func (reconciler *Application) Default() {
	applicationlog.Info("Default()", "name", reconciler.Name)
	if reconciler.Spec.Title == "" {
		reconciler.Spec.Title = variables.DEFAULT_ANNOTATION_TITLE
	}
}

//+kubebuilder:webhook:path=/validate-application-sample-ibm-com-v1beta1-application,mutating=false,failurePolicy=fail,sideEffects=None,groups=application.sample.ibm.com,resources=applications,verbs=create;update,versions=v1beta1,name=vapplication.kb.io,admissionReviewVersions={v1alpha1,v1beta1}
var _ webhook.Validator = &Application{}

func (reconciler *Application) ValidateCreate() error {
	applicationlog.Info("ValidateCreate()", "name", reconciler.Name)
	return reconciler.validate()
}

func (reconciler *Application) ValidateUpdate(old runtime.Object) error {
	applicationlog.Info("ValidateUpdate()", "name", reconciler.Name)
	return reconciler.validate()
}

func (reconciler *Application) ValidateDelete() error {
	applicationlog.Info("ValidateDelete()", "name", reconciler.Name)
	return nil
}

func (reconciler *Application) validateName() *field.Error {
	// Note: Names of Kubernetes objects can only have a length is 63 characters
	// Note: Since deployment name = application name + ‘-deployment-microservice', the name cannot have more than 35 characters
	if len(reconciler.ObjectMeta.Name) > validationutils.DNS1035LabelMaxLength-24 {
		return field.Invalid(field.NewPath("metadata").Child("name"), reconciler.Name, "must be no more than 35 characters")
	}
	return nil
}

func (reconciler *Application) validateSchemaUrl() *field.Error {
	if !strings.HasPrefix(reconciler.Spec.SchemaUrl, "http") {
		return field.Invalid(field.NewPath("spec").Child("schemaUrl"), reconciler.Name, "must start with 'http'")
	}
	return nil
}

func (reconciler *Application) validate() error {
	var allErrors field.ErrorList
	if err := reconciler.validateSchemaUrl(); err != nil {
		allErrors = append(allErrors, err)
	}
	if err := reconciler.validateName(); err != nil {
		allErrors = append(allErrors, err)
	}
	if len(allErrors) == 0 {
		return nil
	}
	return apierrors.NewInvalid(
		schema.GroupKind{Group: GroupVersion.Group, Kind: reconciler.Kind},
		reconciler.Name, allErrors)
}
