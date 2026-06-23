# ============================================
# Pipeline Module
# ============================================


# ---- CODEBUILD PROJECT ----
resource "aws_codebuild_project" "main" {
  name          = "${var.project_name}-${var.environment}-build"
  description   = "Packages source code for CodeDeploy deployment"
  service_role  = var.codebuild_role_arn
  build_timeout = 10

  source {
    type      = "CODEPIPELINE"
    buildspec = "devops/buildspec.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ALLOWED_HOSTS"
      value = var.ec2_ip_address
    }

    # ── Secrets Manager: ARN injected so buildspec can write deploy-env ──────
    environment_variable {
      name  = "APP_CONFIG_SECRET_ARN"
      value = var.app_secret_arn
    }

    environment_variable {
      name  = "PROJECT_NAME"
      value = var.project_name
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/codebuild/${var.project_name}-${var.environment}"
      stream_name = "build-log"
    }
  }

  tags = { Name = "${var.project_name}-${var.environment}-build" }
}

# CodeBuild inline policy (needs S3 access)
resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.project_name}-${var.environment}-codebuild-policy"
  role = var.codebuild_role_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:GetObjectVersion", "s3:PutObject", "s3:GetBucketAcl", "s3:GetBucketLocation"]
        Resource = ["${var.s3_bucket_arn}", "${var.s3_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["codestar-connections:UseConnection"]
        Resource = var.codestar_connection_arn
      }
    ]
  })
}

# ---- CODEDEPLOY ----
resource "aws_codedeploy_app" "main" {
  name             = "${var.project_name}-${var.environment}-app"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "main" {
  app_name              = aws_codedeploy_app.main.name
  deployment_group_name = "${var.project_name}-${var.environment}-deployment-group"
  service_role_arn      = var.codedeploy_role_arn

  deployment_style {
    deployment_type   = "IN_PLACE"
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "CodeDeploy"
      type  = "KEY_AND_VALUE"
      value = "${var.project_name}-${var.environment}"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}

# ---- CODEPIPELINE ----
resource "aws_codepipeline" "main" {
  name     = "${var.project_name}-${var.environment}-pipeline"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.s3_bucket_name
    type     = "S3"
  }

  # Stage 1: Source (GitHub)
  stage {
    name = "Source"
    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = "${var.github_owner}/${var.github_repo}"
        BranchName       = var.github_branch
        DetectChanges = "true"
      }
    }
  }

  # Stage 2: Build (CodeBuild)
  stage {
    name = "Build"
    action {
      name             = "CodeBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.main.name
      }
    }
  }

  # Stage 3: Deploy (CodeDeploy → EC2)
  stage {
    name = "Deploy"
    action {
      name            = "CodeDeploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["build_output"]
      configuration = {
        ApplicationName     = aws_codedeploy_app.main.name
        DeploymentGroupName = aws_codedeploy_deployment_group.main.deployment_group_name
      }
    }
  }

  tags = { Name = "${var.project_name}-${var.environment}-pipeline" }
}

# CodePipeline inline policy
resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.project_name}-${var.environment}-codepipeline-policy"
  role = var.codepipeline_role_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:GetObjectVersion", "s3:GetBucketVersioning", "s3:PutObjectAcl", "s3:PutObject"]
        Resource = ["${var.s3_bucket_arn}", "${var.s3_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["codestar-connections:UseConnection"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["codebuild:BatchGetBuilds", "codebuild:StartBuild"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["codedeploy:CreateDeployment", "codedeploy:GetApplication", "codedeploy:GetApplicationRevision", "codedeploy:GetDeployment", "codedeploy:GetDeploymentConfig", "codedeploy:RegisterApplicationRevision"]
        Resource = "*"
      }
    ]
  })
}
