package v1alpha1

import (
	"github.com/ibm/operator-sample-go/operator-application/api/v1beta1"
	"github.com/ibm/operator-sample-go/operator-application/variables"
	"sigs.k8s.io/controller-runtime/pkg/conversion"
	logf "sigs.k8s.io/controller-runtime/pkg/log"
)

var applicationlog = logf.Log.WithName("application-resource")

// convert this version (src = v1alpha1) to the hub version (dst = v1beta1)
func (src *Application) ConvertTo(dstRaw conversion.Hub) error {
	applicationlog.Info("Conversion Webhook: From v1alpha1 to v1beta1")
	dst := dstRaw.(*v1beta1.Application)
	dst.Spec.AmountPods = src.Spec.AmountPods
	dst.Spec.DatabaseName = src.Spec.DatabaseName
	dst.Spec.DatabaseNamespace = src.Spec.DatabaseNamespace
	dst.Spec.SchemaUrl = src.Spec.SchemaUrl
	dst.Spec.Version = src.Spec.Version
	dst.Spec.Image = src.Spec.Image

	if src.ObjectMeta.Annotations == nil {
		dst.Spec.Title = variables.DEFAULT_ANNOTATION_TITLE
		applicationlog.Info(dst.Spec.Title)
	} else {
		title, annotationFound := src.ObjectMeta.Annotations[variables.ANNOTATION_TITLE]
		if annotationFound {
			dst.Spec.Title = title
			applicationlog.Info(dst.Spec.Title)
		} else {
			dst.Spec.Title = variables.DEFAULT_ANNOTATION_TITLE
			applicationlog.Info(dst.Spec.Title)
		}
	}

	dst.ObjectMeta = src.ObjectMeta
	dst.Status.Conditions = src.Status.Conditions

	return nil
}

// convert from the hub version (src= v1beta1) to this version (dst = v1alpha1)
func (dst *Application) ConvertFrom(srcRaw conversion.Hub) error {
	applicationlog.Info("Conversion Webhook: From v1beta1 to v1alpha1")
	src := srcRaw.(*v1beta1.Application)
	dst.ObjectMeta = src.ObjectMeta
	dst.Status.Conditions = src.Status.Conditions
	dst.Spec.AmountPods = src.Spec.AmountPods
	dst.Spec.DatabaseName = src.Spec.DatabaseName
	dst.Spec.DatabaseNamespace = src.Spec.DatabaseNamespace
	dst.Spec.SchemaUrl = src.Spec.SchemaUrl
	dst.Spec.Version = src.Spec.Version
	dst.Spec.Image = src.Spec.Image

	if dst.ObjectMeta.Annotations == nil {
		dst.ObjectMeta.Annotations = make(map[string]string)
	}
	dst.ObjectMeta.Annotations[variables.ANNOTATION_TITLE] = string(src.Spec.Title)

	return nil
}
