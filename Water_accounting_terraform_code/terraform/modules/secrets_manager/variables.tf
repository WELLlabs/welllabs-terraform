# ============================================
# Secrets Manager Module — Variables
# ============================================

variable "project_name" {
  type        = string
  description = "Name of the project (used to namespace the secret)"
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev / prod)"
}
