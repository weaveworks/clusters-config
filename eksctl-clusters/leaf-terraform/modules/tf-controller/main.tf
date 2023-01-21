data "aws_iam_policy_document" "tf_controller_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "oidc.eks.eu-north-1.amazonaws.com/id/A2FF98C794569C1C9F6F6A251DCA2404:sub"
      values   = ["system:serviceaccount:flux-system:tf-runner"]
    }

    principals {
      identifiers = ["arn:aws:iam::457472006214:oidc-provider/oidc.eks.eu-north-1.amazonaws.com/id/A2FF98C794569C1C9F6F6A251DCA2404"]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "waleed-tf-runner" {
  assume_role_policy = data.aws_iam_policy_document.waleed-tf-runner.json
  name               = "default_test-control-plane-tf-controller"
}

resource "aws_iam_role_policy_attachment" "waleed-tf-runner" {
  role       = aws_iam_role.waleed-tf-runner.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# kubectl annotate -n flux-system serviceaccount tf-runner eks.amazonaws.com/role-arn="arn:aws:iam::894516026745:role/wge2205-tf-controller"
