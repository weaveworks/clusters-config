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
}
