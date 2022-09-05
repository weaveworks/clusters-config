resource "aws_iam_role" "readonly" {
  name = "WeaveReadOnly"

  assume_role_policy = data.aws_iam_policy_document.gsuite_trust_policy.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "readonly" {
  role       = aws_iam_role.readonly.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
