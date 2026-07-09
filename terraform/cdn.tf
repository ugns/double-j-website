module "cdn" {
  source  = "cloudposse/cloudfront-s3-cdn/aws"
  version = "2.1.1"

  acm_certificate_arn = module.acm.arn
  aliases             = concat([var.domain_name], var.aliases)

  dns_alias_enabled   = true
  parent_zone_id      = data.aws_route53_zone.this.zone_id
  dns_allow_overwrite = true

  origin_access_type                 = "origin_access_control"
  block_origin_public_access_enabled = true
  allow_ssl_requests_only            = true
  default_root_object                = "index.html"

  deployment_principal_arns = {
    (var.gh_action_role) = ["*"]
  }

  custom_error_response = [
    {
      error_code         = 404
      response_code      = 404
      response_page_path = "/404.html"
    },
    {
      error_code         = 403
      response_code      = 403
      response_page_path = "/403.html"
    },
  ]

  context = module.this.context
}
