output "resource_id" {
  description = "Cloud Posse label ID used across resources"
  value       = module.this.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.cdn.cf_domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cdn.cf_id
}

output "s3_bucket_name" {
  description = "S3 origin bucket name"
  value       = module.cdn.s3_bucket
}

output "s3_bucket_arn" {
  description = "S3 origin bucket ARN"
  value       = module.cdn.s3_bucket_arn
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN"
  value       = module.acm.arn
}

output "website_url" {
  description = "Primary website URL"
  value       = "https://${var.domain_name}"
}

output "contact_api_url" {
  description = "Contact form API endpoint URL"
  value       = "${aws_apigatewayv2_api.contact.api_endpoint}/contact"
}
