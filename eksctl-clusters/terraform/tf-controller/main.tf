data "aws_iam_policy_document" "tf_controller_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "oidc.eks.eu-north-1.amazonaws.com/id/66AEA5A038F7AFB34662B2C7CFF3010D:sub"
      values   = ["system:serviceaccount:flux-system:tf-runner"]
    }

    principals {
      identifiers = ["arn:aws:iam::894516026745:oidc-provider/oidc.eks.eu-north-1.amazonaws.com/id/66AEA5A038F7AFB34662B2C7CFF3010D"]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "tf_controller" {
  assume_role_policy = data.aws_iam_policy_document.tf_controller_assume_role.json
  name               = "wge2205-tf-controller"
}

resource "aws_iam_role_policy_attachment" "tf_controller" {
  role       = aws_iam_role.tf_controller.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# kubectl annotate -n flux-system serviceaccount tf-runner eks.amazonaws.com/role-arn="arn:aws:iam::894516026745:role/wge2205-tf-controller"
