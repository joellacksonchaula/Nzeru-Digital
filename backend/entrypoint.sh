#!/bin/sh
# Exit on serious errors but continue on non-critical ones
set -u  # Exit if undefined variable is used

echo "==> Running migrations..."
python manage.py migrate --noinput || {
    echo "ERROR: Migrations failed. Aborting startup."
    exit 1
}

echo "==> Creating superuser (if not exists)..."
python manage.py shell << 'EOF'
import os
import sys
from django.contrib.auth import get_user_model

User = get_user_model()
username = os.environ.get('DJANGO_SUPERUSER_USERNAME', '').strip()
email = os.environ.get('DJANGO_SUPERUSER_EMAIL', '').strip()
password = os.environ.get('DJANGO_SUPERUSER_PASSWORD', '').strip()

if not username or not password:
    print('INFO: Superuser environment variables not set. Skipping creation.')
    sys.exit(0)

try:
    # Check if superuser already exists (by username)
    if User.objects.filter(username=username).exists():
        print(f'INFO: Superuser "{username}" already exists. Skipping creation.')
    else:
        User.objects.create_superuser(
            username=username,
            email=email or f'{username}@example.com',
            password=password
        )
        print(f'SUCCESS: Superuser "{username}" created.')
except Exception as e:
    print(f'WARNING: Could not create superuser: {str(e)}')
    # Don't fail container startup over this
    sys.exit(0)
EOF

echo "==> Collecting static files..."
python manage.py collectstatic --noinput || {
    echo "WARNING: Static file collection had issues, but continuing."
}

echo "==> Starting Gunicorn on port ${PORT:-8000}..."
# Use exec so Gunicorn becomes PID 1 and receives Railway's SIGTERM for graceful shutdown
exec gunicorn config.wsgi:application \
    --bind "0.0.0.0:${PORT:-8000}" \
    --workers 3 \
    --worker-class sync \
    --timeout 120 \
    --max-requests 1000 \
    --max-requests-jitter 100 \
    --log-level info \
    --access-logfile - \
    --error-logfile - \
    --enable-stdio-inheritance