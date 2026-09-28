---
name: internationalisation-checker
description: Finds hardcoded strings and migrates them to i18n JSON locale files
triggers:
  - /internationalisation-checker
  - /i18n
  - /localize
---

# Instructions

When this skill is invoked, scan for hardcoded user-facing strings and set up internationalization.

## Process

1. **Detect i18n Framework**:
   - React: react-i18next, react-intl
   - Vue: vue-i18n
   - Angular: @angular/localize, ngx-translate
   - Next.js: next-i18next
   - Generic: i18next, FormatJS

2. **Scan for Hardcoded Strings**:

   **Patterns to Find**:
   ```javascript
   // JSX text content
   <h1>Welcome to our app</h1>
   <button>Submit</button>
   <p>Your order has been placed</p>

   // String literals in UI code
   alert("Are you sure?")
   toast.success("Saved successfully!")
   placeholder="Enter your email"
   title="Settings"

   // Template literals with text
   `Hello, ${name}!`
   ```

   **Patterns to Ignore**:
   ```javascript
   // Technical strings
   console.log("Debug info")
   throw new Error("Internal error")
   className="button-primary"
   const API_URL = "https://api.example.com"
   ```

3. **Generate Locale Files**:

   **Structure**:
   ```
   locales/
   ├── en/
   │   ├── common.json
   │   ├── auth.json
   │   └── errors.json
   ├── es/
   │   ├── common.json
   │   ├── auth.json
   │   └── errors.json
   └── fr/
       └── ...
   ```

   **Locale File Format**:
   ```json
   {
     "common": {
       "welcome": "Welcome to our app",
       "submit": "Submit",
       "cancel": "Cancel",
       "save": "Save",
       "delete": "Delete"
     },
     "auth": {
       "login": "Log in",
       "logout": "Log out",
       "signUp": "Sign up",
       "forgotPassword": "Forgot password?",
       "emailPlaceholder": "Enter your email"
     },
     "messages": {
       "saveSuccess": "Saved successfully!",
       "deleteConfirm": "Are you sure you want to delete this?",
       "greeting": "Hello, {{name}}!"
     },
     "errors": {
       "required": "This field is required",
       "invalidEmail": "Please enter a valid email",
       "networkError": "Network error. Please try again."
     }
   }
   ```

4. **Generate Migration Code**:

   **Before**:
   ```tsx
   function WelcomePage({ user }) {
     return (
       <div>
         <h1>Welcome to our app</h1>
         <p>Hello, {user.name}!</p>
         <button>Get Started</button>
       </div>
     );
   }
   ```

   **After (react-i18next)**:
   ```tsx
   import { useTranslation } from 'react-i18next';

   function WelcomePage({ user }) {
     const { t } = useTranslation();

     return (
       <div>
         <h1>{t('common.welcome')}</h1>
         <p>{t('messages.greeting', { name: user.name })}</p>
         <button>{t('common.getStarted')}</button>
       </div>
     );
   }
   ```

5. **Set Up i18n Configuration**:

   ```typescript
   // src/i18n/config.ts
   import i18n from 'i18next';
   import { initReactI18next } from 'react-i18next';
   import Backend from 'i18next-http-backend';
   import LanguageDetector from 'i18next-browser-languagedetector';

   i18n
     .use(Backend)
     .use(LanguageDetector)
     .use(initReactI18next)
     .init({
       fallbackLng: 'en',
       supportedLngs: ['en', 'es', 'fr', 'de'],
       ns: ['common', 'auth', 'errors'],
       defaultNS: 'common',
       interpolation: {
         escapeValue: false,
       },
       backend: {
         loadPath: '/locales/{{lng}}/{{ns}}.json',
       },
     });

   export default i18n;
   ```

## Output Format

```markdown
## i18n Analysis Report

### Strings Found: 147

| Category | Count | Files |
|----------|-------|-------|
| UI Labels | 45 | 12 |
| Messages | 32 | 8 |
| Errors | 28 | 15 |
| Placeholders | 22 | 9 |
| Already i18n | 20 | 6 |

### Files Requiring Updates

| File | Hardcoded Strings |
|------|-------------------|
| src/pages/Home.tsx | 12 |
| src/components/Form.tsx | 8 |
| src/utils/messages.ts | 15 |

### Generated Files
- `locales/en/common.json` (45 keys)
- `locales/en/auth.json` (18 keys)
- `locales/en/errors.json` (28 keys)
- `src/i18n/config.ts`

### Migration Snippets
[Code transformations for each file]

### Next Steps
1. Review generated locale files
2. Apply code transformations
3. Add translations for other languages
4. Test with locale switching
```

## Enhancements

- Detect pluralization needs (1 item vs N items)
- Handle date/number formatting
- Generate translation memory (TMX) export
- Integrate with translation services (Crowdin, Lokalise)
- Check for RTL language support
- Validate interpolation variables match
- Generate missing translation reports
