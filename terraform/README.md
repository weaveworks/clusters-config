# Terraform

This directory contains terraform for provisioning the Engineering Sandbox Account

It does 2 things:

* `./state_bucket`:
  - Create an S3 bucket (`clusters-config-terraform-state`) for use storing state files generated here
* `./account`
  - Creates IAM roles that will be shared across the account:
    + Human assumable roles
      * `WeaveEksEditor` - the standard engineer user. Can create eksctl clusters
      * `WeaveReadOnly` - a readonly user.
    + Some required EKS roles
      * `WeaveEksClusterRole` - role required by EKS to create and manage the cluster
      * `WeaveEksWorkerNodeRole` - a role (instance profile) required by node group instances
    + Service linked roles
