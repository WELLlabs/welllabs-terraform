# ============================================================
# Secrets Manager Module — Main
#
# Creates an EMPTY secret resource.
# Terraform only provisions the container — you fill in the
# actual secret values manually in the AWS Console:
#   AWS Console → Secrets Manager → <secret-name> → Retrieve secret value → Edit
#
# Required JSON keys to add manually:
#   PORT, MONGO_URI, JWT_SECRET, ADMIN_EMAIL,
#   CONSULTANT_SECRET, GBA_SECRET, DONOR_SECRET, WELL_LABS_2_SECRET
# ============================================================


resource "aws_secretsmanager_secret" "app_config" {
  name        = "${var.project_name}/${var.environment}/app-config"
  description = "WellLabs DDA Product — application environment variables."

  # Immediate deletion (no recovery window) so re-apply after destroy works cleanly.
  # Set to recovery_window_in_days = 7 for production.
  recovery_window_in_days = 0

  tags = {
    Name        = "${var.project_name}-${var.environment}-app-config"
    Environment = var.environment
    ManagedBy   = "terraform"
    Note        = "Secret values must be filled manually in AWS Console"
  }
}
