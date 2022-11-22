package applicationcontroller

import (
	"context"

	applicationsamplev1beta1 "github.com/ibm/operator-sample-go/operator-application/api/v1beta1"
	"github.com/ibm/operator-sample-go/operator-application/utilities"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"sigs.k8s.io/controller-runtime/pkg/log"
)

const CONDITION_STATUS_TRUE = "True"
const CONDITION_STATUS_FALSE = "False"
const CONDITION_STATUS_UNKNOWN = "Unknown"

// Note: Status of RESOURCE_FOUND can only be True; otherwise there is no condition
const CONDITION_TYPE_RESOURCE_FOUND = "ResourceFound"
const CONDITION_REASON_RESOURCE_FOUND = "ResourceFound"
const CONDITION_MESSAGE_RESOURCE_FOUND = "Resource found in k18n"

func (reconciler *ApplicationReconciler) setConditionResourceFound(ctx context.Context,
	application *applicationsamplev1beta1.Application) error {

	if !reconciler.containsCondition(ctx, application, CONDITION_REASON_RESOURCE_FOUND) {
		reconciler.Recorder.Event(application, corev1.EventTypeNormal, CONDITION_REASON_RESOURCE_FOUND, CONDITION_MESSAGE_RESOURCE_FOUND)
		return utilities.AppendCondition(ctx, reconciler.Client, application, CONDITION_TYPE_RESOURCE_FOUND, CONDITION_STATUS_TRUE,
			CONDITION_REASON_RESOURCE_FOUND, CONDITION_MESSAGE_RESOURCE_FOUND)
	}
	return nil
}

// Note: Status of INSTALL_READY can only be True, otherwise there is a failure condition
const CONDITION_TYPE_INSTALL_READY = "InstallReady"
const CONDITION_REASON_INSTALL_READY = "AllRequirementsMet"
const CONDITION_MESSAGE_INSTALL_READY = "All requirements met, attempting install"

func (reconciler *ApplicationReconciler) setConditionInstallReady(ctx context.Context,
	application *applicationsamplev1beta1.Application) error {

	reconciler.deleteCondition(ctx, application, CONDITION_TYPE_FAILED, CONDITION_REASON_FAILED_INSTALL_READY)
	if !reconciler.containsCondition(ctx, application, CONDITION_REASON_INSTALL_READY) {
		reconciler.Recorder.Event(application, corev1.EventTypeNormal, CONDITION_TYPE_INSTALL_READY, CONDITION_MESSAGE_INSTALL_READY)
		return utilities.AppendCondition(ctx, reconciler.Client, application, CONDITION_TYPE_INSTALL_READY, CONDITION_STATUS_TRUE,
			CONDITION_REASON_INSTALL_READY, CONDITION_MESSAGE_INSTALL_READY)
	}
	return nil
}

// Note: Status of FAILED can only be True
const CONDITION_TYPE_FAILED = "Failed"
const CONDITION_REASON_FAILED_INSTALL_READY = "RequirementsNotMet"
const CONDITION_MESSAGE_FAILED_INSTALL_READY = "Not all requirements met"

func (reconciler *ApplicationReconciler) setConditionFailed(ctx context.Context,
	application *applicationsamplev1beta1.Application, reason string) error {

	var message string
	switch reason {
	case CONDITION_REASON_FAILED_INSTALL_READY:
		message = CONDITION_MESSAGE_FAILED_INSTALL_READY
	}

	if !reconciler.containsCondition(ctx, application, reason) {
		reconciler.Recorder.Event(application, corev1.EventTypeWarning, CONDITION_TYPE_FAILED, CONDITION_MESSAGE_FAILED_INSTALL_READY)
		return utilities.AppendCondition(ctx, reconciler.Client, application, CONDITION_TYPE_FAILED, CONDITION_STATUS_TRUE,
			reason, message)
	}
	return nil
}

// Note: Status of DATABASE_EXISTS can be True or False
const CONDITION_TYPE_DATABASE_EXISTS = "DatabaseExists"
const CONDITION_REASON_DATABASE_EXISTS = "DatabaseExists"
const CONDITION_MESSAGE_DATABASE_EXISTS = "The database exists"

func (reconciler *ApplicationReconciler) setConditionDatabaseExists(ctx context.Context,
	application *applicationsamplev1beta1.Application, status metav1.ConditionStatus) error {

	if !reconciler.containsCondition(ctx, application, CONDITION_REASON_DATABASE_EXISTS) {
		return utilities.AppendCondition(ctx, reconciler.Client, application, CONDITION_TYPE_DATABASE_EXISTS, status,
			CONDITION_REASON_DATABASE_EXISTS, CONDITION_MESSAGE_DATABASE_EXISTS)
	} else {
		currentStatus := reconciler.getConditionStatus(ctx, application, CONDITION_TYPE_DATABASE_EXISTS)
		if currentStatus != status {
			reconciler.Recorder.Event(application, corev1.EventTypeWarning, CONDITION_TYPE_DATABASE_EXISTS, CONDITION_MESSAGE_DATABASE_EXISTS)
			reconciler.deleteCondition(ctx, application, CONDITION_TYPE_DATABASE_EXISTS, CONDITION_REASON_DATABASE_EXISTS)
			return utilities.AppendCondition(ctx, reconciler.Client, application, CONDITION_TYPE_DATABASE_EXISTS, status,
				CONDITION_REASON_DATABASE_EXISTS, CONDITION_MESSAGE_DATABASE_EXISTS)
		}
	}
	return nil
}

// Note: Status of SUCCEEDED can only be True
const CONDITION_TYPE_SUCCEEDED = "Succeeded"
const CONDITION_REASON_SUCCEEDED = "InstallSucceeded"
const CONDITION_MESSAGE_SUCCEEDED = "Application has been installed"

func (reconciler *ApplicationReconciler) setConditionSucceeded(ctx context.Context,
	application *applicationsamplev1beta1.Application) error {

	if !reconciler.containsCondition(ctx, application, CONDITION_REASON_SUCCEEDED) {
		reconciler.Recorder.Event(application, corev1.EventTypeNormal, CONDITION_REASON_SUCCEEDED, CONDITION_MESSAGE_SUCCEEDED)
		return utilities.AppendCondition(ctx, reconciler.Client, application, CONDITION_TYPE_SUCCEEDED, CONDITION_STATUS_TRUE,
			CONDITION_REASON_SUCCEEDED, CONDITION_MESSAGE_SUCCEEDED)
	}
	return nil
}

// Note: Status of DELETION_REQUEST_RECEIVED can only be True
const CONDITION_TYPE_DELETION_REQUEST_RECEIVED = "DeletionRequestReceived"
const CONDITION_REASON_DELETION_REQUEST_RECEIVED = "DeletionRequestReceived"
const CONDITION_MESSAGE_DELETION_REQUEST_RECEIVED = "Application is supposed to be deleted"

func (reconciler *ApplicationReconciler) setConditionDeletionRequestReceived(ctx context.Context,
	application *applicationsamplev1beta1.Application) error {

	if !reconciler.containsCondition(ctx, application, CONDITION_REASON_DELETION_REQUEST_RECEIVED) {
		reconciler.Recorder.Event(application, corev1.EventTypeNormal, CONDITION_TYPE_DELETION_REQUEST_RECEIVED, CONDITION_MESSAGE_DELETION_REQUEST_RECEIVED)
		return utilities.AppendCondition(ctx, reconciler.Client, application, CONDITION_TYPE_DELETION_REQUEST_RECEIVED, CONDITION_STATUS_TRUE,
			CONDITION_REASON_DELETION_REQUEST_RECEIVED, CONDITION_MESSAGE_DELETION_REQUEST_RECEIVED)
	}
	return nil
}

func (reconciler *ApplicationReconciler) getConditionStatus(ctx context.Context, application *applicationsamplev1beta1.Application,
	typeName string) metav1.ConditionStatus {

	var output metav1.ConditionStatus = CONDITION_STATUS_UNKNOWN
	for _, condition := range application.Status.Conditions {
		if condition.Type == typeName {
			output = condition.Status
		}
	}
	return output
}

// Note: Status of DELETION_REQUEST_RECEIVED can only be True
const CONDITION_TYPE_DELETECONDITION = "Update failed"
const CONDITION_REASON_DELETECONDITION = "Update failed"
const CONDITION_MESSAGE_DELETECONDITION = "Application resource status update failed."

func (reconciler *ApplicationReconciler) deleteCondition(ctx context.Context, application *applicationsamplev1beta1.Application,
	typeName string, reason string) error {

	log := log.FromContext(ctx)
	var newConditions = make([]metav1.Condition, 0)
	for _, condition := range application.Status.Conditions {
		if condition.Type != typeName && condition.Reason != reason {
			newConditions = append(newConditions, condition)
		}
	}
	application.Status.Conditions = newConditions

	err := reconciler.Client.Status().Update(ctx, application)
	if err != nil {
		reconciler.Recorder.Event(application, corev1.EventTypeWarning, CONDITION_REASON_DELETECONDITION, CONDITION_MESSAGE_DELETECONDITION)
	}
	return nil
}

// TODO: Move to uti
func (reconciler *ApplicationReconciler) containsCondition(ctx context.Context,
	application *applicationsamplev1beta1.Application, reason string) bool {

	output := false
	for _, condition := range application.Status.Conditions {
		if condition.Reason == reason {
			output = true
		}
	}
	return output
}
