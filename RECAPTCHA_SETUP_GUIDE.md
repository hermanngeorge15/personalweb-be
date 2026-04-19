# Google reCAPTCHA v3 Setup Guide

## 🚨 Current Issue
You're getting `errorCodes=[invalid-keys]` because your reCAPTCHA keys are either invalid or don't match.

---

## 📋 Complete Setup Instructions

### Step 1: Access Google reCAPTCHA Admin Console

1. Open your browser and go to: **https://www.google.com/recaptcha/admin**
2. Sign in with your Google account
3. You'll see a dashboard with existing reCAPTCHA sites (if any)

---

### Step 2: Register a New reCAPTCHA v3 Site

1. Click the **➕ (plus icon)** button to register a new site
2. Fill in the registration form:

   **Label:**
   ```
   My Blog Contact Form
   ```
   (or any name you prefer)

   **reCAPTCHA type:**
   - ✅ Select **"Score based (v3)"** 
   - ❌ Do NOT select v2 (checkbox) or Enterprise

   **Domains:**
   Add the following domains (one per line):
   ```
   localhost
   127.0.0.1
   yourdomain.com
   ```
   Replace `yourdomain.com` with your actual production domain

   **Accept reCAPTCHA Terms of Service:**
   - ✅ Check this box

3. Click **Submit**

---

### Step 3: Copy Your Keys

After registration, you'll see a page with your keys:

```
Site Key:    6LeXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Secret Key:  6LeYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
```

**⚠️ CRITICAL:** Both keys MUST come from the **SAME reCAPTCHA site**!

- **Site Key** = Used in frontend (HTML/JavaScript)
- **Secret Key** = Used in backend (Spring Boot)

📝 **Copy both keys** - you'll need them in the next steps.

---

### Step 4: Configure Backend (Secret Key)

#### Option A: Using Environment Variable (Recommended)

Set the environment variable:

```bash
export RECAPTCHA_SECRET_KEY='YOUR_SECRET_KEY_HERE'
```

To make it persistent, add it to your `~/.zshrc` or `~/.bash_profile`:

```bash
echo "export RECAPTCHA_SECRET_KEY='YOUR_SECRET_KEY_HERE'" >> ~/.zshrc
source ~/.zshrc
```

#### Option B: Update application.yml (Development Only)

⚠️ **Warning:** Don't commit real keys to Git!

Edit `src/main/resources/application.yml`:

```yaml
recaptcha:
  enabled: ${RECAPTCHA_ENABLED:true}
  secret-key: ${RECAPTCHA_SECRET_KEY:YOUR_SECRET_KEY_HERE}  # Replace this
  verify-url: https://www.google.com/recaptcha/api/siteverify
  minimum-score: ${RECAPTCHA_MINIMUM_SCORE:0.5}
```

**Replace `YOUR_SECRET_KEY_HERE`** with your actual Secret Key from Step 3.

---

### Step 5: Configure Frontend (Site Key)

Edit `test-recaptcha.html` (or your actual frontend):

**1. Update the script tag (around line 8):**

```html
<script src="https://www.google.com/recaptcha/api.js?render=YOUR_SITE_KEY_HERE"></script>
```

Replace `YOUR_SITE_KEY_HERE` with your actual Site Key.

**2. Update the JavaScript constant (around line 179):**

```javascript
const SITE_KEY = 'YOUR_SITE_KEY_HERE';  // Replace with your Site Key
```

---

### Step 6: Restart Your Backend

```bash
./gradlew bootRun
```

---

### Step 7: Test Your Implementation

1. Open `test-recaptcha.html` in your browser
2. Fill out the form
3. Click "Submit with reCAPTCHA"
4. Check the response

**Expected Success Response:**
```
✅ reCAPTCHA verification result: success=true, score=0.9, action=submit
```

**Check Backend Logs:**
```bash
tail -f logs/be.log | grep -i recaptcha
```

---

## 🔍 Troubleshooting

### Error: `invalid-keys`

**Cause:** Secret Key is invalid or doesn't exist

**Solution:**
1. Go back to https://www.google.com/recaptcha/admin
2. Verify you copied the correct **Secret Key**
3. Make sure it's from a **v3** site (not v2)
4. Update your backend configuration
5. Restart the backend

---

### Error: `missing-input-secret`

**Cause:** Secret Key is not configured in backend

**Solution:**
1. Check that `RECAPTCHA_SECRET_KEY` environment variable is set
2. Or verify `application.yml` has the correct key
3. Restart the backend

---

### Error: `invalid-input-response`

**Cause:** The token sent from frontend is invalid

**Solution:**
1. Verify **Site Key** in frontend matches the one from Google Admin
2. Make sure Site Key and Secret Key are from the **SAME reCAPTCHA site**
3. Check browser console for JavaScript errors
4. Token might have expired (valid for 2 minutes) - try again

---

### Error: Low reCAPTCHA Score (< 0.5)

**Cause:** Google detected suspicious activity

**Solution:**
1. This is normal during testing with localhost
2. You can lower `minimum-score` in `application.yml`:
   ```yaml
   recaptcha:
     minimum-score: 0.3  # Lower threshold for development
   ```
3. In production, keep it at 0.5 or higher

---

## 📊 Key Matching Checklist

Use this checklist to verify your setup:

- [ ] I have a reCAPTCHA **v3** site (Score based)
- [ ] I copied the **Site Key** from Google Admin
- [ ] I copied the **Secret Key** from Google Admin
- [ ] **BOTH keys are from the SAME site** in Google Admin
- [ ] I updated `test-recaptcha.html` with the Site Key (2 places)
- [ ] I set `RECAPTCHA_SECRET_KEY` environment variable OR updated `application.yml`
- [ ] I restarted the backend server
- [ ] My domain (or localhost) is added to the reCAPTCHA site settings

---

## 🔐 Security Best Practices

1. **Never commit Secret Key to Git**
   - Use environment variables
   - Add `.env` to `.gitignore`

2. **Restrict domains in Google Admin**
   - Only add domains you control
   - Keep localhost for development only

3. **Monitor your reCAPTCHA usage**
   - Google provides analytics in the Admin Console
   - Set up alerts for unusual activity

4. **Use appropriate score thresholds**
   - Development: 0.3
   - Production: 0.5 - 0.7
   - High security: 0.7+

---

## 📚 Additional Resources

- [Google reCAPTCHA v3 Documentation](https://developers.google.com/recaptcha/docs/v3)
- [reCAPTCHA Admin Console](https://www.google.com/recaptcha/admin)
- [Score Interpretation Guide](https://developers.google.com/recaptcha/docs/v3#interpreting_the_score)

---

## ✅ Quick Verification Commands

**Check if environment variable is set:**
```bash
echo $RECAPTCHA_SECRET_KEY
```

**Test backend endpoint:**
```bash
curl -X POST http://localhost:8891/api/contact \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test",
    "email": "test@example.com",
    "message": "Test message",
    "recaptchaToken": "YOUR_TOKEN_HERE"
  }'
```

**View backend logs:**
```bash
tail -f logs/be.log | grep -i recaptcha
```

---

## 🎯 Summary

Your `invalid-keys` error means your Secret Key is not valid. Follow these steps:

1. ✅ Go to https://www.google.com/recaptcha/admin
2. ✅ Register a new v3 site (or find existing one)
3. ✅ Copy BOTH Site Key AND Secret Key from the SAME site
4. ✅ Update frontend with Site Key
5. ✅ Update backend with Secret Key (via environment variable)
6. ✅ Restart backend
7. ✅ Test with `test-recaptcha.html`

**Need Help?** Check the troubleshooting section above or review the backend logs for detailed error messages.
