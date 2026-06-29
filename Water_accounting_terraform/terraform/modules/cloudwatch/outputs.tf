# ============================================
# CloudWatch Module - Outputs
# ============================================

output "syslog_log_group" {
  description = "CloudWatch log group for system logs"
  value       = aws_cloudwatch_log_group.syslog.name
}

output "userdata_log_group" {
  description = "CloudWatch log group for userdata logs"
  value       = aws_cloudwatch_log_group.userdata.name
}

output "codebuild_log_group" {
  description = "CloudWatch log group for CodeBuild logs"
  value       = aws_cloudwatch_log_group.codebuild.name
}

output "frontend_access_log_group" {
  description = "CloudWatch log group for Nginx frontend access logs"
  value       = aws_cloudwatch_log_group.frontend_access.name
}

output "frontend_error_log_group" {
  description = "CloudWatch log group for Nginx frontend error logs"
  value       = aws_cloudwatch_log_group.frontend_error.name
}

output "deploy_log_group" {
  description = "CloudWatch log group for CodeDeploy deployment logs"
  value       = aws_cloudwatch_log_group.deploy.name
}
