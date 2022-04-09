package databaseclustercontroller

import (
	"context"

	databasesamplev1alpha1 "github.com/ibm/operator-sample-go/operator-database/api/v1alpha1"

	variables "github.com/ibm/operator-sample-go/operator-database/variablesdatabasecluster"
	appsv1 "k8s.io/api/apps/v1"
	v1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/api/resource"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/types"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/log"
)

func (reconciler *DatabaseClusterReconciler) defineStatefulSet(databasecluster *databasesamplev1alpha1.DatabaseCluster) *appsv1.StatefulSet {
	labels := map[string]string{variables.LabelKey: variables.LabelValue}

	service := &appsv1.StatefulSet{
		TypeMeta: metav1.TypeMeta{},
		ObjectMeta: metav1.ObjectMeta{
			Name:      variables.StatefulSetName,
			Namespace: databasecluster.Namespace,
		},
		Spec: appsv1.StatefulSetSpec{
			Replicas: &databasecluster.Spec.AmountPods,
			Selector: &metav1.LabelSelector{
				MatchLabels: labels,
			},
			ServiceName: variables.ServiceName,
			Template: v1.PodTemplateSpec{
				ObjectMeta: metav1.ObjectMeta{
					Labels: labels,
				},
				Spec: v1.PodSpec{
					Containers: []v1.Container{{
						Image:        variables.Image,
						Name:         variables.ContainerName,
						VolumeMounts: []v1.VolumeMount{{Name: variables.VolumeMountName, MountPath: variables.DataDirectory}},
						Ports: []v1.ContainerPort{{
							ContainerPort: variables.Port,
						}},
						Env: []v1.EnvVar{
							{Name: variables.EnvKeyDataDirectory, Value: variables.DataDirectory},
							{Name: variables.EnvKeyPodname, ValueFrom: &v1.EnvVarSource{FieldRef: &v1.ObjectFieldSelector{
								APIVersion: "v1",
								FieldPath:  "metadata.name",
							}}},
							{Name: variables.EnvKeyNamespace, ValueFrom: &v1.EnvVarSource{FieldRef: &v1.ObjectFieldSelector{
								APIVersion: "v1",
								FieldPath:  "metadata.name",
							}}},
						},
					}},
					/*SecurityContext: &v1.PodSecurityContext{
						RunAsGroup: &variables.FsGroup,
						RunAsUser:  &variables.User,
					},*/
				},
			},
			VolumeClaimTemplates: []v1.PersistentVolumeClaim{{
				TypeMeta: metav1.TypeMeta{},
				ObjectMeta: metav1.ObjectMeta{
					Name: variables.VolumeMountName,
				},
				Spec: v1.PersistentVolumeClaimSpec{
					AccessModes: []v1.PersistentVolumeAccessMode{v1.ReadWriteOnce},
					Resources: v1.ResourceRequirements{
						Limits: map[v1.ResourceName]resource.Quantity{},
						Requests: v1.ResourceList{
							v1.ResourceStorage: resource.MustParse("1Gi"),
						},
					},
					StorageClassName: &variables.StorageClassName,
				},
				Status: v1.PersistentVolumeClaimStatus{},
			}},
		},
	}

	ctrl.SetControllerReference(databasecluster, service, reconciler.Scheme)
	return service

}

func (reconciler *DatabaseClusterReconciler) reconcileStatefulSet(ctx context.Context, databasecluster *databasesamplev1alpha1.DatabaseCluster) (ctrl.Result, error) {
	log := log.FromContext(ctx)
	serviceDefinition := reconciler.defineStatefulSet(databasecluster)
	service := &appsv1.StatefulSet{}
	err := reconciler.Get(ctx, types.NamespacedName{Name: variables.StatefulSetName, Namespace: databasecluster.Namespace}, service)
	if err != nil {
		if errors.IsNotFound(err) {
			log.Info("StatefulSet resource " + variables.StatefulSetName + " not found. Creating or re-creating service")
			err = reconciler.Create(ctx, serviceDefinition)
			if err != nil {
				log.Info("Failed to create StatefulSet resource. Re-running reconcile.")
				return ctrl.Result{}, err
			}
		} else {
			log.Info("Failed to get StatefulSet resource " + variables.StatefulSetName + ". Re-running reconcile.")
			return ctrl.Result{}, err
		}
	} else {
		// Note: For simplication purposes StatefulSets are not updated - see deployment section
	}
	return ctrl.Result{}, nil
}
