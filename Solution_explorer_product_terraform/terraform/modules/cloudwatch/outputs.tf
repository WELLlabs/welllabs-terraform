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

output "backend_log_group" {
  description = "CloudWatch log group for backend logs (streams: backend-access, backend-error)"
  value       = aws_cloudwatch_log_group.backend.name
}

output "frontend_log_group" {
  description = "CloudWatch log group for frontend logs (streams: frontend-access, frontend-error)"
  value       = aws_cloudwatch_log_group.frontend.name
}
