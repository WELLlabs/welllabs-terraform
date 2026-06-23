# ============================================
# IAM Module - Variables
# ============================================

variable "project_name" {
  description = "Project name used for resource tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "app_secret_arn" {
  description = "ARN of the Secrets Manager app-config secret (scopes EC2 inline policy)"
  type        = string
}
