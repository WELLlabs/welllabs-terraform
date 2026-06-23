#!/bin/bash
# ==============================================================================
#  Cleanup Script for Conflicting AWS Resources
#  Usage: ./cleanup_resources.sh [dev|prod]
# ==============================================================================

ENVIRONMENT=${1:-dev}
PROJECT_NAME="well-labs-solution-explorer"
PREFIX="${PROJECT_NAME}-${ENVIRONMENT}"

echo "=============================================================================="
# Highlight prefix
echo "  Starting cleanup of pre-existing AWS resources for: ${PREFIX}"
echo "=============================================================================="
echo ""

# ──────────────────────────────────────────────────────────────────────────────
# 1. DELETE CLOUDFRONT ORIGIN ACCESS CONTROL (OAC)
# ──────────────────────────────────────────────────────────────────────────────
OAC_NAME="${PREFIX}-oac"
echo "Checking for CloudFront OAC: ${OAC_NAME}..."

OAC_ID=$(aws cloudfront list-origin-access-controls \
  --query "OriginAccessControlList.Items[?OriginAccessControlConfig.Name=='${OAC_NAME}'].Id" \
  --output text 2>/dev/null || true)

if [ -n "$OAC_ID" ] && [ "$OAC_ID" != "None" ]; then
  echo "→ Found CloudFront OAC with ID: ${OAC_ID}. Fetching ETag..."
  ETAG=$(aws cloudfront get-origin-access-control \
    --id "${OAC_ID}" \
    --query "ETag" \
    --output text 2>/dev/null || true)
    
  if [ -n "$ETAG" ] && [ "$ETAG" != "None" ]; then
    echo "→ Deleting CloudFront OAC: ${OAC_ID}..."
    aws cloudfront delete-origin-access-control --id "${OAC_ID}" --if-match "${ETAG}"
    echo "✓ CloudFront OAC deleted successfully."
  else
    echo "⚠ Could not retrieve ETag for OAC ${OAC_ID}."
  fi
else
  echo "✓ No conflicting CloudFront OAC found."
fi
echo ""

# ──────────────────────────────────────────────────────────────────────────────
# 2. DELETE IAM INSTANCE PROFILE
# ──────────────────────────────────────────────────────────────────────────────
INSTANCE_PROFILE_NAME="${PREFIX}-ec2-profile"
EC2_ROLE_NAME="${PREFIX}-ec2-role"

echo "Checking for IAM Instance Profile: ${INSTANCE_PROFILE_NAME}..."
if aws iam get-instance-profile --instance-profile-name "${INSTANCE_PROFILE_NAME}" &>/dev/null; then
  echo "→ Removing role ${EC2_ROLE_NAME} from instance profile ${INSTANCE_PROFILE_NAME}..."
  aws iam remove-role-from-instance-profile \
    --instance-profile-name "${INSTANCE_PROFILE_NAME}" \
    --role-name "${EC2_ROLE_NAME}" 2>/dev/null || true
    
  echo "→ Deleting instance profile ${INSTANCE_PROFILE_NAME}..."
  aws iam delete-instance-profile --instance-profile-name "${INSTANCE_PROFILE_NAME}"
  echo "✓ Instance profile deleted successfully."
else
  echo "✓ No conflicting instance profile found."
fi
echo ""

# ──────────────────────────────────────────────────────────────────────────────
# 3. DELETE IAM ROLES
# ──────────────────────────────────────────────────────────────────────────────
ROLES=(
  "${PREFIX}-ec2-role"
  "${PREFIX}-codebuild-role"
  "${PREFIX}-codedeploy-role"
  "${PREFIX}-codepipeline-role"
)

for ROLE in "${ROLES[@]}"; do
  echo "Checking for IAM Role: ${ROLE}..."
  if aws iam get-role --role-name "${ROLE}" &>/dev/null; then
    echo "→ Found role ${ROLE}. Cleaning up policies..."
    
    # Detach managed policies
    MANAGED_POLICIES=$(aws iam list-attached-role-policies \
      --role-name "${ROLE}" \
      --query "AttachedPolicies[].PolicyArn" \
      --output text 2>/dev/null || true)
      
    for POLICY_ARN in $MANAGED_POLICIES; do
      if [ -n "$POLICY_ARN" ] && [ "$POLICY_ARN" != "None" ]; then
        echo "  - Detaching managed policy: ${POLICY_ARN}"
        aws iam detach-role-policy --role-name "${ROLE}" --policy-arn "${POLICY_ARN}"
      fi
    done
    
    # Delete inline policies
    INLINE_POLICIES=$(aws iam list-role-policies \
      --role-name "${ROLE}" \
      --query "PolicyNames[]" \
      --output text 2>/dev/null || true)
      
    for POLICY_NAME in $INLINE_POLICIES; do
      if [ -n "$POLICY_NAME" ] && [ "$POLICY_NAME" != "None" ]; then
        echo "  - Deleting inline policy: ${POLICY_NAME}"
        aws iam delete-role-policy --role-name "${ROLE}" --policy-name "${POLICY_NAME}"
      fi
    done
    
    # Delete the role
    echo "→ Deleting IAM Role: ${ROLE}..."
    aws iam delete-role --role-name "${ROLE}"
    echo "✓ IAM Role ${ROLE} deleted successfully."
  else
    echo "✓ No conflicting IAM Role found for ${ROLE}."
  fi
  echo ""
done

echo "=============================================================================="
echo "  Cleanup operations complete!"
echo "=============================================================================="
