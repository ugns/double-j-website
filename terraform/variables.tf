variable "gh_action_role" {
  description = "AWS IAM ARN for Terraform GitHub Actions"
  type        = string
}

variable "repository" {
  description = "Source respository"
  type        = string
}

variable "domain_name" {
  description = "The domain name to host site"
  type        = string
}

variable "aliases" {
  description = "Additional aliases for Cloudfront"
  type        = list(string)
  default     = []
}

variable "contact_recipient_email" {
  description = "Email address that receives contact form submissions"
  type        = string
}