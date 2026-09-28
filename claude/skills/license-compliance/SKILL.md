---
name: license-compliance
description: Audits third-party licenses and generates legal compliance notices
triggers:
  - /license-compliance
  - /licenses
  - /legal
---

# Instructions

When this skill is invoked, audit all dependencies for license compliance and generate required notices.

## Process

1. **Scan Dependencies**:
   ```bash
   # Node.js
   npx license-checker --json

   # Python
   pip-licenses --format=json

   # Go
   go-licenses csv ./...

   # Rust
   cargo license --json
   ```

2. **Categorize Licenses**:

   **Permissive (Generally Safe)**:
   - MIT
   - Apache-2.0
   - BSD-2-Clause, BSD-3-Clause
   - ISC
   - Unlicense, CC0-1.0

   **Copyleft (Requires Attention)**:
   - GPL-2.0, GPL-3.0 (strong copyleft)
   - LGPL-2.1, LGPL-3.0 (weak copyleft)
   - MPL-2.0 (file-level copyleft)
   - AGPL-3.0 (network copyleft)

   **Proprietary/Restrictive**:
   - Commercial licenses
   - Custom licenses
   - No license specified (all rights reserved)

3. **Check Compatibility**:

   | Your License | Can Use Permissive | Can Use LGPL | Can Use GPL |
   |--------------|-------------------|--------------|-------------|
   | MIT | ✅ | ✅ (dynamic link) | ❌ |
   | Apache-2.0 | ✅ | ✅ (dynamic link) | ❌ |
   | GPL-3.0 | ✅ | ✅ | ✅ |
   | Proprietary | ✅ | ✅ (dynamic link) | ❌ |

4. **Generate NOTICE/THIRD-PARTY File**:

   ```markdown
   # Third-Party Licenses

   This project uses the following third-party libraries:

   ## MIT License

   ### lodash (4.17.21)
   Copyright (c) JS Foundation and other contributors

   Permission is hereby granted, free of charge...
   [Full MIT text]

   ### axios (1.6.0)
   Copyright (c) 2014-present Matt Zabriskie

   [License text]

   ## Apache License 2.0

   ### typescript (5.3.0)
   Copyright (c) Microsoft Corporation

   [License text or reference]
   ```

5. **Generate Compliance Report**:

## Output Format

```markdown
## License Compliance Report

**Total Dependencies**: 150
**Direct**: 25 | **Transitive**: 125

### License Distribution

| License | Count | Risk Level |
|---------|-------|------------|
| MIT | 98 | ✅ Low |
| Apache-2.0 | 32 | ✅ Low |
| ISC | 12 | ✅ Low |
| BSD-3-Clause | 5 | ✅ Low |
| GPL-3.0 | 2 | ⚠️ High |
| Unknown | 1 | 🔴 Critical |

### Issues Found

#### 🔴 Critical: Unknown License
- **Package**: some-package@1.0.0
- **Action Required**: Contact author or find alternative

#### ⚠️ Warning: GPL-3.0 Dependency
- **Package**: gpl-lib@2.0.0
- **Impact**: May require open-sourcing your code
- **Alternatives**: [list alternatives]

### Generated Files
- `THIRD-PARTY-LICENSES.md` - Full license texts
- `NOTICE` - Attribution notices

### Recommendations
1. Replace `gpl-lib` with MIT-licensed alternative
2. Contact `some-package` author for license clarification
```

## Enhancements

- Detect license conflicts between dependencies
- Generate SBOM (Software Bill of Materials) in SPDX format
- Check against company-approved license list
- Monitor for license changes on updates
- Generate compliance documentation for legal review
- Identify dependencies with multiple licenses (AND/OR)
- Check for patent clauses in licenses
