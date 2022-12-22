# SSL Certificate for the eng-sandbox domain used to register
# created clusters domains

resource "aws_acm_certificate" "eng_sandbox" {
  domain_name       = "*.eng-sandbox.weave.works"
  validation_method = "DNS"
  tags              = local.common_tags
}

resource "aws_route53_record" "eng_sandbox" {
  for_each = {
    for dvo in aws_acm_certificate.eng_sandbox.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = "Z077228227PQNG000XADR"
}

resource "aws_acm_certificate_validation" "eng_sandbox" {
  certificate_arn         = aws_acm_certificate.eng_sandbox.arn
  validation_record_fqdns = [for record in aws_route53_record.eng_sandbox : record.fqdn]
}
