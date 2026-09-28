---
name: environment-manager
description: Audits environment variable usage and syncs .env templates across environments
triggers:
  - /environment-manager
  - /env
  - /dotenv
---

# Instructions

When this skill is invoked, analyze environment variable usage and ensure consistent configuration management.

## Process

1. **Scan for Environment Variables**:
   - Use Grep to find `process.env`, `os.environ`, `os.Getenv`, `env::var`
   - Check for dotenv/config loading patterns
   - Identify framework-specific env access (Vite's `import.meta.env`, etc.)

2. **Catalog All Variables**:

   For each variable found, document:
   - Variable name
   - Where it's used (file:line)
   - Whether it has a default value
   - If it's required or optional
   - Apparent purpose/category

3. **Analyze Existing .env Files**:
   ```
   .env                 # Local defaults (gitignored)
   .env.example         # Template (committed)
   .env.local           # Local overrides
   .env.development     # Dev environment
   .env.production      # Production environment
   .env.test            # Test environment
   ```

4. **Generate/Update .env.example**:

   ```bash
   # ===========================================
   # Application Configuration
   # ===========================================

   # Server
   PORT=3000
   HOST=localhost
   NODE_ENV=development

   # ===========================================
   # Database
   # ===========================================

   # PostgreSQL connection
   DATABASE_URL=postgresql://user:password@localhost:5432/dbname
   DATABASE_POOL_SIZE=10

   # ===========================================
   # Authentication
   # ===========================================

   # JWT Configuration
   JWT_SECRET=your-secret-key-change-in-production
   JWT_EXPIRES_IN=7d

   # OAuth (optional)
   # GOOGLE_CLIENT_ID=
   # GOOGLE_CLIENT_SECRET=

   # ===========================================
   # External Services
   # ===========================================

   # AWS (required for file uploads)
   AWS_ACCESS_KEY_ID=
   AWS_SECRET_ACCESS_KEY=
   AWS_REGION=us-east-1
   AWS_S3_BUCKET=

   # ===========================================
   # Feature Flags
   # ===========================================

   ENABLE_DEBUG_MODE=false
   ENABLE_METRICS=true
   ```

5. **Detect Issues**:
   - Variables used but not in .env.example
   - Variables in .env.example but never used
   - Secrets potentially committed to git
   - Missing required variables
   - Inconsistent naming conventions

6. **Generate Validation Schema**:

   **TypeScript (zod)**:
   ```typescript
   import { z } from 'zod';

   const envSchema = z.object({
     NODE_ENV: z.enum(['development', 'production', 'test']),
     PORT: z.string().transform(Number).default('3000'),
     DATABASE_URL: z.string().url(),
     JWT_SECRET: z.string().min(32),
     AWS_ACCESS_KEY_ID: z.string().optional(),
   });

   export const env = envSchema.parse(process.env);
   ```

   **Python (pydantic)**:
   ```python
   from pydantic_settings import BaseSettings

   class Settings(BaseSettings):
       node_env: str = "development"
       port: int = 3000
       database_url: str
       jwt_secret: str

       class Config:
           env_file = ".env"
   ```

## Output Format

```markdown
## Environment Audit Report

### Variables Found: 24

| Variable | Files | Required | In .env.example |
|----------|-------|----------|-----------------|
| DATABASE_URL | 3 | Yes | ✅ |
| JWT_SECRET | 2 | Yes | ✅ |
| STRIPE_KEY | 1 | Yes | ❌ Missing |
| DEBUG_MODE | 1 | No | ✅ |

### Issues

#### ❌ Missing from .env.example
- `STRIPE_KEY` (used in src/payments/stripe.ts:12)
- `REDIS_URL` (used in src/cache/redis.ts:8)

#### ⚠️ Unused in .env.example
- `OLD_API_KEY` (not found in any source files)

#### 🔴 Potential Secret Exposure
- `.env` file found in git history (commit abc123)

### Generated Files
- `.env.example` - Updated template
- `src/config/env.ts` - Type-safe validation

### Recommendations
1. Add missing variables to .env.example
2. Remove unused variables
3. Run `git filter-branch` to remove .env from history
```

## Enhancements

- Generate Docker environment configuration
- Create CI/CD secret requirements list
- Sync with cloud secret managers (AWS SSM, Vault)
- Validate URLs, ports, and other typed values
- Generate documentation for each variable
- Check for environment-specific overrides
- Detect hardcoded values that should be env vars
