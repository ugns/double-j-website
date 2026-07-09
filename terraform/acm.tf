module "acm" {
  source  = "cloudposse/acm-request-certificate/aws"
  version = "0.18.1"

  zone_id                           = data.aws_route53_zone.this.zone_id
  domain_name                       = var.domain_name
  subject_alternative_names         = var.aliases
  process_domain_validation_options = true
  wait_for_certificate_issued       = true

  context = module.this.context
}
