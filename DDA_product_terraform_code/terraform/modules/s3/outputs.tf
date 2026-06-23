# ============================================
# S3 Module - Outputs
# ============================================

output "bucket_name" {
  description = "Name of the S3 artifact bucket"
  value       = aws_s3_bucket.artifact_bucket.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 artifact bucket"
  value       = aws_s3_bucket.artifact_bucket.arn
}

output "well_labs_bucket_name" {
  description = "Name of the S3 well_labs bucket"
  value       = aws_s3_bucket.well_labs_bucket.bucket
}

output "well_labs_bucket_arn" {
  description = "ARN of the S3 well_labs bucket"
  value       = aws_s3_bucket.well_labs_bucket.arn
}

output "well_labs_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 well_labs bucket"
  value       = aws_s3_bucket.well_labs_bucket.bucket_regional_domain_name
}
