# Modules

module "ses" {
  source  = "cloudposse/ses/aws"
  version = "0.25.2"

  domain            = var.domain_name
  zone_id           = data.aws_route53_zone.this.zone_id
  verify_domain     = true
  verify_dkim       = true
  create_spf_record = true

  ses_user_enabled               = false
  ses_group_enabled              = false
  iam_create_access_key          = false
  iam_create_ses_smtp_password   = false
  custom_from_dns_record_enabled = false

  attributes = ["ses"]
  context    = module.this.context
}

module "contact_lambda" {
  source  = "cloudposse/lambda-function/aws"
  version = "0.6.1"

  function_name = "${module.this.id}-contact"
  description   = "Contact form handler for ${var.domain_name}"
  handler       = "handler.handler"
  runtime       = "python3.12"
  timeout       = 10
  memory_size   = 128

  filename         = data.archive_file.contact_lambda.output_path
  source_code_hash = data.archive_file.contact_lambda.output_base64sha256

  lambda_environment = {
    variables = {
      RECIPIENT_EMAIL = var.contact_recipient_email
      ALLOWED_ORIGIN  = "https://${var.domain_name}"
      SITE_DOMAIN     = var.domain_name
    }
  }

  cloudwatch_logs_retention_in_days = 30

  inline_iam_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ses:SendEmail", "ses:SendRawEmail"]
      Resource = module.ses.ses_domain_identity_arn
    }]
  })

  invoke_function_permissions = [{
    principal  = "apigateway.amazonaws.com"
    source_arn = "${aws_apigatewayv2_api.contact.execution_arn}/*/*"
  }]

  iam_policy_description = "Allows contact form Lambda to send email via SES."

  attributes = ["contact"]
  context    = module.this.context
}

# Resources

resource "aws_apigatewayv2_api" "contact" {
  name          = "${module.this.id}-contact"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["https://${var.domain_name}"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["content-type"]
    max_age       = 3600
  }

  tags = module.this.tags
}

resource "aws_apigatewayv2_stage" "contact" {
  api_id      = aws_apigatewayv2_api.contact.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 10
    throttling_rate_limit  = 5
  }

  tags = module.this.tags
}

resource "aws_apigatewayv2_integration" "contact" {
  api_id                 = aws_apigatewayv2_api.contact.id
  integration_type       = "AWS_PROXY"
  integration_uri        = module.contact_lambda.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "contact" {
  api_id    = aws_apigatewayv2_api.contact.id
  route_key = "POST /contact"
  target    = "integrations/${aws_apigatewayv2_integration.contact.id}"
}

resource "aws_apigatewayv2_route" "contact_options" {
  api_id    = aws_apigatewayv2_api.contact.id
  route_key = "OPTIONS /contact"
  target    = "integrations/${aws_apigatewayv2_integration.contact.id}"
}

# Data sources

data "archive_file" "contact_lambda" {
  type        = "zip"
  source_file = "${path.module}/../lambda/contact/handler.py"
  output_path = "${path.module}/../lambda/contact/handler.zip"
}
