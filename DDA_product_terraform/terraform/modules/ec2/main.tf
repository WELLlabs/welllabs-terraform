# ============================================
# EC2 Module
# ============================================


# INSTANCE TYPE: c5.large (2 vCPUs, 4 GB RAM)
# AMI: Ubuntu 22.04 (latest)
# ============================================



# Generate SSH Key Pair via Terraform
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.ssh_key.public_key_openssh

  tags = {
    Name = "${var.project_name}-${var.environment}-key-pair"
  }
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.generated_key.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.instance_profile_name

  # Userdata installs Docker, Nginx, CloudWatch, CodeDeploy
  user_data = templatefile("${path.module}/../../userdata/install.sh", {
    project_name = var.project_name
    environment  = var.environment
  })


  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name       = "${var.project_name}-${var.environment}-app-server"
    CodeDeploy = "${var.project_name}-${var.environment}"
  }
}

# Elastic IP - Static public IP that survives reboots
resource "aws_eip" "app_eip" {
  instance = aws_instance.app_server.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-eip"
  }

}