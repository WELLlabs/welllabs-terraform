# ============================================
# CloudWatch Module
# ============================================


resource "aws_cloudwatch_log_group" "syslog" {
  name              = "/${var.project_name}-${var.environment}/syslog"
  retention_in_days = 30

  tags = { Name = "${var.project_name}-${var.environment}-syslog" }
}

resource "aws_cloudwatch_log_group" "userdata" {
  name              = "/${var.project_name}-${var.environment}/userdata"
  retention_in_days = 30

  tags = { Name = "${var.project_name}-${var.environment}-userdata" }
}

resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/codebuild/${var.project_name}-${var.environment}"
  retention_in_days = 30

  tags = { Name = "${var.project_name}-${var.environment}-codebuild-logs" }
}

resource "aws_cloudwatch_log_group" "frontend_access" {
  name              = "/${var.project_name}-${var.environment}/frontend-access"
  retention_in_days = 30

  tags = { Name = "${var.project_name}-${var.environment}-frontend-access" }
}

resource "aws_cloudwatch_log_group" "frontend_error" {
  name              = "/${var.project_name}-${var.environment}/frontend-error"
  retention_in_days = 30

  tags = { Name = "${var.project_name}-${var.environment}-frontend-error" }
}

resource "aws_cloudwatch_log_group" "deploy" {
  name              = "/${var.project_name}-${var.environment}/deploy"
  retention_in_days = 30

  tags = { Name = "${var.project_name}-${var.environment}-deploy" }
}
