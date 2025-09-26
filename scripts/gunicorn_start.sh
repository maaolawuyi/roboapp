#!/usr/bin/env bash
set -e
APP_DIR="/var/www/roboapp"
PY_ENV="/opt/roboapp-venv"
source $PY_ENV/bin/activate
pip install -r $APP_DIR/requirements.txt
cd $APP_DIR
exec gunicorn -w 2 -b 127.0.0.1:8000 app:app
