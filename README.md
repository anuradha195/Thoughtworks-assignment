# Thoughtworks-assignment - Mediawiki deployment


# Structure
Folder "Thoughtworks-assignment" is a root of tree/layered structure for all components.
Subfolders contain nested layers of infrastructure.


# Execution
This Component has ops.sh script to manage create and delete jobs.
All parameters are set, so execution as simple as:

Create: */ops.sh create*

Update: */ops.sh update*

Delete: */ops.sh delete*

-> Above script will install kubernetes cluster with eks-cluster.yaml file.
-> Then, Install necessary Kubernetes tools with install-kubernetes-tools.sh script
-> Once the infrastructure is ready, deploy our customized Helm Charts (available in Helm directory of root folder).

Install: *helm install mediawiki-helm-deployment /path-to-helm-directory/*

-> Please find screenshots of my deployment attached.

