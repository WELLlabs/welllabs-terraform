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
  description = "ARN of the Secrets Manager secret — EC2 role is granted GetSecretValue on this ARN"
  type        = string
}
