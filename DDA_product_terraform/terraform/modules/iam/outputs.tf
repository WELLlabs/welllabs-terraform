# ============================================
# IAM Module - Outputs
# ============================================

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "codebuild_role_arn" {
  description = "ARN of the CodeBuild IAM role"
  value       = aws_iam_role.codebuild_role.arn
}

output "codebuild_role_id" {
  description = "ID of the CodeBuild IAM role (for inline policies)"
  value       = aws_iam_role.codebuild_role.id
}

output "codedeploy_role_arn" {
  description = "ARN of the CodeDeploy IAM role"
  value       = aws_iam_role.codedeploy_role.arn
}

output "codepipeline_role_arn" {
  description = "ARN of the CodePipeline IAM role"
  value       = aws_iam_role.codepipeline_role.arn
}

output "codepipeline_role_id" {
  description = "ID of the CodePipeline IAM role (for inline policies)"
  value       = aws_iam_role.codepipeline_role.id
}
