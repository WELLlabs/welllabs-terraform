# ============================================
#Outputs
# ============================================

# ---- EC2 ----
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2.instance_id
}

output "public_ip" {
  description = "Elastic IP address of the EC2 instance"
  value       = module.ec2.public_ip
}

output "private_key_pem" {
  description = "SSH private key — save with: terraform output -raw private_key_pem > key.pem"
  value       = module.ec2.private_key_pem
  sensitive   = true
}

# ---- S3 & CloudFront ----
output "artifact_bucket" {
  description = "Name of the S3 artifact bucket"
  value       = module.s3.bucket_name
}

output "well_labs_bucket" {
  description = "Name of the S3 well_labs bucket"
  value       = module.s3.well_labs_bucket_name
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = module.cloudfront.cloudfront_domain_name
}

# ---- PIPELINE ----
output "pipeline_name" {
  description = "Name of the CodePipeline"
  value       = module.pipeline.pipeline_name
}


# ---- CLOUDWATCH ----
output "cloudwatch_syslog" {
  description = "CloudWatch log group for system logs"
  value       = module.cloudwatch.syslog_log_group
}

output "cloudwatch_userdata" {
  description = "CloudWatch log group for userdata logs"
  value       = module.cloudwatch.userdata_log_group
}
