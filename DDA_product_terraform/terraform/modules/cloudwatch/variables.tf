# ============================================
# CloudWatch Module - Variables
# ============================================

variable "project_name" {
  description = "Project name used for resource tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}
