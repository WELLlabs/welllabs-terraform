# ============================================
# EC2 Module - Outputs
# ============================================

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "public_ip" {
  description = "Elastic IP address of the EC2 instance"
  value       = aws_eip.app_eip.public_ip
}

output "private_key_pem" {
  description = "Private SSH key (save this to a .pem file for SSH access)"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}
