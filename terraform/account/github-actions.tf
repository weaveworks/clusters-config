
# Role to be assumed by Github Actions to manage EKS clusters

resource "aws_iam_role" "eks_github_actions" {
  name               = "WeaveEksGithubActions"
  assume_role_policy = data.aws_iam_policy_document.github_trust_policy.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy" "eks_github_actions" {
  role   = aws_iam_role.eks_github_actions.name
  policy = data.aws_iam_policy_document.eks_editor.json
}
