#!/bin/bash


# USAGE:
#   ./deploy.sh [dev|prod]          → Init + Plan + Confirm + Apply
#   ./deploy.sh [dev|prod] destroy  → Destroy resources for the environment
#


set -e

# ============================================
# VALIDATE ARGUMENTS
# ============================================
ENVIRONMENT=$1
ACTION=$2

if [ -z "$ENVIRONMENT" ] || { [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "prod" ]; }; then
    echo "=========================================="
    echo "  WELL LABS — Terraform Deployment Script"
    echo "=========================================="
    echo ""
    echo "  Usage:"
    echo "    ./deploy.sh [dev|prod]             Deploy environment"
    echo "    ./deploy.sh [dev|prod] destroy     Destroy environment"
    echo ""
    echo "  Examples:"
    echo "    ./deploy.sh dev                    Deploy dev environment"
    echo "    ./deploy.sh prod destroy           Destroy prod environment"
    echo ""
    exit 1
fi

if [ -n "$ACTION" ] && [ "$ACTION" != "destroy" ]; then
    echo "Error: Invalid action '$ACTION'. Use 'destroy' or leave empty."
    exit 1
fi

ENV_FILE="${ENVIRONMENT}.tfvars"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: Environment variables file '$ENV_FILE' not found!"
    exit 1
fi

# ============================================
# VARIABLES
# ============================================
PROJECT_NAME=$(grep -E '^project_name\s*=' "$ENV_FILE" | cut -d '"' -f 2)
AWS_REGION=$(grep -E '^aws_region\s*=' "$ENV_FILE" | cut -d '"' -f 2)
KEY_PAIR_NAME=$(grep -E '^key_pair_name\s*=' "$ENV_FILE" | cut -d '"' -f 2)

STATE_BUCKET="${PROJECT_NAME}-terraform-state"
echo "state bucket ${STATE_BUCKET}"
echo "project name ${PROJECT_NAME}"

STATE_REGION="${AWS_REGION}"

# ============================================
# CREATE S3 STATE BUCKET (if not exists)
# ============================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Checking S3 state bucket..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if aws s3api head-bucket --bucket "$STATE_BUCKET" --region "$STATE_REGION" 2>/dev/null; then
    echo "✓ Bucket '$STATE_BUCKET' already exists. Using it."
else
    echo "→ Bucket '$STATE_BUCKET' does not exist. Creating..."
    aws s3api create-bucket \
        --bucket "$STATE_BUCKET" \
        --region "$STATE_REGION" \
        --create-bucket-configuration LocationConstraint="$STATE_REGION"
    echo "✓ Bucket '$STATE_BUCKET' created successfully."
fi
echo ""

# ============================================
# DISPLAY DEPLOYMENT INFO
# ============================================
echo "=========================================="
echo "  WELL LABS — Terraform Deployment"
echo "=========================================="
echo "  Environment : ${ENVIRONMENT}"
if [ "$ACTION" = "destroy" ]; then
    echo "  Mode        : DESTROY"
else
    echo "  Mode        : DEPLOY (init → plan → apply)"
fi
echo "  State       : s3://$STATE_BUCKET/Infra/${ENVIRONMENT}/terraform.tfstate"
echo "  Key .pem    : s3://$STATE_BUCKET/Infra/${KEY_PAIR_NAME}.pem"
echo "=========================================="
echo ""

# ============================================
# STEP 1: TERRAFORM INIT
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  STEP 1: terraform init (${ENVIRONMENT})"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
terraform init -reconfigure -backend-config="key=Infra/${ENVIRONMENT}/terraform.tfstate" -input=false
echo ""
echo "✓ Terraform initialized successfully."
echo ""

# ============================================
# DESTROY MODE
# ============================================
if [ "$ACTION" = "destroy" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ⚠  DESTROY MODE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  This will PERMANENTLY DESTROY all resources in the [${ENVIRONMENT}] environment!"
    echo ""
    read -p "  Are you sure you want to DESTROY all resources? (yes/no): " CONFIRM_DESTROY
    echo ""

    if [ "$CONFIRM_DESTROY" = "yes" ]; then
        echo "→ Running terraform destroy..."
        echo ""
        terraform destroy -var-file="${ENV_FILE}" -auto-approve
        echo ""
        echo "=========================================="
        echo "  ✓ Environment [${ENVIRONMENT}] DESTROYED!"
        echo "=========================================="
    else
        echo "  ✗ Destroy cancelled. No resources were removed."
        exit 0
    fi

    exit 0
fi

# ============================================
# DEPLOY MODE
# ============================================

# ============================================
# STEP 2: TERRAFORM PLAN
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  STEP 2: terraform plan"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
terraform plan -var-file="${ENV_FILE}" -out=tfplan
echo ""

# ============================================
# STEP 3: CONFIRMATION PROMPT
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  STEP 3: Confirm Deployment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Review the plan above carefully."
echo "  This will CREATE/UPDATE real AWS resources for [${ENVIRONMENT}]!"
echo ""
read -p "  Do you want to confirm and apply? (yes/no): " CONFIRM_APPLY
echo ""

if [ "$CONFIRM_APPLY" = "yes" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  STEP 4: terraform apply"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "→ Running terraform apply..."
    echo ""
    terraform apply tfplan
    echo ""
    echo "=========================================="
    echo "  ✓ Deployment completed!"
    echo "=========================================="
    echo ""
    echo "  Download SSH key:"
    echo "    aws s3 cp s3://$STATE_BUCKET/Infra/$KEY_PAIR_NAME.pem ."
    echo ""
else
    echo "  ✗ Deployment cancelled. No changes were applied."
    exit 0
fi
