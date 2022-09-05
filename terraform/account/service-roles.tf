#
# Create the various service/machine IAM roles
#
# There's a load of service linked roles to create and 2 roles specifically
# for EKS: the cluster role (used by the cluster to manage, e.g. EC2) and the
# worker node instance profile (used to find the cluster & access ECR).
#

# Create the service linked roles
locals {
  eks_service_linked_roles = [
    "autoscaling.amazonaws.com",
    "ec2scheduled.amazonaws.com",
    "eks-fargate.amazonaws.com",
    "eks-nodegroup.amazonaws.com",
    "eks.amazonaws.com",
    "elasticloadbalancing.amazonaws.com",
    "spot.amazonaws.com",
    "spotfleet.amazonaws.com",
    "transitgateway.amazonaws.com",
  ]
}

resource "aws_iam_service_linked_role" "eks_service_roles" {
  for_each = toset(local.eks_service_linked_roles)

  aws_service_name = each.value
}

# Create the EKS cluster management role
# cf. https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html
#    (step 1 > a > 'show more')
module "eks_cluster_role" {
  source = "./modules/aws_service_role"

  name                   = "WeaveEksClusterRole"
  description            = "Role for managing EKS cluster membership and resources"
  service_identifier     = "eks"
  aws_policies_to_attach = ["AmazonEKSClusterPolicy"]
  tags                   = local.common_tags
}

# Create the worker node role
# cf https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html#create-worker-node-role
module "eks_worker_node_role" {
  source = "./modules/aws_service_role"

  name               = "WeaveEksWorkerNodeRole"
  description        = "Role for use by EKS nodes to read ECR & discover the EKS cluster"
  service_identifier = "ec2"
  aws_policies_to_attach = [
    "AmazonEC2ContainerRegistryReadOnly",
    "AmazonEKS_CNI_Policy",
    "AmazonEKSWorkerNodePolicy",
  ]
  tags = local.common_tags
}


resource "aws_iam_instance_profile" "eks_worker_node_role" {
  name = module.eks_worker_node_role.role.name
  role = module.eks_worker_node_role.role.name
}
