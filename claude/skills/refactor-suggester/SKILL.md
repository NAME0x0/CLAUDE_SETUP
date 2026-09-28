---
name: refactor-suggester
description: Identifies code smells and provides concrete refactoring suggestions with diffs
triggers:
  - /refactor-suggester
  - /refactor
  - /improve-code
---

# Instructions

When this skill is invoked, analyze code for improvement opportunities and provide actionable refactoring suggestions.

## Process

1. **Analyze Code Structure**:
   - Read target file(s) completely
   - Calculate function/method lengths
   - Identify class sizes and responsibilities
   - Map dependencies and coupling

2. **Detect Code Smells**:

   **Complexity Issues**:
   - Long methods (>20 lines)
   - Deep nesting (>3 levels)
   - High cyclomatic complexity (>10)
   - Too many parameters (>4)
   - Large classes (>300 lines)

   **Duplication**:
   - Copy-pasted code blocks
   - Similar logic in multiple places
   - Repeated patterns that could be abstracted

   **Coupling & Cohesion**:
   - Feature envy (method uses other class's data extensively)
   - Inappropriate intimacy between classes
   - God classes/functions doing too much
   - Shotgun surgery (one change requires many file edits)

   **Naming & Clarity**:
   - Unclear variable/function names
   - Magic numbers without constants
   - Comments explaining "what" instead of code being self-documenting

3. **Propose Refactorings**:

   For each smell, suggest specific patterns:
   - **Extract Method**: For long functions
   - **Extract Class**: For god classes
   - **Replace Conditional with Polymorphism**: For complex switch/if chains
   - **Introduce Parameter Object**: For too many parameters
   - **Replace Magic Number with Constant**: For literals
   - **Compose Method**: For improving readability
   - **Extract Variable**: For complex expressions

4. **Generate Diffs**:
   Show before/after for each suggestion

## Output Format

```markdown
## Refactoring Analysis

**File**: path/to/file.js
**Overall Health**: 6/10

### Issues Found

#### 1. [Smell Type] - [Location]
**Severity**: High/Medium/Low
**Current Code**:
```[lang]
[problematic code]
```

**Suggested Refactoring**: [Pattern name]
**Refactored Code**:
```[lang]
[improved code]
```

**Benefits**: [Why this is better]

---

### Summary
- 3 High priority refactorings
- 5 Medium priority improvements
- Estimated complexity reduction: 40%
```

## Enhancements

- Calculate before/after complexity metrics
- Detect patterns that could use design patterns
- Suggest incremental refactoring order (safest first)
- Identify opportunities for functional programming patterns
- Flag code that would benefit from dependency injection
- Offer to apply refactorings automatically
