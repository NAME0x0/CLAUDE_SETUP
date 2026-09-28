---
name: dead-code-purger
description: Identifies and removes unused imports, functions, variables, and orphaned files
triggers:
  - /dead-code-purger
  - /dead-code
  - /cleanup
---

# Instructions

When this skill is invoked, analyze the codebase for unused code and safely remove it.

## Process

1. **Run Language-Specific Analysis Tools**:

   **TypeScript/JavaScript**:
   ```bash
   # Find unused exports
   npx ts-prune

   # Find unused dependencies
   npx depcheck

   # ESLint unused rules
   npx eslint --rule 'no-unused-vars: error' .
   ```

   **Python**:
   ```bash
   # Find unused imports and variables
   vulture . --min-confidence 80

   # Alternative
   autoflake --check --remove-all-unused-imports -r .
   ```

   **Go**:
   ```bash
   # Built-in unused detection
   go build ./... 2>&1 | grep "declared but not used"

   # With staticcheck
   staticcheck ./...
   ```

2. **Identify Dead Code Categories**:

   **Unused Imports**:
   ```typescript
   // REMOVE: imported but never used
   import { unusedHelper } from './utils';
   ```

   **Unused Variables**:
   ```typescript
   // REMOVE: assigned but never read
   const unusedConfig = { ... };
   ```

   **Unused Functions/Methods**:
   ```typescript
   // REMOVE: defined but never called
   function legacyHelper() { ... }
   ```

   **Unreachable Code**:
   ```typescript
   function example() {
     return early;
     // REMOVE: unreachable
     console.log('never runs');
   }
   ```

   **Orphaned Files**:
   - Files not imported anywhere
   - Test files for deleted code
   - Old migration files
   - Unused assets

3. **Analyze Dependency Graph**:
   - Build import/require graph from entry points
   - Mark all reachable modules
   - Identify modules with no incoming edges

4. **Safety Checks**:
   - Check for dynamic imports (`import()`, `require()`)
   - Check for reflection usage
   - Verify not removing public API exports
   - Check for framework magic (decorators, annotations)
   - Look for string-based references

5. **Generate Removal Plan**:

   ```markdown
   ### Safe to Remove (High Confidence)

   | Type | Location | Reason |
   |------|----------|--------|
   | Import | src/utils.ts:3 | `lodash` - never used |
   | Function | src/helpers.ts:45 | `formatLegacy()` - no callers |
   | Variable | src/config.ts:12 | `OLD_API_URL` - unreferenced |
   | File | src/deprecated/old.ts | No imports anywhere |

   ### Review Required (Lower Confidence)

   | Type | Location | Concern |
   |------|----------|---------|
   | Export | src/api/index.ts | `legacyEndpoint` - may be public API |
   | Function | src/utils.ts:78 | `dynamicHelper` - possible dynamic call |
   ```

6. **Apply Removals**:
   - Remove with Edit tool
   - Preserve git history context
   - Run tests after each batch

## Output Format

```markdown
## Dead Code Analysis

### Summary
- **Files Analyzed**: 156
- **Dead Code Found**: 23 items
- **Estimated Lines**: 450
- **Unused Dependencies**: 3

### Unused Dependencies
```bash
npm uninstall lodash moment left-pad
```

### Unused Exports (ts-prune)
| File | Export | Lines |
|------|--------|-------|
| src/utils/helpers.ts | formatDate | 15-30 |
| src/utils/helpers.ts | parseQuery | 32-45 |
| src/api/legacy.ts | entire file | 1-120 |

### Unused Variables
| File | Variable | Line |
|------|----------|------|
| src/config.ts | DEBUG_MODE | 5 |
| src/constants.ts | OLD_VERSION | 12 |

### Orphaned Files
- `src/components/OldButton.tsx`
- `src/utils/deprecated.ts`
- `src/__tests__/old.test.ts`

### Removal Commands
```bash
# Remove unused dependencies
npm uninstall lodash moment left-pad

# Remove orphaned files
rm src/components/OldButton.tsx
rm src/utils/deprecated.ts

# Or apply all automatically
[Offer to apply changes]
```

### Post-Cleanup
- [ ] Run full test suite
- [ ] Verify build succeeds
- [ ] Check bundle size reduction
```

## Enhancements

- Calculate bundle size savings
- Detect code only used in tests (may be intentional)
- Find duplicate code blocks
- Identify dead CSS classes
- Check for unused database columns/tables
- Generate refactoring suggestions for sparse files
- Track dead code trends over time
