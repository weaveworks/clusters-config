# External DNS policy to allow external dns to update Route53
# record sets for created clusters

data "aws_iam_policy_document" "external_dns_route53" {
  statement {
    sid    = "AllowChangeRecordSets"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets"
    ]
    resources = [
      "arn:aws:route53:::hostedzone/Z077228227PQNG000XADR"
    ]
  }

  statement {
    sid    = "AllowListRecordSets"
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_dns_route53" {
  name        = "AllowExternalDNSUpdates"
  description = "Allow External DNS to update Route53 record sets"
  policy      = data.aws_iam_policy_document.external_dns_route53.json
}
