# ============================================
# Security Group Module - Variables
# ============================================

variable "project_name" {
  description = "Project name used for resource tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "my_ip" {
  description = "Your public IP in CIDR format for SSH access (e.g., 203.0.113.25/32)"
  type        = string
}
