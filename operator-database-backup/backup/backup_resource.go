package backup

func defineDatabaseResource() {}

/*
	database := &databasesamplev1alpha1.Database{
		ObjectMeta: metav1.ObjectMeta{
			Name:      application.Spec.DatabaseName,
			Namespace: application.Spec.DatabaseNamespace,
		},
		Spec: databasesamplev1alpha1.DatabaseSpec{
			User:        variables.DatabaseUser,
			Password:    variables.DatabasePassword,
			Url:         variables.DatabaseUrl,
			Certificate: variables.DatabaseCertificate,
		},
	}
*/

func getBackupResource(namespace string, name string) {}

/*
	database := &databasesamplev1alpha1.Database{}
	databaseDefinition := defineDatabase(application)
	err := reconciler.Get(ctx, types.NamespacedName{Name: application.Spec.DatabaseName, Namespace: application.Spec.DatabaseNamespace}, database)
	if err != nil {
		if errors.IsNotFound(err) {
			add condition
		} else {
			happy path
		}
	} else  {
		add condition
	}
}
*/
