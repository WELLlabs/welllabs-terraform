#!/bin/bash
# ============================================================
#  EC2 UserData — WellLabs Solution Explorer (Minimal)
#  AMI pre-installed: Nginx, CloudWatch Agent, CodeDeploy Agent
#  This script: Starts services + Installs MongoDB 7.0
#  OS: Ubuntu 22.04
# ============================================================
set -e
exec > /var/log/userdata.log 2>&1

echo "=========================================="
echo " WellLabs EC2 UserData Starting: $(date)"
echo "=========================================="

# ─────────────────────────────────────────────────────────────
# [1] System packages (minimal)
# ─────────────────────────────────────────────────────────────
echo "[1/6] Updating system packages..."
apt-get update -y
apt-get install -y curl gnupg2 ca-certificates

# ─────────────────────────────────────────────────────────────
# [2] Node.js 20 LTS (if not in AMI)
# ─────────────────────────────────────────────────────────────
echo "[2/6] Installing Node.js 20..."
if ! command -v node &>/dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt-get install -y nodejs
fi
npm install -g serve 2>/dev/null || true
echo "   Node.js: $(node -v) | npm: $(npm -v)"

# ─────────────────────────────────────────────────────────────
# [3] MongoDB Community 7.0
# ─────────────────────────────────────────────────────────────
echo "[3/6] Installing MongoDB 7.0..."
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc \
  | gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] \
https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" \
  | tee /etc/apt/sources.list.d/mongodb-org-7.0.list

apt-get update -y
apt-get install -y mongodb-org

systemctl start mongod
systemctl enable mongod
echo "   mongod: $(systemctl is-active mongod)"

# ─────────────────────────────────────────────────────────────
# [4] Start Nginx (pre-installed + pre-configured in AMI)
# ─────────────────────────────────────────────────────────────
echo "[4/6] Starting Nginx (pre-installed in AMI)..."
systemctl start nginx
systemctl enable nginx
echo "   nginx: $(systemctl is-active nginx)"

# ─────────────────────────────────────────────────────────────
# [5] Start CodeDeploy Agent (pre-installed in AMI)
# ─────────────────────────────────────────────────────────────
echo "[5/6] Starting CodeDeploy Agent (pre-installed in AMI)..."
systemctl start codedeploy-agent
systemctl enable codedeploy-agent
echo "   CodeDeploy: $(systemctl is-active codedeploy-agent)"

# ─────────────────────────────────────────────────────────────
# [6] Start CloudWatch Agent (pre-installed in AMI)
# ─────────────────────────────────────────────────────────────
echo "[6/6] Configuring + Starting CloudWatch Agent..."

# Write the config file (safe even if AMI already has one)
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/

cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'CW_CONFIG'
{
  "agent": { "run_as_user": "root" },
  "metrics": {
    "metrics_collected": {
      "mem":  { "measurement": ["mem_used_percent"] },
      "disk": { "measurement": ["disk_used_percent"], "resources": ["*"] }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/userdata.log",
            "log_group_name": "/${project_name}-${environment}/userdata",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/opt/welllabs/logs/backend.log",
            "log_group_name": "/${project_name}-${environment}/backend",
            "log_stream_name": "backend-access"
          },
          {
            "file_path": "/opt/welllabs/logs/backend-error.log",
            "log_group_name": "/${project_name}-${environment}/backend-error",
            "log_stream_name": "backend-error"
          },
          {
            "file_path": "/opt/welllabs/logs/frontend.log",
            "log_group_name": "/${project_name}-${environment}/frontend",
            "log_stream_name": "frontend-access"
          },
          {
            "file_path": "/opt/welllabs/logs/frontend-error.log",
            "log_group_name": "/${project_name}-${environment}/frontend",
            "log_stream_name": "frontend-error"
          },
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "/${project_name}-${environment}/syslog",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
CW_CONFIG

# Start agent using the config above
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s 2>/dev/null || echo "   CloudWatch: Will start once IAM role is attached."

echo "   CloudWatch: $(systemctl is-active amazon-cloudwatch-agent 2>/dev/null || echo 'check IAM role')"
# ─────────────────────────────────────────────────────────────
# Runtime directories
# ─────────────────────────────────────────────────────────────
mkdir -p /opt/welllabs/{shared,releases,backend/releases,frontend/releases,deployment,logs}

# ─────────────────────────────────────────────────────────────
# NOTE: .env is NO LONGER written by userdata.
# Secrets are stored in AWS Secrets Manager and fetched at
# deploy time by CodeDeploy's AfterInstall hook (after_install.sh).
# The APP_CONFIG_SECRET_ARN is passed into the artifact by CodeBuild.
# ─────────────────────────────────────────────────────────────

echo ""
echo "=========================================="
echo " UserData COMPLETE: $(date)"
echo " Node.js : $(node -v)"
echo " mongod  : $(systemctl is-active mongod)"
echo " nginx   : $(systemctl is-active nginx)"
echo " codedeploy-agent: $(systemctl is-active codedeploy-agent)"
echo ""
echo " NEXT STEPS:"
echo "   1. terraform apply — creates Secrets Manager secret with real values"
echo "   2. Push code → CodePipeline triggers deploy → AfterInstall fetches secret"
echo "=========================================="