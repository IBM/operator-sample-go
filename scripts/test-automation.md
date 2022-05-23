# Test automation

### Kubernetes

| Operator | Verification | Needed configuration | Test sequence | Verification Point |
| --- | --- | --- | --- | --- |
| Database | Database was created | Database operator installed, CR for test defined | 1. Verify prerequisite, 2. Create yaml for test instance CR resource, 3. Apply yaml for test instance CR resource, 4. Verify the instances, 5. Delete the test instance | If a database was instantiated and two pods of the stateful set are running. | 
| Database | Backup on IBM Cloud Object Storage | Operator installed, Object Storage Configured, Backup Application was instantiated by the Database operator | TBD | TBD | No, needs to be defined. |
| Application | Application was create | Database Custer Service Version is available, Application was create in version beta | TBD |  TBD | No |
| Application | Application scaling| Database Custer Service Version is available, Application was create in version beta, Application scaler was instantiated by application operator | TBD | No, needs to be defined. |

### OpenShift

| Operator | Verification | Needed configuration | Test sequence | Verification Point | Implemented |
| --- | --- | --- | --- |  --- |  --- |
| Database | Database was created | Database operator installed, CR for test defined | 1. Verify prerequisite, 2. Create yaml for test instance CR resource, 3. Apply yaml for test instance CR resource, 4. Verify the instances, 5. Delete the test instance | If a database was instantiated and two pods of the stateful set are running. |  Yes |
| Database | Backup on IBM Cloud Object Storage | Operator installed, Object Storage Configured, Backup Application was instantiated by the Database operator | TBD | TBD | No, needs to be defined. |
| Application | Application was create | Database Custer Service Version is available, Application was create in version beta | TBD | TBD | No |
| Application | Application scaling| Database Custer Service Version is available, Application was create in version beta, Application scaler was instantiated by application operator | TBD | TBD |  No, needs to be defined. |

