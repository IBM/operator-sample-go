package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

type ApplicationSpec struct {
	//+kubebuilder:default:="1.0.0"
	Version string `json:"version,omitempty"`
	//+kubebuilder:validation:Minimum=0
	//+kubebuilder:default:=1
	AmountPods int32 `json:"amountPods"`
	// +kubebuilder:default:="database"
	DatabaseName string `json:"databaseName,omitempty"`
	// +kubebuilder:default:="databaseNamespace"
	DatabaseNamespace string `json:"databaseNamespace,omitempty"`
	// +kubebuilder:default:="https://raw.githubusercontent.com/IBM/multi-tenancy/main/installapp/postgres-config/create-populate-tenant-a.sql"
	SchemaUrl string `json:"schemaUrl,omitempty"`
	Image     string `json:"image,omitempty"`
}

type ApplicationStatus struct {
	// +patchMergeKey=type
	// +patchStrategy=merge
	// +listType=map
	// +listMapKey=type
	Conditions    []metav1.Condition `json:"conditions"`
	SchemaCreated bool               `json:"schemaCreated"`
}

//+kubebuilder:object:root=true
//+kubebuilder:subresource:status

type Application struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	Spec   ApplicationSpec   `json:"spec,omitempty"`
	Status ApplicationStatus `json:"status,omitempty"`
}

//+kubebuilder:object:root=true

type ApplicationList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []Application `json:"items"`
}

func init() {
	SchemeBuilder.Register(&Application{}, &ApplicationList{})
}

func (application *Application) GetConditions() []metav1.Condition {
	return application.Status.Conditions
}

func (application *Application) SetConditions(conditions []metav1.Condition) {
	application.Status.Conditions = conditions
}
