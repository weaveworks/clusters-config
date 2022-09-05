data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["${var.service_identifier}.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.name
  tags               = var.tags
  description        = var.description
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = toset(var.aws_policies_to_attach)

  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}
