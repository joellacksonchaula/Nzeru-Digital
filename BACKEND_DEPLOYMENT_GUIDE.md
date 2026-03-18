# Backend Deployment & Troubleshooting Guide

## Issues Resolved

### 1. **Container Restart Loop**

**Root Cause:** The entrypoint.sh script had `set -e` which caused immediate failure if any command failed, particularly during superuser creation with the error "That username is already taken."

**Solution Implemented:**
- Changed error handling from `set -e` to `set -u` (only fail on undefined variables)
- Wrapped migration step with explicit error check
- Made superuser creation non-fatal (continues even if it fails)
- Improved static file collection to log warnings instead of failing
- Upgraded Gunicorn configuration:
  - Increased workers from 2 to 3
  - Added `--max-requests` and `--max-requests-jitter` for better memory management
  - Added proper error logging flags

**File Modified:** `backend/entrypoint.sh`

---

### 2. **Login/Register Failure Across Devices**

**Root Cause:** 
- CORS settings were too restrictive for mobile devices
- Missing credential support in CORS headers
- API service didn't have proper timeout/error handling

**Solutions Implemented:**

#### Backend Changes (`config/settings.py`):
```python
# Added CORS_ALLOW_CREDENTIALS to allow token-based auth
CORS_ALLOW_CREDENTIALS = True

# Extended CORS_ALLOWED_ORIGINS with localhost for testing
CORS_ALLOWED_ORIGINS = [
    "https://savingsutl-production.up.railway.app",
    "https://glittering-cobbler-1d32f6.netlify.app",
    "http://localhost:3000",  # Testing
    "http://localhost:8081",  # Flutter web dev
]

# Added missing headers for proxied requests
CORS_ALLOW_HEADERS = [
    # ... existing headers ...
    "x-forwarded-for",
    "x-forwarded-proto",
]
```

#### Frontend Changes (`lib/services/api_service.dart`):
- Added `.timeout(const Duration(seconds: 30))` to all requests
- Proper error handling for `SocketException` and `TimeoutException`
- Clearer error messages for network issues
- Added `Accept: application/json` header

**Why This Matters:**
- Mobile devices may have slower network, so 30s timeout prevents hanging
- Native error handling helps users understand connectivity issues
- CORS credentials flag allows session persistence across requests

---

### 3. **Superuser Creation Error: "That username is already taken"**

**Root Cause:** Script tried to create superuser repeatedly on each container restart without checking if it already exists.

**Solution Implemented:**
- Wrapped superuser creation in a try/except block
- Added explicit check: `if User.objects.filter(username=username).exists()`
- Made creation non-fatal so container starts even if it fails
- Generates email from username if not provided

**New Entrypoint Logic:**
```bash
if User.objects.filter(username=username).exists():
    print(f'INFO: Superuser "{username}" already exists. Skipping.')
else:
    User.objects.create_superuser(...)
```

---

### 4. **Unordered QuerySet Pagination Warnings**

**Root Cause:** Django REST Framework requires querysets to be ordered when using pagination.

**Solution Implemented:**
Added `.order_by()` to all ViewSet `get_queryset()` methods:

| ViewSet | Ordering |
|---------|----------|
| TransactionViewSet | `-timestamp` (newest first) |
| PenaltyViewSet | `-date` |
| LoanViewSet | `-created_at` |
| LoanPaymentViewSet | `-payment_date` |
| InterestDistributionViewSet | `-distributed_at` |
| NotificationViewSet | `-created_at` |
| SavingsPlanViewSet | `-created_at` |

**File Modified:** `backend/api/views.py`

---

## Deployment Checklist for Railway

### Environment Variables Required
```
DJANGO_SECRET_KEY=<strong-random-key>
DJANGO_DEBUG=False
DATABASE_URL=postgresql://user:pass@host/dbname
DJANGO_SUPERUSER_USERNAME=admin
DJANGO_SUPERUSER_EMAIL=admin@example.com
DJANGO_SUPERUSER_PASSWORD=<strong-password>
PORT=8000  # Railway sets this automatically
```

### Pre-Deployment Steps
1. **Generate SECRET_KEY** (never commit to repo):
   ```bash
   python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
   ```

2. **Run migrations locally**:
   ```bash
   python manage.py migrate
   ```

3. **Collect static files locally** (for verification):
   ```bash
   python manage.py collectstatic --noinput
   ```

4. **Test authentication**:
   ```bash
   # Register user
   curl -X POST https://savingsutl-production.up.railway.app/api/auth/register/ \
     -H "Content-Type: application/json" \
     -d '{
       "username": "testuser",
       "email": "test@example.com",
       "password": "TempPass123!",
       "password2": "TempPass123!"
     }'
   
   # Login
   curl -X POST https://savingsutl-production.up.railway.app/api/auth/login/ \
     -H "Content-Type: application/json" \
     -d '{
       "username": "testuser",
       "password": "TempPass123!"
     }'
   ```

### Post-Deployment Monitoring
1. **Check container logs** (in Railway dashboard):
   - Verify migrations run successfully
   - Confirm Gunicorn starts without errors
   - Look for CORS issues if web client fails

2. **Test endpoints**:
   - GET `/api/auth/me/` (requires auth token)
   - GET `/api/savings/` (should return paginated results, ordered by -created_at)
   - POST `/api/transactions/` (create test deposit)

3. **Monitor for restart loops**:
   - Railway dashboard → Deployments → watch Recent Builds
   - If container restarts repeatedly, check logs for Python exceptions

---

## Common Issues & Fixes

### Issue: 401 Unauthorized on Login
**Diagnosis:**
- Check if user exists: `python manage.py shell`
  ```python
  from django.contrib.auth.models import User
  User.objects.filter(username='testuser').exists()
  ```
- Verify password: `user.check_password('YourPassword')`

**Fix:**
- Re-create user: `User.objects.filter(username='testuser').delete()`
- Backend handles both email and username in login request

### Issue: CORS Error on Mobile/Web Client
**Symptoms:** Browser console shows "Access to XMLHttpRequest blocked by CORS policy"

**Fix:**
1. Ensure origin is in `CORS_ALLOWED_ORIGINS`
2. Set `CORS_ALLOW_CREDENTIALS = True`
3. Verify request includes proper headers (no `x-requested-with` typos)

### Issue: Gunicorn Worker Timeout
**Symptoms:** Requests take >120 seconds, container restarts

**Fix:**
- Check slow database queries in views
- Add `.only()` or `.values()` to reduce query load
- Increase `--timeout` in entrypoint.sh (current: 120s)

---

## Gunicorn Configuration Explanation

```bash
gunicorn config.wsgi:application \
    --bind "0.0.0.0:${PORT:-8000}"        # Listen on all interfaces
    --workers 3                             # 3 concurrent workers (CPU cores + 1)
    --worker-class sync                     # Synchronous worker (stable)
    --timeout 120                           # Kill hanging requests after 120s
    --max-requests 1000                     # Restart worker after 1000 requests
    --max-requests-jitter 100               # Randomize to avoid thundering herd
    --log-level info                        # Log at INFO level
    --access-logfile -                      # Log to stdout
    --error-logfile -                       # Log errors to stdout
    --enable-stdio-inheritance              # Proper signal handling
```

**Why These Settings:**
- **3 workers:** Railway small instance has ~0.5 CPU, but this allows request queueing
- **max-requests:** Prevents memory leaks from long-running workers
- **jitter:** Distributes restart timing to avoid all workers restarting simultaneously
- **stdio-inheritance:** Allows Railway to gracefully shut down Gunicorn on SIGTERM

---

## Next Steps

1. **Deploy updated `entrypoint.sh` to Railway**
2. **Set all required environment variables in Railway Dashboard**
3. **Monitor container logs for 5-10 minutes** after deployment
4. **Test login from a different device/network** to verify cross-device auth works
5. **Monitor database size** - may grow rapidly if transactions are created frequently

---

## Additional Resources

- [Django Deployment Checklist](https://docs.djangoproject.com/en/stable/howto/deployment/checklist/)
- [Django REST Framework Pagination](https://www.django-rest-framework.org/api-guide/pagination/)
- [Gunicorn Docs](https://docs.gunicorn.org/)
- [Railway PostgreSQL Setup](https://docs.railway.app/databases/postgresql)
