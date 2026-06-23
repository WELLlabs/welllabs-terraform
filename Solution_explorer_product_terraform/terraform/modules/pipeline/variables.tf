# ============================================
# Pipeline Module - Variables
# ============================================

variable "project_name" {
  description = "Project name used for resource tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for storing pipeline artifacts"
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN for IAM policies"
  type        = string
}

variable "codebuild_role_arn" {
  description = "ARN of the CodeBuild IAM role"
  type        = string
}

variable "codebuild_role_id" {
  description = "ID of the CodeBuild IAM role (for inline policies)"
  type        = string
}

variable "codedeploy_role_arn" {
  description = "ARN of the CodeDeploy IAM role"
  type        = string
}

variable "codepipeline_role_arn" {
  description = "ARN of the CodePipeline IAM role"
  type        = string
}

variable "codepipeline_role_id" {
  description = "ID of the CodePipeline IAM role (for inline policies)"
  type        = string
}

variable "codestar_connection_arn" {
  description = "The ARN of the CodeStar connection to use for the source code repository."
  type        = string
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to monitor"
  type        = string
}

variable "ec2_ip_address" {
  description = "The public IP address of the EC2 instance"
  type        = string
}

variable "app_secret_arn" {
  description = "ARN of the Secrets Manager app-config secret — injected into CodeBuild env so buildspec can write deploy-env"
  type        = string
}
