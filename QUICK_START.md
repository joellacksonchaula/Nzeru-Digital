# Quick Start Deployment Guide

## TL;DR - Deploy in 5 Steps

### Step 1: Update Backend Environment Variables (2 min)
In Railway Dashboard → Variables:
```
DJANGO_SECRET_KEY=<generate-new>
DJANGO_SUPERUSER_USERNAME=admin
DJANGO_SUPERUSER_EMAIL=admin@example.com
DJANGO_SUPERUSER_PASSWORD=<strong-password>
```

### Step 2: Deploy Backend (5 min)
```bash
cd backend
git add entrypoint.sh config/settings.py api/views.py
git commit -m "fix: container restarts, CORS, pagination"
git push origin main
# Wait for Railway to deploy (check dashboard)
```

### Step 3: Test Backend (2 min)
```bash
# Test login
curl -X POST https://savingsutl-production.up.railway.app/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"YourPassword"}'
```

### Step 4: Build & Deploy Frontend (5 min)
```bash
flutter clean
flutter pub get
flutter build web --release
netlify deploy --prod --dir=build/web
```

### Step 5: Update CORS & Test (2 min)
Add your Netlify URL to Railway environment:
```
CORS_ALLOWED_ORIGINS=...your-netlify-url...
```
Test dashboard on https://your-netlify-url/dashboard

---

## What Was Fixed

| Issue | Fix | File |
|-------|-----|------|
| Container restarts | Non-fatal superuser creation | `entrypoint.sh` |
| Cross-device login fails | CORS credentials support | `config/settings.py` |
| Mobile timeout errors | 30s request timeout | `api_service.dart` |
| Pagination warnings | Added .order_by() | `views.py` |
| No crypto dashboard | New DashboardScreenV2 | `dashboard_screen_v2.dart` |

---

## What's New

✅ **Candlestick Charts** - TradingView style with OHLC data
✅ **MK Currency Formatting** - "MK 1,250,000.00" format
✅ **Crypto UI Theme** - White/Black/Red/Gold color scheme
✅ **Better Error Handling** - Network timeouts, proper messages
✅ **Stable Deployment** - No container restart loops

---

## File Summary

### Modified (3 files)
1. `backend/entrypoint.sh` - Fixed startup issues
2. `backend/config/settings.py` - CORS configuration
3. `backend/api/views.py` - Added query ordering

### New (4 files)
1. `lib/widgets/candlestick_chart.dart` - Chart widget
2. `lib/utils/currency_formatter.dart` - MK formatting
3. `lib/screens/home/dashboard_screen_v2.dart` - New dashboard
4. (Updated route in `app_routes.dart`)

### Documentation (3 files)
1. `BACKEND_DEPLOYMENT_GUIDE.md`
2. `FRONTEND_DASHBOARD_GUIDE.md`
3. `DEPLOYMENT_IMPLEMENTATION_GUIDE.md`

---

## Test the Changes

### After Backend Deploy
```bash
# Should work now (no 401 errors)
curl -X POST https://your-backend/api/auth/login/ \
  -d '{"username":"testuser","password":"pass"}'
```

### After Frontend Deploy
```
Dashboard should show:
✓ Total Savings: MK 1,250,000.00 (with commas)
✓ Candlestick chart with 7-day deposit data
✓ Gold accent color (#D4AF37)
✓ Black text on white background
✓ Red negative values, green positive values
```

---

## Environment Variables Needed

### Railway (Backend)
```
DJANGO_DEBUG=False
DJANGO_SECRET_KEY=<generate>
DJANGO_SUPERUSER_USERNAME=admin
DJANGO_SUPERUSER_EMAIL=admin@example.com
DJANGO_SUPERUSER_PASSWORD=<strong>
DATABASE_URL=<auto>
PORT=8000
CORS_ALLOWED_ORIGINS=https://your-netlify-url
```

### Netlify (Frontend)
```
No special config needed
Just deploy the Flutter web build
```

---

## Common Errors & Quick Fixes

| Error | Fix |
|-------|-----|
| "Container restarting" | Already fixed in entrypoint.sh |
| "CORS blocked" | Add your URL to CORS_ALLOWED_ORIGINS |
| "401 Unauthorized" | Use email OR username for login |
| "Request timeout" | Already fixed with 30s timeout |
| "MK currency not showing" | Use CurrencyFormatter.formatMK() |

---

## Support Files

👉 **For detailed backend info:** See `BACKEND_DEPLOYMENT_GUIDE.md`
👉 **For dashboard component details:** See `FRONTEND_DASHBOARD_GUIDE.md`
👉 **For complete deployment steps:** See `DEPLOYMENT_IMPLEMENTATION_GUIDE.md`

---

## Success Checklist

- [ ] Backend deployed to Railway
- [ ] No container restart loops
- [ ] Frontend built without errors
- [ ] Dashboard displays with MK currency
- [ ] Candlestick chart renders
- [ ] Can login on different device
- [ ] CORS errors resolved
- [ ] Ready for production!

---

## One-Liner Deployment

```bash
# Backend
cd backend && git add -A && git commit -m "fix: all issues" && git push origin main

# Frontend (after build)
flutter build web --release && netlify deploy --prod --dir=build/web
```

---

**Estimated Total Time:** 15-20 minutes
**Difficulty:** Medium
**Risk:** Low (with rollback plan)

🚀 **You've got this!**
