terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.13.0, < 7"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4.0"
    }
    awsutils = {
      source  = "cloudposse/awsutils"
      version = ">= 0.11.0"
    }
  }

  required_version = ">= 1.0"
}

provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn = var.gh_action_role
  }
}

provider "awsutils" {
  region = "us-east-1"
  assume_role {
    role_arn = var.gh_action_role
  }
}