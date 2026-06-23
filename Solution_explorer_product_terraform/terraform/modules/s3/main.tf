# ============================================
# S3 Module
# ============================================



resource "aws_s3_bucket" "artifact_bucket" {
  bucket        = "${var.project_name}-${var.environment}-pipeline-artifacts"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-${var.environment}-pipeline-artifacts"
  }
}

resource "aws_s3_bucket" "well_labs_bucket" {
  bucket        = "${var.project_name}-${var.environment}-bucket"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-${var.environment}-bucket"
  }
}
