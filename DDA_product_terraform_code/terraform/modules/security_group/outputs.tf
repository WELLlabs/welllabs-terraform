# ============================================
# Security Group Module - Outputs
# ============================================

output "sg_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2_sg.id
}
