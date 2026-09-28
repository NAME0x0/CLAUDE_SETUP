---
name: code-review
description: Performs comprehensive code review covering logic, security, performance, and best practices
triggers:
  - /code-review
  - /review
  - /cr
---

# Instructions

When this skill is invoked, perform a thorough code review of the specified file, PR, or recent changes.

## Process

1. **Determine Review Scope**:
   - If PR number given: `gh pr diff [number]`
   - If file given: Read the entire file
   - If no input: Review uncommitted changes via `git diff`

2. **Analyze Code Quality**:

   **Logic & Correctness**:
   - Verify algorithms are correct and handle all cases
   - Check for off-by-one errors, null references, race conditions
   - Ensure error handling covers failure modes
   - Validate business logic matches requirements

   **Security (OWASP Top 10)**:
   - SQL/NoSQL injection vulnerabilities
   - XSS (Cross-Site Scripting) risks
   - Authentication/authorization flaws
   - Sensitive data exposure
   - Insecure deserialization
   - Missing input validation

   **Performance**:
   - N+1 query problems
   - Unnecessary iterations or computations
   - Memory leaks or excessive allocations
   - Missing caching opportunities
   - Blocking operations in async contexts

   **Maintainability**:
   - Code clarity and readability
   - Appropriate naming conventions
   - DRY violations (repeated code)
   - Function/class size and complexity
   - Proper separation of concerns

3. **Check Against Project Standards**:
   - Read existing similar code for patterns
   - Verify consistency with project conventions
   - Check if tests are included for new code

4. **Generate Review Report**:

## Output Format

```markdown
## Code Review Summary

**Scope**: [files reviewed]
**Severity Counts**: 🔴 Critical: X | 🟠 Major: Y | 🟡 Minor: Z | 💡 Suggestions: W

### Critical Issues 🔴
[Security vulnerabilities, data loss risks, breaking bugs]

### Major Issues 🟠
[Logic errors, performance problems, missing error handling]

### Minor Issues 🟡
[Style inconsistencies, naming, minor improvements]

### Suggestions 💡
[Nice-to-haves, refactoring opportunities, best practices]

### What's Good ✅
[Positive observations about the code]
```

## Enhancements

- Cross-reference with project's existing patterns
- Check for common CVE patterns in dependencies used
- Verify test coverage for changed code
- Detect copied code that might have licensing issues
- Suggest specific refactoring patterns (extract method, etc.)
- Flag TODO/FIXME comments that should be addressed
