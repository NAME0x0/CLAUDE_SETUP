---
name: changelog-automator
description: Parses git history to generate professional CHANGELOG.md following Keep a Changelog format
triggers:
  - /changelog-automator
  - /changelog
  - /release-notes
---

# Instructions

When this skill is invoked, analyze git history and generate a properly formatted changelog.

## Process

1. **Analyze Git History**:
   ```bash
   # Get commits since last tag
   git log $(git describe --tags --abbrev=0)..HEAD --oneline

   # Get all tags for version history
   git tag --sort=-version:refname

   # Get commits with conventional commit format
   git log --pretty=format:"%h %s" --since="last month"
   ```

2. **Parse Conventional Commits**:

   | Prefix | Category | Changelog Section |
   |--------|----------|-------------------|
   | feat: | Features | Added |
   | fix: | Bug Fixes | Fixed |
   | docs: | Documentation | - |
   | style: | Styling | - |
   | refactor: | Refactoring | Changed |
   | perf: | Performance | Changed |
   | test: | Tests | - |
   | build: | Build | - |
   | ci: | CI | - |
   | chore: | Chores | - |
   | BREAKING CHANGE: | Breaking | Changed (⚠️) |

3. **Group by Version/Release**:

   Determine version:
   - If `feat:` present → minor bump
   - If `fix:` only → patch bump
   - If `BREAKING CHANGE:` → major bump
   - Use explicit version if provided

4. **Generate CHANGELOG.md**:

   ```markdown
   # Changelog

   All notable changes to this project will be documented in this file.

   The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
   and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

   ## [Unreleased]

   ### Added
   - New user authentication flow with OAuth2 support (#123)
   - Dark mode toggle in settings page (#145)

   ### Changed
   - Upgraded Node.js from 18 to 20 (#156)
   - Improved API response times by 40% (#148)

   ### Fixed
   - Fixed memory leak in WebSocket connections (#134)
   - Corrected timezone handling in date picker (#141)

   ### Security
   - Updated dependencies to patch CVE-2024-1234 (#155)

   ## [2.1.0] - 2024-01-15

   ### Added
   - Export functionality for user data (#120)
   - Multi-language support (Spanish, French) (#118)

   ### Changed
   - **BREAKING**: Renamed `getUserData` to `fetchUserProfile` (#122)
   - Migrated from REST to GraphQL for user queries (#119)

   ### Deprecated
   - Legacy `/api/v1/users` endpoint (use `/api/v2/users`) (#121)

   ### Removed
   - Dropped support for Node.js 16 (#117)

   ### Fixed
   - Fixed race condition in concurrent uploads (#115)

   ## [2.0.0] - 2024-01-01

   ### Changed
   - **BREAKING**: Complete API redesign (#100)

   [Unreleased]: https://github.com/user/repo/compare/v2.1.0...HEAD
   [2.1.0]: https://github.com/user/repo/compare/v2.0.0...v2.1.0
   [2.0.0]: https://github.com/user/repo/releases/tag/v2.0.0
   ```

5. **Generate Release Notes** (for GitHub Releases):

   ```markdown
   ## What's Changed

   ### ✨ New Features
   * Add OAuth2 authentication by @developer in #123
   * Implement dark mode by @contributor in #145

   ### 🐛 Bug Fixes
   * Fix memory leak in WebSocket by @maintainer in #134

   ### 🔒 Security
   * Update lodash to fix prototype pollution by @dependabot in #155

   ### 📚 Documentation
   * Update API documentation by @docs-team in #150

   **Full Changelog**: https://github.com/user/repo/compare/v2.0.0...v2.1.0
   ```

## Output Format

```markdown
## Changelog Generated

### Analysis
- **Commits Analyzed**: 45
- **Date Range**: 2024-01-01 to 2024-01-15
- **Suggested Version**: 2.1.0 (minor - new features)

### Changes Summary
| Category | Count |
|----------|-------|
| Added | 5 |
| Changed | 3 |
| Fixed | 8 |
| Security | 1 |

### Files Updated
- `CHANGELOG.md` - Updated with new entries
- (Optional) `package.json` - Version bumped

### Preview
[Generated changelog section]

### Commands
```bash
# Create git tag
git tag -a v2.1.0 -m "Release 2.1.0"

# Push tag
git push origin v2.1.0

# Create GitHub release
gh release create v2.1.0 --generate-notes
```
```

## Enhancements

- Link commits to GitHub issues/PRs automatically
- Generate release notes for multiple platforms
- Create visual changelog (timeline)
- Detect breaking changes from API diffs
- Generate contributor acknowledgments
- Support monorepo with per-package changelogs
- Export to RSS feed for subscribers
