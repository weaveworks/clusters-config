data "aws_iam_policy_document" "tf_controller_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "oidc.eks.eu-north-1.amazonaws.com/id/A98A063228ABBB91D48C62BFB3AE21F8:sub"
      values   = ["system:serviceaccount:flux-system:tf-runner"]
    }

    principals {
      identifiers = ["arn:aws:iam::457472006214:oidc-provider/oidc.eks.eu-north-1.amazonaws.com/id/A98A063228ABBB91D48C62BFB3AE21F8"]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "tf_controller" {
  assume_role_policy = data.aws_iam_policy_document.tf_controller_assume_role.json
  name               = "default_test-control-plane-tf-controller"
}

resource "aws_iam_role_policy_attachment" "tf_controller" {
  role       = aws_iam_role.tf_controller.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# kubectl annotate -n flux-system serviceaccount tf-runner eks.amazonaws.com/role-arn="arn:aws:iam::894516026745:role/wge2205-tf-controller"
