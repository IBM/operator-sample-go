package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

type DatabaseSpec struct {
	User        string `json:"user,omitempty"`
	Password    string `json:"password,omitempty"`
	Url         string `json:"url,omitempty"`
	Certificate string `json:"certificate,omitempty"`
}

type DatabaseStatus struct {
}

//+kubebuilder:object:root=true
//+kubebuilder:subresource:status

type Database struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	Spec   DatabaseSpec   `json:"spec,omitempty"`
	Status DatabaseStatus `json:"status,omitempty"`
}

//+kubebuilder:object:root=true

type DatabaseList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []Database `json:"items"`
}

func init() {
	SchemeBuilder.Register(&Database{}, &DatabaseList{})
}
