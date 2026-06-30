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

resource "aws_cloudwatch_log_group" "backend" {
  name              = "/${var.project_name}-${var.environment}/backend"
  retention_in_days = 30

  tags = { Name = "${var.project_name}-${var.environment}-backend" }
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/${var.project_name}-${var.environment}/frontend"
  retention_in_days = 30

  tags = { Name = "${var.project_name}-${var.environment}-frontend" }
}
