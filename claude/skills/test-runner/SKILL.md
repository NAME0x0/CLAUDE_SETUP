---
name: test-runner
description: Runs tests for changed files, analyzes failures, and provides fix suggestions. Also generates unit tests and edge-case/boundary tests (absorbed unit-test-generator and edge-case-tester).
triggers:
  - /test-runner
  - /run-tests
  - /test
---

# Instructions

When this skill is invoked, intelligently run tests and provide actionable feedback on failures.

## Process

1. **Detect Test Framework**:
   - Check package.json for jest, mocha, vitest, etc.
   - Check pyproject.toml/setup.py for pytest, unittest
   - Check go.mod for Go testing
   - Check Cargo.toml for Rust tests
   - Identify test command from scripts or Makefile

2. **Determine Test Scope**:
   - If specific file provided, run tests for that file only
   - If no file specified, check git status for changed files
   - Map changed source files to their corresponding test files
   - Run affected tests first, then full suite if requested

3. **Execute Tests**:
   ```bash
   # Examples by framework
   npm test -- --coverage --changedSince=main
   pytest -v --tb=short [test_file]
   go test -v ./...
   cargo test
   ```

4. **Analyze Results**:
   - Parse test output for failures and errors
   - For each failure:
     - Read the failing test code
     - Read the source code being tested
     - Identify the discrepancy between expected and actual
     - Determine if it's a test bug or source bug

5. **Provide Fix Suggestions**:
   For each failure, provide:
   - Clear explanation of what failed and why
   - Whether the test or source needs fixing
   - Specific code changes to resolve
   - Offer to apply the fix directly

## Output Format

```markdown
## Test Results

**Total**: X | **Passed**: Y | **Failed**: Z | **Skipped**: W

### Failures

#### 1. [test name]
- **File**: path/to/test.js:42
- **Error**: Expected X but got Y
- **Analysis**: [Explanation]
- **Suggested Fix**: [Code or approach]

### Coverage Summary (if available)
- Statements: X%
- Branches: Y%
- Functions: Z%
```

## Enhancements

- Cache test results to skip unchanged tests
- Run tests in parallel when supported
- Prioritize recently failed tests
- Detect flaky tests by checking for intermittent failures
- Suggest missing test coverage for uncovered code paths
- Integrate with CI status if available

## Test generation (merged from unit-test-generator + edge-case-tester)

- Generating new unit tests for uncovered code → read `references/unit-test-generator.md` and follow it.
- Boundary values, null inputs, fuzz-style edge cases → read `references/edge-case-tester.md` and follow it.
