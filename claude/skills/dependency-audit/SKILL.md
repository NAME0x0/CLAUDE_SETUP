---
name: dependency-audit
description: Scans dependencies for CVEs, outdated packages, and suggests secure upgrades
triggers:
  - /dependency-audit
  - /audit
  - /security-scan
---

# Instructions

When this skill is invoked, perform a comprehensive security and health audit of project dependencies.

## Process

1. **Identify Package Manager**:
   - npm/yarn/pnpm: package.json, package-lock.json
   - pip: requirements.txt, Pipfile, pyproject.toml
   - Go: go.mod, go.sum
   - Cargo: Cargo.toml, Cargo.lock
   - Composer: composer.json

2. **Run Native Audit Tools**:
   ```bash
   # Node.js
   npm audit --json
   yarn audit --json
   pnpm audit --json

   # Python
   pip-audit
   safety check

   # Go
   govulncheck ./...

   # Rust
   cargo audit

   # PHP
   composer audit
   ```

3. **Check for Outdated Packages**:
   ```bash
   npm outdated --json
   pip list --outdated
   go list -u -m all
   cargo outdated
   ```

4. **Analyze Results**:

   **For Each Vulnerability**:
   - CVE ID and severity (Critical/High/Medium/Low)
   - Affected package and version range
   - Fixed version (if available)
   - Exploit description
   - Upgrade path

   **For Outdated Packages**:
   - Current vs latest version
   - Breaking changes in upgrade path
   - Changelog highlights

5. **Generate Upgrade Plan**:
   - Prioritize by severity
   - Group related upgrades
   - Identify potential breaking changes
   - Suggest safe upgrade order

## Output Format

```markdown
## Dependency Audit Report

**Scanned**: [date]
**Packages**: X total, Y direct, Z transitive

### Security Vulnerabilities

#### Critical (X)
| Package | Current | Fixed | CVE | Description |
|---------|---------|-------|-----|-------------|
| lodash | 4.17.15 | 4.17.21 | CVE-2021-23337 | Command injection |

#### High (X)
[Similar table]

#### Medium (X)
[Similar table]

### Outdated Packages

| Package | Current | Latest | Type | Breaking |
|---------|---------|--------|------|----------|
| react | 17.0.2 | 18.2.0 | Major | Yes |
| axios | 0.21.0 | 1.6.0 | Major | Yes |

### Recommended Actions

1. **Immediate** (security fixes):
   ```bash
   npm install lodash@4.17.21
   ```

2. **Soon** (outdated, non-breaking):
   ```bash
   npm update minor-package
   ```

3. **Planned** (major upgrades):
   - React 18 migration guide: [link]

### License Compliance
[Any license concerns found]
```

## Enhancements

- Cross-reference with NIST NVD for complete CVE details
- Check for packages with no recent maintenance (abandoned)
- Identify duplicate packages in dependency tree
- Calculate dependency tree depth and bloat
- Suggest lighter alternatives for heavy packages
- Generate Dependabot/Renovate config for automated updates
- Check for typosquatting risks in package names
