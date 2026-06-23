# ============================================
# Provider Configuration
# ============================================


terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      created_by  = "MeyiCloud"
      aws-apn-id  = "pc:eyl8vo7kcwv8k9qctzbathhiq"
    }
  }
}

# Get current AWS account ID (used by S3 module for unique bucket naming)
data "aws_caller_identity" "current" {}
