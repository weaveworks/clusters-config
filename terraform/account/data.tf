# Common data we may want to use in several places

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "gsuite_trust_policy" {
  statement {
    sid     = "TrustWeaveGsuite"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithSAML"]
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:saml-provider/GSuite"]
    }
    condition {
      test     = "StringEquals"
      variable = "SAML:aud"
      values   = ["https://signin.aws.amazon.com/saml"]
    }
  }

  statement {
    sid     = "TrustAdmin"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AdministratorAccess"]
    }
  }
}

data "aws_iam_policy_document" "github_trust_policy" {
  statement {
    sid     = "TrustGithubOIDC"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:weaveworks/clusters-config:*"]
    }
  }
}

# cf https://eksctl.io/usage/minimum-iam-policies/
# Skip the create service linked roles permissions by creating those roles in tf
data "aws_iam_policy_document" "eks_editor" {
  statement {
    sid       = "AllowEKS"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "autoscaling:*",
      "cloudformation:*",
      "cloudwatch:*",
      "ec2:*",
      "eks:*",
      "elasticloadbalancing:*",
      "logs:PutRetentionPolicy",
    ]
  }

  statement {
    sid    = "AllowSSMParameterAccess"
    effect = "Allow"
    resources = [
      "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/aws/*",
      "arn:aws:ssm:*::parameter/aws/*",
    ]
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]
  }

  statement {
    sid       = "AllowKeyUsage"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:CreateGrant",
      "kms:DescribeKey",
    ]
  }

  statement {
    sid    = "AllowIAM"
    effect = "Allow"
    actions = [
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:GetInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:GetRole",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:AttachRolePolicy",
      "iam:PutRolePolicy",
      "iam:ListInstanceProfiles",
      "iam:AddRoleToInstanceProfile",
      "iam:ListInstanceProfilesForRole",
      "iam:PassRole",
      "iam:DetachRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:GetRolePolicy",
      "iam:GetOpenIDConnectProvider",
      "iam:CreateOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider",
      "iam:ListAttachedRolePolicies",
      "iam:TagRole",
      "iam:GetPolicy",
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:ListPolicyVersions"
    ]
    resources = [
      "arn:aws:iam::894516026745:instance-profile/eksctl-*",
      "arn:aws:iam::894516026745:role/eksctl-*",
      "arn:aws:iam::894516026745:policy/eksctl-*",
      "arn:aws:iam::894516026745:oidc-provider/*",
      "arn:aws:iam::894516026745:role/aws-service-role/eks-nodegroup.amazonaws.com/AWSServiceRoleForAmazonEKSNodegroup",
      "arn:aws:iam::894516026745:role/eksctl-managed-*"
    ]
  }

  statement {
    sid    = "AllowIAMInstanceProfile"
    effect = "Allow"
    actions = [
      "iam:GetInstanceProfile",
      "iam:ListInstanceProfiles",
      "iam:AddRoleToInstanceProfile",
      "iam:ListInstanceProfilesForRole"
    ]
    resources = [
      "arn:aws:iam::894516026745:instance-profile/WeaveEksWorkerNodeRole"
    ]
  }
  statement {
    sid     = "AllowGetAllRoles"
    effect  = "Allow"
    actions = ["iam:GetRole"]
    resources = [
      "arn:aws:iam::894516026745:role/*"
    ]
  }
  statement {
    sid    = "AllowPassingEKSRoles"
    effect = "Allow"
    resources = [
      module.eks_cluster_role.role.arn,
      module.eks_worker_node_role.role.arn,
      aws_iam_instance_profile.eks_worker_node_role.arn,
      aws_iam_service_linked_role.eks_service_roles["eks-nodegroup.amazonaws.com"].arn,
    ]
    actions = ["iam:PassRole"]
  }
}
