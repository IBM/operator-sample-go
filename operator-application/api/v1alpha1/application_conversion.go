package v1alpha1

import (
	"github.com/ibm/operator-sample-go/operator-application/api/v1beta1"
	"sigs.k8s.io/controller-runtime/pkg/conversion"
	logf "sigs.k8s.io/controller-runtime/pkg/log"
)

var applicationlog = logf.Log.WithName("application-resource")

// convert this application to the hub version (v1beta1)
func (src *Application) ConvertTo(dstRaw conversion.Hub) error {
	applicationlog.Info("Calling ConvertTo")
	dst := dstRaw.(*v1beta1.Application)
	dst.Spec.AmountPods = src.Spec.AmountPods
	dst.Spec.DatabaseName = src.Spec.DatabaseName
	dst.Spec.DatabaseNamespace = src.Spec.DatabaseNamespace
	dst.Spec.SchemaUrl = src.Spec.SchemaUrl
	dst.Spec.Version = src.Spec.Version
	dst.Spec.Title = "undefined"
	dst.ObjectMeta = src.ObjectMeta
	dst.Status.Conditions = src.Status.Conditions
	return nil
}

// convert from the hub version (v1beta1) to this version
func (dst *Application) ConvertFrom(srcRaw conversion.Hub) error {
	applicationlog.Info("Calling ConvertFrom")
	src := srcRaw.(*v1beta1.Application)
	dst.Spec.AmountPods = src.Spec.AmountPods
	dst.Spec.DatabaseName = src.Spec.DatabaseName
	dst.Spec.DatabaseNamespace = src.Spec.DatabaseNamespace
	dst.Spec.SchemaUrl = src.Spec.SchemaUrl
	dst.Spec.Version = src.Spec.Version
	dst.ObjectMeta = src.ObjectMeta
	dst.Status.Conditions = src.Status.Conditions
	return nil
}
