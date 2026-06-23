variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
}



variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "key_pair_name" {
  type        = string
  description = "Name of the SSH key pair"
}

variable "my_ip" {
  type        = string
  description = "IP address allowed for SSH access"
}

variable "github_owner" {
  type        = string
  description = "GitHub repository owner"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name"
}

variable "github_branch" {
  type        = string
  description = "GitHub repository branch"
}

variable "ami_id" {
  type        = string
  description = "Custom AMI ID"
}

variable "codestar_connection_arn" {
  description = "The ARN of the CodeStar connection to use for the source code repository."
  type        = string
}
