package backup

import (
	"context"
	"fmt"

	databaseoperatorv1alpha1 "github.com/ibm/operator-sample-go/operator-database/api/v1alpha1"
)

func getBackupResource(ctx context.Context, name string, namespace string) {
	databaseBackup := &databaseoperatorv1alpha1.DatabaseBackup{}
	fmt.Println(databaseBackup)

	/*err := reconciler.Get(ctx, types.NamespacedName{Name: application.Spec.DatabaseName, Namespace: application.Spec.DatabaseNamespace}, database)
	if err != nil {
		if errors.IsNotFound(err) {
			//add condition
		} else {
			//happy path
		}
	} else  {
		//add condition
	}
	*/
}
