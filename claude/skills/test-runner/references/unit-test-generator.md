---
name: unit-test-generator
description: Generates comprehensive unit tests for specified files with edge cases and mocking
triggers:
  - /unit-test
  - /generate-tests
  - /test-gen
---

# Instructions

When this skill is invoked, generate comprehensive unit tests for the specified file or function.

## Process

1. **Analyze Target Code**:
   - Read the target file completely
   - Identify all exported functions/classes/methods
   - Map dependencies and imports that need mocking
   - Understand input types, return types, and side effects

2. **Examine Existing Test Patterns**:
   - Use Glob to find existing test files (`**/*.test.*`, `**/*.spec.*`, `**/test_*.py`)
   - Read 1-2 existing tests to match project conventions
   - Identify testing framework (Jest, Pytest, Mocha, Go testing, etc.)
   - Note mocking patterns used (jest.mock, unittest.mock, testify, etc.)

3. **Generate Test Cases**:

   For each function/method, create tests for:
   - **Happy path**: Normal inputs producing expected outputs
   - **Edge cases**: Empty inputs, boundary values, null/undefined
   - **Error cases**: Invalid inputs, expected exceptions
   - **Type variations**: Different valid input types if applicable

4. **Structure Tests Properly**:
   ```
   describe('[FunctionName]', () => {
     describe('when given valid input', () => {
       it('should return expected result', () => {});
     });

     describe('when given invalid input', () => {
       it('should throw appropriate error', () => {});
     });

     describe('edge cases', () => {
       it('should handle empty input', () => {});
       it('should handle boundary values', () => {});
     });
   });
   ```

5. **Add Mocks and Fixtures**:
   - Mock external dependencies (APIs, databases, file system)
   - Create reusable test fixtures for common data
   - Set up and tear down properly

## Output Format

- Generate complete test file ready to run
- Include all necessary imports
- Add comments explaining non-obvious test cases
- Report coverage of identified code paths

## Enhancements

- Calculate cyclomatic complexity to ensure sufficient test coverage
- Generate property-based tests for pure functions
- Include snapshot tests for serialization functions
- Add performance benchmarks for critical paths
- Generate test data factories for complex objects
- Detect async code and generate proper async test patterns
