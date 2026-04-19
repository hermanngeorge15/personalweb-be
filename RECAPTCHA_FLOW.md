# reCAPTCHA v3 Flow Diagram

## 🔐 Key Usage Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                  Google reCAPTCHA Admin Console                  │
│              https://www.google.com/recaptcha/admin              │
│                                                                   │
│  Your reCAPTCHA v3 Site: "My Blog"                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Site Key:    6LeXXXXXXXXXXXXXXXXXXXXXXXXXX  [COPY 📋]   │  │
│  │  Secret Key:  6LeYYYYYYYYYYYYYYYYYYYYYYYYYY  [COPY 📋]   │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                      │                    │
                      │                    │
          ┌───────────┘                    └─────────────┐
          │ Site Key                         Secret Key   │
          │ (PUBLIC)                         (PRIVATE)    │
          ▼                                              ▼
┌──────────────────────┐                    ┌──────────────────────┐
│      FRONTEND        │                    │       BACKEND        │
│  test-recaptcha.html │                    │  application.yml     │
│                      │                    │                      │
│  Line 8:             │                    │  Line 68:            │
│  <script src="...    │                    │  recaptcha:          │
│   render=SITE_KEY">  │                    │    secret-key:       │
│                      │                    │      SECRET_KEY      │
│  Line 179:           │                    │                      │
│  const SITE_KEY =    │                    │  OR Environment Var: │
│    'YOUR_SITE_KEY'   │                    │  RECAPTCHA_SECRET_   │
│                      │                    │  KEY='SECRET_KEY'    │
└──────────────────────┘                    └──────────────────────┘
```

---

## 🔄 Complete Verification Flow

```
1. USER opens webpage
   │
   ├─> Browser loads reCAPTCHA script with SITE_KEY
   │   https://www.google.com/recaptcha/api.js?render=SITE_KEY
   │
   └─> reCAPTCHA script initializes
       └─> ✅ Google validates SITE_KEY

2. USER fills form and clicks Submit
   │
   ├─> JavaScript calls: grecaptcha.execute(SITE_KEY, {action: 'submit'})
   │
   ├─> Google generates TOKEN (valid for 2 minutes)
   │   Token = encrypted data containing:
   │   - Timestamp
   │   - Browser fingerprint
   │   - User behavior score
   │
   └─> TOKEN returned to JavaScript

3. Frontend sends data to Backend
   │
   POST /api/contact
   ├─> name: "John Doe"
   ├─> email: "john@example.com"
   ├─> message: "Hello"
   └─> recaptchaToken: "TOKEN_FROM_STEP_2"

4. Backend verifies with Google
   │
   POST https://www.google.com/recaptcha/api/siteverify
   ├─> secret: SECRET_KEY      ← Must match SITE_KEY's pair
   ├─> response: TOKEN
   └─> remoteip: 127.0.0.1

5. Google responds
   │
   ├─> success: true/false
   ├─> score: 0.0 - 1.0 (higher = more human-like)
   ├─> action: "submit"
   ├─> challenge_ts: "2024-10-14T10:10:00Z"
   ├─> hostname: "localhost"
   └─> error-codes: [] or ["invalid-keys", ...]

6. Backend validates
   │
   ├─> Check: response.success == true?
   ├─> Check: response.score >= 0.5?
   │
   ├─> ✅ PASS → Process contact form
   └─> ❌ FAIL → Return 400 error
```

---

## ❌ Your Current Error

```
RecaptchaVerifyResponse(
  success=false,
  score=null,
  action=null,
  challengeTs=null,
  hostname=null,
  errorCodes=[invalid-keys]  ← This is the problem!
)
```

**What `invalid-keys` means:**

```
┌─────────────────────────────────────────────────────────────┐
│  Google received:                                            │
│  - secret: 6Lf13OgrAAAAALxyuRJWZFhYhuPVv7u2581zXIBp        │
│  - response: (token from frontend)                          │
│                                                              │
│  Google checked its database:                               │
│  ❌ "6Lf13OgrAAAAALxyuRJWZFhYhuPVv7u2581zXIBp" not found! │
│                                                              │
│  Result: invalid-keys                                       │
└─────────────────────────────────────────────────────────────┘
```

**Possible causes:**

1. **Secret Key doesn't exist** in Google's system
2. **Secret Key is from v2**, not v3
3. **Typo** in the Secret Key
4. **Wrong account** - logged into different Google account

---

## ✅ How Keys Should Match

```
Google reCAPTCHA Site: "My Blog"
├─> Site Key:    6LeABC...123
└─> Secret Key:  6LeXYZ...789
         │              │
         │              │
         ▼              ▼
    FRONTEND       BACKEND
    (Public)       (Private)
         │              │
         └──────┬───────┘
                │
                ▼
         MUST BE FROM
          SAME SITE!
```

**Example of WRONG setup:**

```
❌ Site Key from "Blog A" → Frontend
❌ Secret Key from "Blog B" → Backend

Result: invalid-input-response or invalid-keys
```

**Example of CORRECT setup:**

```
✅ Site Key from "My Blog" → Frontend
✅ Secret Key from "My Blog" → Backend

Result: success=true, score=0.9
```

---

## 🎯 Checklist for Fix

Step-by-step verification:

1. **Go to Google Admin Console**
   ```
   https://www.google.com/recaptcha/admin
   └─> Are you logged in with the correct Google account?
   ```

2. **Find or Create v3 Site**
   ```
   ├─> If no site exists: Click ➕ and create new
   └─> If site exists: Click on it to view keys
   ```

3. **Verify it's v3**
   ```
   reCAPTCHA type: Score based (v3)
   ├─> ✅ Correct
   └─> ❌ If it says "v2" or "Challenge", create new v3 site
   ```

4. **Copy BOTH keys from SAME site**
   ```
   Site Key:    6LeXXX...  [📋 Copy]
   Secret Key:  6LeYYY...  [📋 Copy]
   ```

5. **Update Frontend**
   ```
   test-recaptcha.html
   ├─> Line 8: <script src="...render=SITE_KEY">
   └─> Line 179: const SITE_KEY = 'SITE_KEY'
   ```

6. **Update Backend**
   ```
   Option A: export RECAPTCHA_SECRET_KEY='SECRET_KEY'
   Option B: Edit application.yml → secret-key: SECRET_KEY
   ```

7. **Restart Backend**
   ```
   ./gradlew bootRun
   ```

8. **Test**
   ```
   Open test-recaptcha.html
   └─> Expected: success=true, score=0.x
   ```

---

## 📊 Expected Success Response

When everything is configured correctly:

```json
{
  "success": true,
  "score": 0.9,
  "action": "submit",
  "challenge_ts": "2024-10-14T10:10:00Z",
  "hostname": "localhost",
  "error-codes": []
}
```

**Backend log:**
```
INFO  reCAPTCHA verification result: success=true, score=0.9, action=submit
```

---

## 🔍 Debug Commands

**Check environment variable:**
```bash
echo $RECAPTCHA_SECRET_KEY
# Should output: 6LeYYY...
```

**Check backend is using correct key:**
```bash
# Look in logs when backend starts
grep -i "recaptcha" logs/be.log
```

**Test with curl:**
```bash
# This will show you the exact error
curl -X POST "https://www.google.com/recaptcha/api/siteverify" \
  -d "secret=YOUR_SECRET_KEY" \
  -d "response=test_token"
```

---

## 📚 References

- Full Setup Guide: `RECAPTCHA_SETUP_GUIDE.md`
- Quick Setup: `QUICK_RECAPTCHA_SETUP.md`
- Google Docs: https://developers.google.com/recaptcha/docs/v3
