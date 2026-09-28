---
name: repo-from-idea
description: Scaffolds complete project structure from a concept - creates README, gitignore, folders, and initial configuration
triggers:
  - /repo-from-idea
  - /new-project
  - /scaffold-repo
---

# Instructions

When this skill is invoked, help the user create a complete project repository from their idea.

## Process

1. **Gather Requirements** (if not provided):
   - Ask for project name, description, and primary language/framework
   - Ask about project type: CLI tool, web app, API, library, etc.
   - Ask about package manager preference if applicable

2. **Analyze and Plan**:
   - Determine appropriate folder structure based on project type and language conventions
   - Identify necessary configuration files (.gitignore, editor configs, etc.)
   - Plan README sections based on project complexity

3. **Create Directory Structure**:
   Use appropriate conventions:
   - Python: `src/`, `tests/`, `docs/`
   - Node.js: `src/`, `lib/`, `test/`, `dist/`
   - Go: `cmd/`, `internal/`, `pkg/`
   - Generic: `src/`, `tests/`, `docs/`, `scripts/`

4. **Generate Files**:
   - **README.md**: Project title, description, installation, usage, contributing sections
   - **.gitignore**: Language-specific ignores (use gitignore.io patterns)
   - **LICENSE**: If specified, use appropriate SPDX license text
   - **Config files**: package.json, pyproject.toml, go.mod, Cargo.toml as needed
   - **.editorconfig**: Consistent formatting across editors

5. **Initialize Git**:
   ```bash
   git init
   git add .
   git commit -m "Initial commit: project scaffold"
   ```

## Output Format

After creating the structure, display:
- Tree view of created directories and files
- Summary of what was generated
- Suggested next steps for the user

## Enhancements

- Detect if running inside an existing git repo and warn
- Offer to add GitHub Actions workflow stub
- Include a basic CONTRIBUTING.md template
- Add .env.example if environment variables are likely needed
