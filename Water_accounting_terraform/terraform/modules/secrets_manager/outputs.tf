# ============================================
# Secrets Manager Module — Outputs
# ============================================

output "secret_arn" {
  description = "ARN of the app-config secret (pass to IAM and CodeBuild)"
  value       = aws_secretsmanager_secret.app_config.arn
}

output "secret_name" {
  description = "Name of the secret in AWS Secrets Manager"
  value       = aws_secretsmanager_secret.app_config.name
}
