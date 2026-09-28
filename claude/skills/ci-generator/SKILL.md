---
name: ci-generator
description: Detects project type and generates CI/CD pipelines for GitHub Actions, GitLab CI, etc.
triggers:
  - /ci-generator
  - /ci
  - /github-actions
---

# Instructions

When this skill is invoked, analyze the project and generate appropriate CI/CD configuration.

## Process

1. **Detect Project Characteristics**:
   - Language/framework from manifest files
   - Test framework in use
   - Build tools and commands
   - Deployment targets (if detectable)
   - Existing CI config to enhance

2. **Determine CI Platform**:
   - Check for existing `.github/workflows/` → GitHub Actions
   - Check for `.gitlab-ci.yml` → GitLab CI
   - Check for `Jenkinsfile` → Jenkins
   - Check for `.circleci/` → CircleCI
   - Default to GitHub Actions if none exist

3. **Generate Pipeline Stages**:

   **Standard Pipeline**:
   ```
   Install → Lint → Test → Build → Deploy (optional)
   ```

   **GitHub Actions Example**:
   ```yaml
   name: CI

   on:
     push:
       branches: [main, develop]
     pull_request:
       branches: [main]

   jobs:
     lint:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: actions/setup-node@v4
           with:
             node-version: '20'
             cache: 'npm'
         - run: npm ci
         - run: npm run lint

     test:
       runs-on: ubuntu-latest
       needs: lint
       steps:
         - uses: actions/checkout@v4
         - uses: actions/setup-node@v4
           with:
             node-version: '20'
             cache: 'npm'
         - run: npm ci
         - run: npm test -- --coverage
         - uses: codecov/codecov-action@v4

     build:
       runs-on: ubuntu-latest
       needs: test
       steps:
         - uses: actions/checkout@v4
         - uses: actions/setup-node@v4
           with:
             node-version: '20'
             cache: 'npm'
         - run: npm ci
         - run: npm run build
         - uses: actions/upload-artifact@v4
           with:
             name: build
             path: dist/
   ```

4. **Add Language-Specific Jobs**:

   **Python**: mypy, pytest with coverage, build wheel
   **Go**: golangci-lint, go test, go build
   **Rust**: clippy, cargo test, cargo build --release
   **Node**: eslint, jest, npm run build

5. **Include Matrix Testing** (if applicable):
   - Multiple Node/Python/Go versions
   - Multiple OS (ubuntu, windows, macos)
   - Multiple database versions for integration tests

6. **Add Deployment Stage** (optional):
   - npm publish for libraries
   - Docker build and push
   - Cloud deployment (AWS, GCP, Vercel, etc.)

## Output Format

```markdown
## CI Configuration Generated

**Platform**: GitHub Actions
**File**: `.github/workflows/ci.yml`

### Pipeline Overview
```
[Mermaid diagram of pipeline]
```

### Jobs Created
1. **lint** - Code style and static analysis
2. **test** - Unit and integration tests with coverage
3. **build** - Production build verification

### Triggers
- Push to: main, develop
- Pull requests to: main

### Next Steps
- Add repository secrets: [list if needed]
- Configure branch protection rules
- Set up Codecov/Coveralls for coverage
```

## Enhancements

- Detect secrets needed and list them
- Add caching for faster builds
- Generate dependabot.yml for dependency updates
- Add release workflow for semantic versioning
- Include security scanning (CodeQL, Snyk)
- Add performance benchmarking jobs
- Generate status badges for README
