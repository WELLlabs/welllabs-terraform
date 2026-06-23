# ============================================
# EC2 Module - Variables
# ============================================

variable "project_name" {
  description = "Project name used for resource tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (c5.large = 2 vCPUs, 4 GB RAM)"
  type        = string
}

variable "key_pair_name" {
  description = "Name of existing EC2 Key Pair for SSH access"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID where EC2 will be launched"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID to attach to EC2"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM Instance Profile name for EC2"
  type        = string
}

variable "ami_id" {
  description = "Custom AMI ID to use for the EC2 instance"
  type        = string
}
