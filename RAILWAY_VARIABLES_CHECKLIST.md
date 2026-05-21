# Railway Environment Variables - Quick Reference

## Instructions
1. Go to: Railway Dashboard → Your Project → Variables
2. Copy each variable name and value below
3. Click "Add Variable" for each one
4. Click "Deploy" after adding all variables

---

## REQUIRED Variables (Copy These First)

### 1. DJANGO_SECRET_KEY
**Value:** Generate using this command:
```
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```
Copy the output and paste it here.

### 2. DJANGO_DEBUG
**Value:** `False`

### 3. DATABASE_URL
**Value:** Copy from Railway dashboard (auto-generated when you add PostgreSQL)
Format: `postgresql://user:password@host:5432/dbname`

### 4. PORT
**Value:** `8000`

---

## SUPERUSER Configuration (Required)

### 5. DJANGO_SUPERUSER_USERNAME
**Value:** `admin` (or your preferred admin username)

### 6. DJANGO_SUPERUSER_EMAIL
**Value:** `admin@yourdomain.com` (replace with your domain)

### 7. DJANGO_SUPERUSER_PASSWORD
**Value:** Use a strong password (generate with: `python -c "import secrets; print(secrets.token_urlsafe(32))"`)

---

## Django Settings (Required)

### 8. ALLOWED_HOSTS
**Value:** `savingsutl-production.up.railway.app,.railway.app,localhost,127.0.0.1`

---

## CORS & Trusted Origins (Required)

### 9. EXTRA_CORS_ALLOWED_ORIGINS
**Value:** `https://glittering-cobbler-1d32f6.netlify.app,https://yourdomain.com,https://app.yourdomain.com`

Replace `yourdomain.com` with your actual domain (can be empty if only using Netlify frontend)

### 10. EXTRA_CSRF_TRUSTED_ORIGINS
**Value:** `https://glittering-cobbler-1d32f6.netlify.app,https://yourdomain.com,https://app.yourdomain.com`

Same as EXTRA_CORS_ALLOWED_ORIGINS

---

## OPTIONAL Variables (Add If Needed)

### 11. TZ (Timezone)
**Value:** `UTC` (or your timezone: `Africa/Lusaka`, `America/New_York`, etc.)

### 12. DJANGO_LOG_LEVEL
**Value:** `INFO` (or `DEBUG` for more verbose logging)

### 13. ADMIN_URL (Security)
**Value:** `admin_custom_path` (customize the admin panel URL instead of `/admin/`)

---

## Copy-Paste Checklist

When setting up in Railway Dashboard, ensure you have:

```markdown
- [ ] DJANGO_SECRET_KEY = [generated value]
- [ ] DJANGO_DEBUG = False
- [ ] DATABASE_URL = [from Railway]
- [ ] PORT = 8000
- [ ] DJANGO_SUPERUSER_USERNAME = admin
- [ ] DJANGO_SUPERUSER_EMAIL = admin@yourdomain.com
- [ ] DJANGO_SUPERUSER_PASSWORD = [strong password]
- [ ] ALLOWED_HOSTS = savingsutl-production.up.railway.app,.railway.app,localhost,127.0.0.1
- [ ] EXTRA_CORS_ALLOWED_ORIGINS = [your frontend URLs]
- [ ] EXTRA_CSRF_TRUSTED_ORIGINS = [your frontend URLs]
- [ ] (Optional) TZ = UTC
- [ ] (Optional) DJANGO_LOG_LEVEL = INFO
```

---

## Important Notes

1. **Never commit `.env` files**: These contain sensitive values
2. **Regenerate SECRET_KEY**: Each deployment environment should have a unique SECRET_KEY
3. **Strong Passwords**: Use random, strong passwords for DJANGO_SUPERUSER_PASSWORD
4. **Update Domains**: Replace all `yourdomain.com` references with your actual domain
5. **Railway Auto-Sets**: When you add PostgreSQL to Railway, it automatically sets DATABASE_URL
6. **No Quotes**: Do not use quotes around values in Railway dashboard

---

## After Deployment

1. Open Railway Dashboard → Deployments → Latest
2. Check logs for:
   ```
   ==> Running migrations...
   ==> Creating superuser (if not exists)...
   ==> Collecting static files...
   ==> Starting Gunicorn on port 8000...
   ```
3. Test health check: `curl https://your-railway-url.up.railway.app/api/health/`
4. Login with superuser credentials via dashboard

---

## Getting Your Railway URL

After first deployment:
1. Go to Railway Dashboard → Your Project
2. Look at the service/deployment card
3. Your URL will be shown as: `https://[name]-[id].up.railway.app`
4. Use this in frontend app configuration

---

## Local Development Still Works

All local development setup remains unchanged:
- `.env` file for local development
- `python manage.py runserver`
- SQLite database by default
- All original requirements.txt unchanged

See `RAILWAY_DEPLOYMENT_GUIDE.md` for full local setup instructions.
