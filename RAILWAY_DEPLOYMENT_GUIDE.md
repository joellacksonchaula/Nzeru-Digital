# Railway Deployment Guide - Complete Configuration

## Overview
This guide provides all Railway-specific deployment requirements and environment variables needed for the Digital Savings Vault backend and frontend. **Local development requirements are maintained separately** (see [Local Development Setup](#local-development-setup) below).

---

## Part 1: Railway Backend Deployment

### Prerequisites
- Railway account (https://railway.app)
- PostgreSQL database provisioned in Railway
- Git repository connected to Railway
- GitHub account linked to Railway

### Step 1: Environment Variables for Railway Dashboard

Navigate to **Railway Dashboard → Your Project → Variables** and add the following environment variables:

#### **Required Core Variables**
```
DJANGO_SECRET_KEY=your-generated-secret-key-here
DJANGO_DEBUG=False
DATABASE_URL=postgresql://user:password@host:5432/dbname
PORT=8000
```

#### **Django Configuration Variables**
```
DJANGO_SUPERUSER_USERNAME=admin
DJANGO_SUPERUSER_EMAIL=admin@yourdomain.com
DJANGO_SUPERUSER_PASSWORD=your-strong-password-here
ALLOWED_HOSTS=savingsutl-production.up.railway.app,.railway.app,localhost,127.0.0.1
```

#### **CORS & Security Variables**
```
EXTRA_CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://app.yourdomain.com
EXTRA_CSRF_TRUSTED_ORIGINS=https://yourdomain.com,https://app.yourdomain.com
```

#### **Optional / Advanced Variables**
```
# For detailed Django logging during deployment
DJANGO_LOG_LEVEL=INFO

# For custom timezone (default: UTC)
TZ=UTC

# For custom admin URLs (security best practice)
ADMIN_URL=admin_custom_path
```

### Step 2: Generate a Strong SECRET_KEY

Run this command locally and copy the output:
```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

Paste the generated key into Railway's `DJANGO_SECRET_KEY` variable.

### Step 3: Database Configuration

Railway automatically creates a PostgreSQL database. To get your `DATABASE_URL`:

1. Go to **Railway Dashboard → Your Project → Variables**
2. Look for auto-generated variable: `DATABASE_URL` (looks like `postgresql://user:pass@host:5432/db`)
3. Railway provides this automatically - **do not modify**

### Step 4: Configure entrypoint.sh for Railway

Ensure your `backend/entrypoint.sh` contains:

```bash
#!/bin/sh
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
    sys.exit(0)
EOF

echo "==> Collecting static files..."
python manage.py collectstatic --noinput || {
    echo "WARNING: Static file collection had issues, but continuing."
}

echo "==> Starting Gunicorn on port ${PORT:-8000}..."
exec gunicorn config.wsgi:application \
    --bind 0.0.0.0:${PORT:-8000} \
    --workers 3 \
    --worker-class sync \
    --timeout 120 \
    --max-requests 1000 \
    --max-requests-jitter 100 \
    --access-logfile - \
    --error-logfile - \
    --log-level info
```

### Step 5: Dockerfile Configuration

Ensure `backend/Dockerfile` is set up for Railway:

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Make entrypoint executable
RUN chmod +x entrypoint.sh

# Railway runs the entrypoint automatically
ENTRYPOINT ["./entrypoint.sh"]
```

### Step 6: Deploy to Railway

```bash
# Commit your changes
git add backend/entrypoint.sh backend/Dockerfile backend/config/settings.py
git commit -m "chore: optimize for Railway deployment"

# Push to trigger automatic deployment
git push origin main
```

Railway will automatically:
1. Build the Docker image
2. Push to its registry
3. Deploy and run the container
4. Execute migrations
5. Create superuser (if needed)
6. Start Gunicorn server

### Step 7: Monitor Deployment

1. Go to **Railway Dashboard → Your Project → Deployments**
2. Click the latest deployment to view logs
3. Look for:
   ```
   ==> Running migrations...
   ==> Creating superuser (if not exists)...
   SUCCESS: Superuser "admin" created.
   ==> Collecting static files...
   ==> Starting Gunicorn on port 8000...
   ```
4. Verify no restart loops occur

### Step 8: Test API Health

```bash
# Replace with your Railway URL
RAILWAY_URL="https://savingsutl-production-bf7e.up.railway.app"

# Health check
curl "$RAILWAY_URL/api/health/"

# Login test
curl -X POST "$RAILWAY_URL/api/auth/login/" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "your-superuser-password"
  }'

# Get current user (use token from login response)
curl "$RAILWAY_URL/api/auth/me/" \
  -H "Authorization: Bearer <access_token>"
```

---

## Part 2: Railway Frontend Deployment

### Option A: Deploy Frontend to Railway (Optional)

If deploying Flutter web frontend to Railway instead of Netlify:

#### Environment Variables for Frontend
```
FLUTTER_ENV=production
API_BASE_URL=https://savingsutl-production-bf7e.up.railway.app
FLUTTER_WEB_HOST=0.0.0.0
FLUTTER_WEB_PORT=8080
```

#### Dockerfile for Flutter Web
```dockerfile
FROM cirrusci/flutter:latest as builder

WORKDIR /app
COPY pubspec.* .
RUN flutter pub get

COPY . .
RUN flutter build web --release

FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
```

### Option B: Deploy Frontend to Netlify (Recommended)

Configure in Netlify dashboard with Railway backend URL in environment variables.

---

## Complete Railway Environment Variables Reference

### Copy-Paste Template

Create a `.env.railway` file locally (never commit this):

```
# Docker & Platform
PORT=8000

# Django Core
DJANGO_SECRET_KEY=<generate-with-command-below>
DJANGO_DEBUG=False
ALLOWED_HOSTS=savingsutl-production.up.railway.app,.railway.app,localhost,127.0.0.1

# Database (Auto-generated by Railway, copy from Railway dashboard)
DATABASE_URL=postgresql://user:password@host:5432/dbname

# Superuser Configuration
DJANGO_SUPERUSER_USERNAME=admin
DJANGO_SUPERUSER_EMAIL=admin@yourdomain.com
DJANGO_SUPERUSER_PASSWORD=<generate-strong-password>

# CORS & Frontend Origins
EXTRA_CORS_ALLOWED_ORIGINS=https://glittering-cobbler-1d32f6.netlify.app,https://yourdomain.com
EXTRA_CSRF_TRUSTED_ORIGINS=https://glittering-cobbler-1d32f6.netlify.app,https://yourdomain.com

# Optional
TZ=UTC
DJANGO_LOG_LEVEL=INFO
```

### Generate Values

```bash
# Generate SECRET_KEY
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

# Generate strong password (optional, use random string)
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

---

## Troubleshooting Railway Deployment

### Container Keeps Restarting

**Check logs:**
```
Railway Dashboard → Deployments → Latest → View Logs
```

**Common causes:**
1. Missing `DATABASE_URL` - Copy from Railway dashboard
2. Invalid `DJANGO_SECRET_KEY` - Regenerate using command above
3. Migration errors - Check database connection
4. Port mismatch - Railway sets `PORT` automatically, ignore defaults

### Superuser Creation Fails

**Error:** "That username is already taken"

**Solution:** Already exists from previous deploy, this is expected and safe.

### Static Files Not Serving

**Ensure in settings.py:**
```python
STATIC_URL = 'static/'
STATIC_ROOT = BASE_DIR / "staticfiles"
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'
```

### CORS Errors on Frontend

**Error:** "Access to XMLHttpRequest blocked by CORS policy"

**Fix:** Add frontend origin to Railway's `EXTRA_CORS_ALLOWED_ORIGINS` variable

---

## Local Development Setup (UNCHANGED)

### Prerequisites
- Python 3.11+
- pip/virtual environment
- PostgreSQL (optional, SQLite works locally)

### Setup Steps

```bash
# Clone repository
git clone <your-repo>
cd savings_utl/backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Create .env file for local development
cat > .env << 'EOF'
DJANGO_SECRET_KEY=your-local-secret-key-at-least-32-characters
DJANGO_DEBUG=True
DATABASE_URL=sqlite:///db.sqlite3
DJANGO_SUPERUSER_USERNAME=admin
DJANGO_SUPERUSER_EMAIL=admin@localhost.com
DJANGO_SUPERUSER_PASSWORD=admin123
PORT=8000
EOF

# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser --noinput \
    --username=admin \
    --email=admin@localhost.com
python manage.py shell << 'EOF'
from django.contrib.auth.models import User
u = User.objects.get(username='admin')
u.set_password('admin123')
u.save()
EOF

# Collect static files
python manage.py collectstatic --noinput

# Run development server
python manage.py runserver 0.0.0.0:8000
```

### Local Testing

```bash
# Health check
curl http://localhost:8000/api/health/

# Login
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'

# Admin panel
# Navigate to: http://localhost:8000/admin/
```

### Local Database Reset

```bash
# Delete SQLite database
rm db.sqlite3

# Re-migrate
python manage.py migrate

# Recreate superuser
python manage.py createsuperuser
```

---

## Summary: Railway vs Local

| Aspect | Railway | Local |
|--------|---------|-------|
| **Database** | PostgreSQL (auto) | SQLite (default) |
| **DEBUG** | False | True |
| **SECRET_KEY** | Generated unique | Default dev key |
| **Superuser** | Auto-created via entrypoint | Manual creation |
| **Static Files** | WhiteNoise compression | Direct serving |
| **PORT** | 8000 (auto-set) | 8000 (configurable) |
| **CORS** | Restricted origins | All origins if DEBUG=True |

---

## Next Steps

1. **Complete Railway Setup:**
   - [ ] Add all environment variables to Railway dashboard
   - [ ] Deploy and verify logs
   - [ ] Test API endpoints
   - [ ] Configure custom domain (optional)

2. **Frontend Integration:**
   - [ ] Update API_BASE_URL in Flutter app
   - [ ] Build and deploy to Netlify or Railway
   - [ ] Test authentication flow

3. **Production Hardening:**
   - [ ] Set up database backups in Railway
   - [ ] Configure monitoring/alerts
   - [ ] Review security settings
   - [ ] Set up custom domain with SSL

---

## Additional Resources

- [Railway Documentation](https://docs.railway.app/)
- [Django Deployment Guide](https://docs.djangoproject.com/en/5.2/howto/deployment/)
- [Gunicorn Configuration](https://docs.gunicorn.org/en/stable/configure.html)
- [PostgreSQL Connection Strings](https://www.postgresql.org/docs/current/libpq-connect.html)
