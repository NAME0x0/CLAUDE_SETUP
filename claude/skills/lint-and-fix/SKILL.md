---
name: lint-and-fix
description: Runs linters and formatters, auto-applies fixes, and reports remaining issues
triggers:
  - /lint-and-fix
  - /lint
  - /format
---

# Instructions

When this skill is invoked, detect project linters/formatters, run them, and auto-apply safe fixes.

## Process

1. **Detect Tooling**:

   **JavaScript/TypeScript**:
   - ESLint: Check for .eslintrc*, eslint.config.js
   - Prettier: Check for .prettierrc*, prettier.config.js
   - Biome: Check for biome.json

   **Python**:
   - Ruff: Check for ruff.toml, pyproject.toml [tool.ruff]
   - Black: Check for pyproject.toml [tool.black]
   - Flake8: Check for .flake8, setup.cfg
   - isort: Check for .isort.cfg, pyproject.toml [tool.isort]
   - mypy: Check for mypy.ini, pyproject.toml [tool.mypy]

   **Go**:
   - gofmt, goimports (built-in)
   - golangci-lint: Check for .golangci.yml

   **Rust**:
   - rustfmt: Check for rustfmt.toml
   - clippy (built-in)

2. **Run Formatters First** (safe auto-fix):
   ```bash
   # Examples
   npx prettier --write .
   black .
   ruff format .
   gofmt -w .
   cargo fmt
   ```

3. **Run Linters with Auto-fix**:
   ```bash
   npx eslint --fix .
   ruff check --fix .
   golangci-lint run --fix
   cargo clippy --fix
   ```

4. **Run Type Checkers**:
   ```bash
   npx tsc --noEmit
   mypy .
   ```

5. **Report Results**:
   - Summarize what was auto-fixed
   - List remaining issues that need manual attention
   - Categorize by severity and file

## Output Format

```markdown
## Lint & Format Report

### Auto-Fixed ✅
- Formatted 15 files with Prettier
- Fixed 8 ESLint issues (unused imports, spacing)
- Sorted imports in 5 Python files

### Requires Manual Fix 🔧

#### Errors (must fix)
| File | Line | Rule | Message |
|------|------|------|---------|
| src/api.ts | 42 | @typescript-eslint/no-explicit-any | Avoid using 'any' |

#### Warnings (should fix)
| File | Line | Rule | Message |
|------|------|------|---------|
| src/utils.py | 15 | C901 | Function too complex (12 > 10) |

### Type Errors
[List of type checking issues]
```

## Enhancements

- If no linter config exists, offer to create sensible defaults
- Detect conflicting rules between tools (Prettier vs ESLint)
- Run incrementally on changed files only for speed
- Cache results to avoid re-linting unchanged files
- Offer to add lint-staged and husky for pre-commit hooks
- Group related issues to suggest batch fixes
