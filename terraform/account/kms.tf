# KMS decryption policy to be used by flux kustomize-controller
# to decrypt SOPS secrets

data "aws_iam_policy_document" "kms_decrypt" {
  statement {
    sid    = "AllowKMSDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
    resources = [
      aws_kms_key.sops-key.arn,
    ]
  }
}

data "aws_iam_policy_document" "kms_management_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::894516026745:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow access for Key Administrators"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::894516026745:role/AdministratorAccess"]
    }
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key" "sops-key" {
  description              = "KMS key to encrypt/decrypt SOPS secrets used by flux kustomize-controller"
  key_usage                = "ENCRYPT_DECRYPT"   # default
  customer_master_key_spec = "SYMMETRIC_DEFAULT" # default
  policy                   = data.aws_iam_policy_document.kms_management_policy.json
}

resource "aws_kms_alias" "sops-key" {
  name          = "alias/sops-key"
  target_key_id = aws_kms_key.sops-key.key_id
}

resource "aws_iam_policy" "kms_decrypt" {
  name        = "WeaveSopsKmsDecrypt"
  description = "KMS decrypt policy used by flux kustomize-controller to decrypt SOPS secrets"
  policy      = data.aws_iam_policy_document.kms_decrypt.json
}
