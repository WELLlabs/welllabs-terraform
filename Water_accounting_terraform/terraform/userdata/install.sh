#!/bin/bash
# ============================================
# EC2 UserData - Install & Enable Services
# ============================================
#
#  This script runs ONCE when the EC2 instance boots.
#  It installs all required software and enables services.
#
#  Pre-installed in AMI:
#   - PostgreSQL
#   - Nginx
#   - CodeDeploy Agent
#   - CloudWatch Agent
#
#  Installed by this script:
#   - PostGIS (PostgreSQL extension)
#   - Python 3.13
#   - GDAL system libraries
#   - Node.js 20
#

set -e
exec > /var/log/userdata.log 2>&1

echo "=========================================="
echo "Starting EC2 UserData"
echo "Date: $(date)"
echo "=========================================="

# 1. Start and enable Nginx
echo "[1/9] Enabling Nginx..."
systemctl start nginx
systemctl enable nginx

# 2. Configure and Start CloudWatch Agent
echo "[2/9] Configuring and Enabling CloudWatch Agent..."

mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'CW_CONFIG'
{
  "agent": {
    "run_as_user": "root"
  },
  "metrics": {
    "metrics_collected": {
      "mem": { "measurement": ["mem_used_percent"] },
      "disk": {
        "measurement": ["disk_used_percent"],
        "resources": ["*"]
      }
    },
    "append_dimensions": {
      "InstanceId": "$${aws:InstanceId}"
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "/${project_name}-${environment}/syslog",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/userdata.log",
            "log_group_name": "/${project_name}-${environment}/userdata",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/nginx/welllabs_access.log",
            "log_group_name": "/${project_name}-${environment}/frontend-access",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/nginx/welllabs_error.log",
            "log_group_name": "/${project_name}-${environment}/frontend-error",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/welllabs-deploy.log",
            "log_group_name": "/${project_name}-${environment}/deploy",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
CW_CONFIG

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s

# 3. Start CodeDeploy Agent
echo "[3/9] Enabling CodeDeploy Agent..."
systemctl restart codedeploy-agent
systemctl enable codedeploy-agent

# 4. Start PostgreSQL and install PostGIS
# echo "[4/9] Enabling PostgreSQL & installing PostGIS..."
# systemctl start postgresql
# systemctl enable postgresql
# apt-get update -y
# apt-get install -y postgresql-14-postgis-3

# 5. Install Python 3.13
echo "[5/9] Installing Python 3.13..."
apt-get install -y software-properties-common
add-apt-repository -y ppa:deadsnakes/ppa
apt-get update -y
apt-get install -y python3.13 python3.13-venv python3.13-dev

# 6. Install GDAL system libraries
echo "[6/9] Installing GDAL & geospatial libraries..."
apt-get install -y gdal-bin libgdal-dev libgeos-dev g++

# 7. Install Node.js 20
echo "[7/9] Installing Node.js 20..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# 8. Create app directories
echo "[8/9] Creating app directories..."
mkdir -p /opt/welllabs/{releases,shared,logs,current}

echo "=========================================="
echo "EC2 UserData Complete!"
echo "Date: $(date)"
echo "=========================================="
