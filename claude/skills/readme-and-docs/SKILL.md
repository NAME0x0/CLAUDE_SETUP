---
name: readme-and-docs
description: Generates professional READMEs, API documentation, and contribution guides
triggers:
  - /readme-and-docs
  - /docs
  - /readme
---

# Instructions

When this skill is invoked, analyze the project and generate comprehensive documentation.

## Process

1. **Analyze Project**:
   - Read package.json, pyproject.toml, Cargo.toml, go.mod for metadata
   - Identify main entry points and public APIs
   - Find existing documentation to enhance (not replace)
   - Determine project type (library, CLI, web app, API)

2. **Gather Information**:
   - Project name and description
   - Installation methods
   - Dependencies and requirements
   - Available scripts/commands
   - Configuration options
   - License information

3. **Generate README.md**:

   ```markdown
   # Project Name

   [![License](badge)][license-url]
   [![Version](badge)][version-url]

   > One-line description of what this project does.

   ## Features

   - Feature 1
   - Feature 2
   - Feature 3

   ## Installation

   ### Prerequisites
   - Node.js >= 18
   - npm or yarn

   ### Quick Start
   ```bash
   npm install project-name
   ```

   ## Usage

   ### Basic Example
   ```javascript
   import { feature } from 'project-name';
   // Usage example
   ```

   ### Advanced Usage
   [More complex examples]

   ## Configuration

   | Option | Type | Default | Description |
   |--------|------|---------|-------------|
   | ... | ... | ... | ... |

   ## API Reference

   [Link to full docs or inline API docs]

   ## Contributing

   See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

   ## License

   [License type] - see [LICENSE](LICENSE) for details.
   ```

4. **Generate CONTRIBUTING.md**:
   - Development setup instructions
   - Code style guidelines
   - PR process
   - Issue reporting guidelines
   - Testing requirements

5. **Generate Additional Docs** (if applicable):
   - API.md for libraries
   - ARCHITECTURE.md for complex projects
   - CHANGELOG.md template
   - CODE_OF_CONDUCT.md

## Output Format

List all generated/updated documentation files with summaries of what each contains.

## Enhancements

- Extract JSDoc/docstrings into API documentation
- Generate badges dynamically (CI status, coverage, npm version)
- Create documentation site config (Docusaurus, MkDocs, VitePress)
- Add FAQ section based on common patterns in code
- Generate architecture diagrams from code analysis
- Create quick reference cards for CLI tools
- Add troubleshooting section for common issues
