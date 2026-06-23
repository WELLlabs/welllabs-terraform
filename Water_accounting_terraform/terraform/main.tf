
# Data sources for default VPC
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 1. SECURITY GROUP
module "security_group" {
  source = "./modules/security_group"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = data.aws_vpc.default.id
  my_ip        = var.my_ip
}

# 5. SECRETS MANAGER — creates the secret container; fill values manually in AWS Console
module "secrets_manager" {
  source = "./modules/secrets_manager"

  project_name = var.project_name
  environment  = var.environment
}

# 2. IAM
module "iam" {
  source = "./modules/iam"

  project_name   = var.project_name
  environment    = var.environment
  app_secret_arn = module.secrets_manager.secret_arn
}

# 3. EC2 (key pair is created inside the module)
module "ec2" {
  source = "./modules/ec2"

  project_name          = var.project_name
  environment           = var.environment
  instance_type         = var.instance_type
  key_pair_name         = var.key_pair_name
  subnet_id             = data.aws_subnets.default.ids[0]
  security_group_id     = module.security_group.sg_id
  instance_profile_name = module.iam.ec2_instance_profile_name
  ami_id                = var.ami_id
}

# 4. Store SSH key .pem in S3 state bucket
resource "aws_s3_object" "ssh_private_key" {
  bucket  = "${var.project_name}-terraform-state"
  key     = "Infra/${var.key_pair_name}.pem"
  content = module.ec2.private_key_pem
}

# 6. S3 (Pipeline Artifacts)
module "s3" {
  source = "./modules/s3"

  project_name = var.project_name
  environment  = var.environment
}

# 7. PIPELINE
module "pipeline" {
  source = "./modules/pipeline"

  project_name          = var.project_name
  environment           = var.environment
  s3_bucket_name        = module.s3.bucket_name
  s3_bucket_arn         = module.s3.bucket_arn
  codebuild_role_arn    = module.iam.codebuild_role_arn
  codebuild_role_id     = module.iam.codebuild_role_id
  codedeploy_role_arn   = module.iam.codedeploy_role_arn
  codepipeline_role_arn = module.iam.codepipeline_role_arn
  codepipeline_role_id  = module.iam.codepipeline_role_id
  github_owner          = var.github_owner
  github_repo           = var.github_repo
  github_branch         = var.github_branch
  codestar_connection_arn = var.codestar_connection_arn
  ec2_ip_address        = module.ec2.public_ip
  app_secret_arn        = module.secrets_manager.secret_arn

  depends_on = [module.ec2, module.secrets_manager]
}

# 8. CLOUDWATCH
module "cloudwatch" {
  source = "./modules/cloudwatch"

  project_name = var.project_name
  environment  = var.environment
}

# 9. CLOUDFRONT
module "cloudfront" {
  source = "./modules/cloudfront"

  project_name                   = var.project_name
  environment                    = var.environment
  s3_bucket_id                   = module.s3.well_labs_bucket_name
  s3_bucket_arn                  = module.s3.well_labs_bucket_arn
  s3_bucket_regional_domain_name = module.s3.well_labs_bucket_regional_domain_name
}
