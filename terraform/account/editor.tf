
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
    sid       = "AllowReadIAM"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "iam:GetInstanceProfile",
      "iam:GetOpenIDConnectProvider",
      "iam:GetPolicy",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfiles",
      "iam:ListInstanceProfilesForRole",
      "iam:ListPolicyVersions",
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

resource "aws_iam_role" "eks_editor" {
  name = "WeaveEksEditor"

  assume_role_policy = data.aws_iam_policy_document.gsuite_trust_policy.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy" "eks_editor" {
  role   = aws_iam_role.eks_editor.name
  policy = data.aws_iam_policy_document.eks_editor.json
}
