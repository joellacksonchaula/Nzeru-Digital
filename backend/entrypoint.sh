#!/bin/sh
# Exit on serious errors but continue on non-critical ones
set -u  # Exit if undefined variable is used

echo "==> Running migrations..."
python manage.py migrate --noinput || {
    echo "ERROR: Migrations failed. Aborting startup."
    exit 1
}

echo "==> Creating superuser (if not exists)..."
python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='nzeru').exists():
    User.objects.create_superuser('nzeru', 'joellacksonchaula@gmail.com', 'nzeru123')
"

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