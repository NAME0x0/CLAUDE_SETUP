---
name: edge-case-tester
description: Generates fuzzing-style tests for boundary values, null inputs, and edge conditions
triggers:
  - /edge-case-tester
  - /edge-cases
  - /fuzz
---

# Instructions

When this skill is invoked, analyze functions and generate comprehensive edge case tests.

## Process

1. **Analyze Target Functions**:
   - Read function signatures and types
   - Identify input parameters and their types
   - Understand return type and possible errors
   - Note any validation or constraints

2. **Identify Edge Case Categories**:

   **Numeric Inputs**:
   - Zero (0)
   - Negative numbers (-1, -Infinity)
   - Very large numbers (MAX_SAFE_INTEGER, Infinity)
   - Floating point edge cases (0.1 + 0.2, NaN)
   - Boundary values (n-1, n, n+1 for limits)

   **String Inputs**:
   - Empty string ("")
   - Whitespace only ("   ", "\t\n")
   - Very long strings (10000+ chars)
   - Unicode characters (emoji, RTL, zero-width)
   - Special characters (`<script>`, SQL injection patterns)
   - Null bytes ("\0")

   **Array/Collection Inputs**:
   - Empty array ([])
   - Single element ([x])
   - Very large arrays (100000+ items)
   - Arrays with null/undefined elements
   - Nested arrays (deep structures)
   - Duplicate elements

   **Object Inputs**:
   - Empty object ({})
   - Missing required properties
   - Extra unexpected properties
   - Circular references
   - Prototype pollution attempts

   **Null/Undefined**:
   - null
   - undefined
   - Optional parameters omitted

   **Type Coercion**:
   - "123" instead of 123
   - "true" instead of true
   - [] instead of {}

3. **Generate Edge Case Tests**:

   ```typescript
   describe('processUserInput', () => {
     describe('edge cases: numeric limits', () => {
       it('should handle zero', () => {
         expect(processUserInput(0)).toEqual(/* expected */);
       });

       it('should handle negative numbers', () => {
         expect(processUserInput(-1)).toEqual(/* expected */);
       });

       it('should handle MAX_SAFE_INTEGER', () => {
         expect(processUserInput(Number.MAX_SAFE_INTEGER)).toEqual(/* expected */);
       });

       it('should handle Infinity', () => {
         expect(() => processUserInput(Infinity)).toThrow();
       });

       it('should handle NaN', () => {
         expect(() => processUserInput(NaN)).toThrow(ValidationError);
       });
     });

     describe('edge cases: strings', () => {
       it('should handle empty string', () => {
         expect(processUserInput('')).toEqual(/* expected */);
       });

       it('should handle whitespace-only string', () => {
         expect(processUserInput('   \t\n')).toEqual(/* expected */);
       });

       it('should handle very long strings', () => {
         const longString = 'a'.repeat(100000);
         expect(processUserInput(longString)).toEqual(/* expected */);
       });

       it('should handle unicode characters', () => {
         expect(processUserInput('Hello 👋 World')).toEqual(/* expected */);
       });

       it('should sanitize potential XSS', () => {
         const xss = '<script>alert("xss")</script>';
         expect(processUserInput(xss)).not.toContain('<script>');
       });

       it('should handle null bytes', () => {
         expect(processUserInput('hello\0world')).toEqual(/* expected */);
       });
     });

     describe('edge cases: null/undefined', () => {
       it('should handle null', () => {
         expect(() => processUserInput(null)).toThrow(TypeError);
       });

       it('should handle undefined', () => {
         expect(() => processUserInput(undefined)).toThrow(TypeError);
       });
     });

     describe('edge cases: arrays', () => {
       it('should handle empty array', () => {
         expect(processItems([])).toEqual([]);
       });

       it('should handle single-element array', () => {
         expect(processItems([item])).toEqual([/* expected */]);
       });

       it('should handle array with null elements', () => {
         expect(() => processItems([1, null, 3])).toThrow();
       });

       it('should handle very large arrays', () => {
         const largeArray = Array.from({ length: 100000 }, (_, i) => i);
         expect(() => processItems(largeArray)).not.toThrow();
       });
     });

     describe('edge cases: concurrent/timing', () => {
       it('should handle rapid successive calls', async () => {
         const promises = Array.from({ length: 100 }, () => processAsync());
         await expect(Promise.all(promises)).resolves.toBeDefined();
       });

       it('should handle timeout scenarios', async () => {
         jest.useFakeTimers();
         const promise = processWithTimeout();
         jest.advanceTimersByTime(30000);
         await expect(promise).rejects.toThrow(TimeoutError);
       });
     });
   });
   ```

4. **Property-Based Testing** (for pure functions):

   ```typescript
   import fc from 'fast-check';

   describe('sortArray (property-based)', () => {
     it('should always return same length', () => {
       fc.assert(
         fc.property(fc.array(fc.integer()), (arr) => {
           return sortArray(arr).length === arr.length;
         })
       );
     });

     it('should be idempotent', () => {
       fc.assert(
         fc.property(fc.array(fc.integer()), (arr) => {
           const once = sortArray(arr);
           const twice = sortArray(once);
           return JSON.stringify(once) === JSON.stringify(twice);
         })
       );
     });

     it('should contain all original elements', () => {
       fc.assert(
         fc.property(fc.array(fc.integer()), (arr) => {
           const sorted = sortArray(arr);
           return arr.every(el => sorted.includes(el));
         })
       );
     });
   });
   ```

## Output Format

```markdown
## Edge Case Test Generation

### Function Analyzed
`processUserData(input: UserInput): ProcessedData`

### Edge Cases Identified: 24

| Category | Test Cases | Risk Level |
|----------|------------|------------|
| Null/Undefined | 4 | High |
| Boundary Values | 6 | Medium |
| String Edge Cases | 8 | Medium |
| Type Coercion | 4 | Low |
| Concurrent Access | 2 | High |

### Generated Test File
`src/__tests__/processUserData.edge.test.ts`

### Coverage Impact
- Branch coverage: +15%
- Edge case coverage: New

### Recommended Additional Tests
- [ ] Add property-based tests with fast-check
- [ ] Add timeout handling tests
- [ ] Add concurrent access tests
```

## Enhancements

- Integrate with fuzzing tools (AFL, libFuzzer)
- Generate mutation testing scenarios
- Create chaos engineering tests
- Add load/stress test patterns
- Generate API contract tests
- Include security-focused edge cases
- Create regression test from production errors
