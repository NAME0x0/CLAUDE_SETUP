---
name: secrets-guardian
description: Scans for hardcoded secrets and sets up pre-commit prevention
triggers:
  - /secrets-guardian
  - /secrets
  - /scan-secrets
---

# Instructions

When this skill is invoked, scan the codebase for exposed secrets and set up prevention mechanisms.

## Process

1. **Scan for Secret Patterns**:

   **High-Confidence Patterns**:
   ```regex
   # AWS
   AKIA[0-9A-Z]{16}                    # AWS Access Key ID
   [A-Za-z0-9/+=]{40}                  # AWS Secret Access Key (context needed)

   # API Keys
   sk-[a-zA-Z0-9]{48}                  # OpenAI API Key
   sk_live_[a-zA-Z0-9]{24,}            # Stripe Live Key
   sk_test_[a-zA-Z0-9]{24,}            # Stripe Test Key
   ghp_[a-zA-Z0-9]{36}                 # GitHub Personal Access Token
   github_pat_[a-zA-Z0-9]{22,}         # GitHub PAT (new format)

   # Private Keys
   -----BEGIN (RSA|DSA|EC|OPENSSH) PRIVATE KEY-----
   -----BEGIN PGP PRIVATE KEY BLOCK-----

   # Database URLs
   postgres://[^:]+:[^@]+@             # PostgreSQL with password
   mongodb(\+srv)?://[^:]+:[^@]+@      # MongoDB with password
   mysql://[^:]+:[^@]+@                # MySQL with password

   # Generic Secrets
   password\s*[=:]\s*['"][^'"]+['"]    # Hardcoded passwords
   secret\s*[=:]\s*['"][^'"]+['"]      # Hardcoded secrets
   api[_-]?key\s*[=:]\s*['"][^'"]+['"] # API keys
   ```

2. **Scan Git History**:
   ```bash
   # Check current files
   git secrets --scan

   # Check entire history
   git log -p --all | grep -E "(AKIA|sk_live|password\s*=)"
   ```

3. **Generate Report**:

   ```markdown
   ## Secret Scan Results

   ### 🔴 Critical Findings

   | Type | File | Line | Value (redacted) |
   |------|------|------|------------------|
   | AWS Key | .env | 5 | AKIA***XXXX |
   | Stripe Key | config.ts | 12 | sk_live_***XXX |
   | DB Password | docker-compose.yml | 23 | p****** |

   ### ⚠️ Potential Issues
   | Type | File | Line | Context |
   |------|------|------|---------|
   | Generic Secret | auth.ts | 45 | `const secret = "..."` |
   ```

4. **Set Up Prevention**:

   **Install git-secrets**:
   ```bash
   # macOS
   brew install git-secrets

   # Configure for AWS
   git secrets --register-aws
   git secrets --install
   ```

   **Pre-commit Hook (.pre-commit-config.yaml)**:
   ```yaml
   repos:
     - repo: https://github.com/Yelp/detect-secrets
       rev: v1.4.0
       hooks:
         - id: detect-secrets
           args: ['--baseline', '.secrets.baseline']

     - repo: https://github.com/awslabs/git-secrets
       rev: master
       hooks:
         - id: git-secrets

     - repo: https://github.com/gitleaks/gitleaks
       rev: v8.18.0
       hooks:
         - id: gitleaks
   ```

   **Gitleaks Config (.gitleaks.toml)**:
   ```toml
   [extend]
   useDefault = true

   [[rules]]
   id = "custom-api-key"
   description = "Custom API Key"
   regex = '''(?i)my_company_api_key\s*[=:]\s*['"]?[\w-]+['"]?'''
   tags = ["key", "api"]

   [allowlist]
   paths = [
     '''\.secrets\.baseline''',
     '''package-lock\.json''',
     '''yarn\.lock''',
   ]
   ```

5. **Generate .gitignore Updates**:
   ```gitignore
   # Secrets
   .env
   .env.*
   !.env.example
   *.pem
   *.key
   *_rsa
   *_dsa
   *_ed25519
   *_ecdsa
   credentials.json
   service-account*.json
   ```

6. **Remediation Steps**:

   For each found secret:
   - Rotate/invalidate the exposed credential
   - Remove from git history if committed
   - Move to secure storage (env vars, secrets manager)
   - Add to .gitignore

## Output Format

```markdown
## Secrets Guardian Report

### Scan Summary
- **Files Scanned**: 234
- **Secrets Found**: 5
- **Git History Issues**: 2

### Critical Actions Required

1. **Rotate AWS Key** (AKIA***XXXX)
   - Found in: `.env:5`
   - Action: Revoke in AWS Console, generate new key
   - Store in: AWS Secrets Manager or env var

2. **Rotate Stripe Key** (sk_live_***XXX)
   - Found in: `config.ts:12` AND git history
   - Action: Roll key in Stripe Dashboard
   - Run: `git filter-branch` to remove from history

### Prevention Setup

Files created:
- `.pre-commit-config.yaml`
- `.gitleaks.toml`
- `.secrets.baseline`

Run:
```bash
pre-commit install
pre-commit run --all-files
```

### Git History Cleanup

```bash
# Remove file from history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch .env" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (coordinate with team!)
git push origin --force --all
```
```

## Enhancements

- Integrate with vault/secrets managers (HashiCorp Vault, AWS SSM)
- Generate secret rotation scripts
- Set up CI/CD secret scanning
- Create security incident report template
- Monitor for leaked credentials (GitHub secret scanning)
- Generate SOC 2 compliance evidence
- Encrypt secrets at rest with SOPS/age
