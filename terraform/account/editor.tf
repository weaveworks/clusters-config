# Role to be assumed by users to manage EKS clusters
resource "aws_iam_role" "eks_editor" {
  name                 = "WeaveEksEditor"
  assume_role_policy   = data.aws_iam_policy_document.gsuite_trust_policy.json
  max_session_duration = 43200
  tags                 = local.common_tags
}

resource "aws_iam_role_policy" "eks_editor" {
  role   = aws_iam_role.eks_editor.name
  policy = data.aws_iam_policy_document.eks_editor.json
}
