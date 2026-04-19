# ⚡ Quick reCAPTCHA v3 Setup

## 🚨 Error: `invalid-keys`
Your Secret Key is invalid or doesn't exist in Google's system.

---

## 🔧 5-Minute Fix

### 1️⃣ Get Your Keys (2 min)

Visit: **https://www.google.com/recaptcha/admin**

**If you DON'T have a site yet:**
1. Click **➕** (Register new site)
2. Label: `My Blog`
3. Type: **Score based (v3)** ⚠️ Important!
4. Domains: `localhost`, `yourdomain.com`
5. Click **Submit**

**Copy both keys:**
```
Site Key:    6LeXXX... (40 chars)
Secret Key:  6LeYYY... (40 chars)
```

---

### 2️⃣ Configure Backend (1 min)

**Set environment variable:**
```bash
export RECAPTCHA_SECRET_KEY='YOUR_SECRET_KEY_HERE'
```

**OR edit `application.yml`:**
```yaml
recaptcha:
  secret-key: YOUR_SECRET_KEY_HERE
```

---

### 3️⃣ Configure Frontend (1 min)

**Edit `test-recaptcha.html`:**

Line 8:
```html
<script src="https://www.google.com/recaptcha/api.js?render=YOUR_SITE_KEY_HERE"></script>
```

Line 179:
```javascript
const SITE_KEY = 'YOUR_SITE_KEY_HERE';
```

---

### 4️⃣ Restart & Test (1 min)

```bash
# Restart backend
./gradlew bootRun

# Open browser
open test-recaptcha.html
```

---

## ✅ Verification

**Check backend logs:**
```bash
tail -f logs/be.log | grep recaptcha
```

**Expected success:**
```
✅ reCAPTCHA verification result: success=true, score=0.9
```

---

## ⚠️ Common Mistakes

1. ❌ Using **v2** keys instead of **v3**
2. ❌ Site Key and Secret Key from **different sites**
3. ❌ Forgetting to **restart backend** after changing keys
4. ❌ **Wrong key in wrong place** (Site Key in backend or vice versa)

---

## 🆘 Still Having Issues?

See full guide: **`RECAPTCHA_SETUP_GUIDE.md`**

Or check:
- Is `RECAPTCHA_SECRET_KEY` environment variable set? `echo $RECAPTCHA_SECRET_KEY`
- Are keys from the same reCAPTCHA site?
- Did you restart the backend?
- Check backend logs for detailed errors
