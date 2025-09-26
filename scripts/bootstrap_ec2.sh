#!/usr/bin/env bash
set -e

APP_DIR="/var/www/roboapp"
PY_ENV="/opt/roboapp-venv"

# Install system deps (works on Amazon Linux or Ubuntu)
dnf -y update || apt-get update -y
(dnf -y install python3 python3-pip git nginx || apt-get install -y python3 python3-pip git nginx)

# Create app dir & set permissions for default user (either ec2-user or ubuntu)
mkdir -p $APP_DIR
chown -R ec2-user:ec2-user $APP_DIR || chown -R ubuntu:ubuntu $APP_DIR

# Python venv
python3 -m venv $PY_ENV
source $PY_ENV/bin/activate
pip install --upgrade pip

# Nginx reverse proxy to Gunicorn on 8000
cat >/etc/nginx/conf.d/roboapp.conf <<'NGX'
server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
NGX
rm -f /etc/nginx/conf.d/default.conf || true
systemctl enable nginx
systemctl restart nginx

echo "Bootstrap complete. Deploy once to install app & start service."
