---
name: bug-reproducer
description: Analyzes error logs/stack traces and creates minimal reproduction test cases
triggers:
  - /bug-reproducer
  - /reproduce-bug
  - /debug
---

# Instructions

When this skill is invoked with an error log, stack trace, or bug description, systematically analyze and create a minimal failing test case.

## Process

1. **Parse the Error**:
   - Extract error type/name, message, and stack trace
   - Identify the originating file and line number
   - Note any relevant context (request data, state, inputs)

2. **Trace the Code Path**:
   - Use Read to examine the file where the error originated
   - Follow the stack trace upward to understand the call chain
   - Use Grep to find related code that might contribute to the issue
   - Identify the exact conditions that trigger the bug

3. **Isolate Variables**:
   - Determine the minimal inputs required to reproduce
   - Identify which state/dependencies are involved
   - Note any timing, concurrency, or order-dependent factors

4. **Create Reproduction Test**:
   ```
   test('[BUG] Description of the failing behavior', () => {
     // Arrange: Set up minimal required state
     // Act: Execute the code path that fails
     // Assert: Verify the bug manifests (this should FAIL)
   });
   ```

5. **Document Findings**:
   - Root cause hypothesis
   - Minimal reproduction steps
   - Affected code paths
   - Suggested fix approach

## Output Format

```markdown
## Bug Analysis

**Error**: [Error type and message]
**Location**: [file:line]
**Root Cause**: [Explanation]

## Reproduction Test

[Generated test code]

## Steps to Reproduce
1. [Step 1]
2. [Step 2]
...

## Suggested Fix
[Approach to resolve]
```

## Enhancements

- Cross-reference with similar past errors using Grep
- Check if error matches known patterns (null reference, race condition, etc.)
- Generate both unit test and integration test reproductions
- Include relevant git blame info for recently changed code
- Offer to create a GitHub issue template with findings
