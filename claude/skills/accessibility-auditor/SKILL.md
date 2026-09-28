---
name: accessibility-auditor
description: Audits UI code against WCAG standards and generates ARIA fixes
triggers:
  - /accessibility-auditor
  - /a11y
  - /wcag
---

# Instructions

When this skill is invoked, audit UI code for accessibility issues and provide fixes.

## Process

1. **Scan UI Components**:
   - Find all component files (React, Vue, Svelte, HTML)
   - Identify interactive elements (buttons, links, forms)
   - Check for images, media, and dynamic content

2. **Check WCAG 2.1 Criteria**:

   **Level A (Must Fix)**:
   - 1.1.1 Non-text Content: Images need alt text
   - 1.3.1 Info and Relationships: Semantic HTML structure
   - 1.4.1 Use of Color: Not sole means of conveying info
   - 2.1.1 Keyboard: All functionality keyboard accessible
   - 2.4.1 Bypass Blocks: Skip navigation links
   - 4.1.1 Parsing: Valid HTML
   - 4.1.2 Name, Role, Value: ARIA properly used

   **Level AA (Should Fix)**:
   - 1.4.3 Contrast (Minimum): 4.5:1 for normal text
   - 1.4.4 Resize Text: Up to 200% without loss
   - 2.4.6 Headings and Labels: Descriptive headings
   - 2.4.7 Focus Visible: Visible focus indicator
   - 3.1.2 Language of Parts: Lang attribute on foreign text

3. **Common Issues to Detect**:

   **Images**:
   ```tsx
   // ❌ Bad: Missing alt
   <img src="logo.png" />

   // ✅ Good: Descriptive alt
   <img src="logo.png" alt="Company Logo" />

   // ✅ Good: Decorative image
   <img src="divider.png" alt="" role="presentation" />
   ```

   **Buttons and Links**:
   ```tsx
   // ❌ Bad: No accessible name
   <button><Icon name="close" /></button>

   // ✅ Good: aria-label for icon-only buttons
   <button aria-label="Close dialog"><Icon name="close" /></button>

   // ❌ Bad: Click handler on non-interactive element
   <div onClick={handleClick}>Click me</div>

   // ✅ Good: Proper button
   <button onClick={handleClick}>Click me</button>
   ```

   **Forms**:
   ```tsx
   // ❌ Bad: Input without label
   <input type="email" placeholder="Email" />

   // ✅ Good: Associated label
   <label htmlFor="email">Email</label>
   <input id="email" type="email" />

   // ✅ Good: aria-label alternative
   <input type="email" aria-label="Email address" />

   // ❌ Bad: No error announcement
   {error && <span className="error">{error}</span>}

   // ✅ Good: Live region for errors
   {error && <span role="alert" aria-live="polite">{error}</span>}
   ```

   **Headings**:
   ```tsx
   // ❌ Bad: Skipped heading level
   <h1>Title</h1>
   <h3>Section</h3>  // Missing h2!

   // ✅ Good: Sequential headings
   <h1>Title</h1>
   <h2>Section</h2>
   ```

   **Focus Management**:
   ```tsx
   // ❌ Bad: Focus trap in modal
   // User can't escape modal with keyboard

   // ✅ Good: Proper focus trap
   <FocusTrap>
     <dialog>
       <button autoFocus>First focusable</button>
       ...
       <button onClick={close}>Close</button>
     </dialog>
   </FocusTrap>
   ```

   **Color Contrast**:
   ```css
   /* ❌ Bad: Low contrast */
   .text { color: #999; background: #fff; } /* 2.85:1 ratio */

   /* ✅ Good: WCAG AA compliant */
   .text { color: #595959; background: #fff; } /* 7:1 ratio */
   ```

4. **Generate Fixes**:

   For each issue, provide:
   - Current code
   - Fixed code
   - WCAG criterion reference
   - Severity (A, AA, AAA)

5. **Suggest Testing**:
   ```bash
   # axe-core CLI
   npx axe <url>

   # Lighthouse
   lighthouse <url> --only-categories=accessibility

   # jest-axe in tests
   expect(await axe(container)).toHaveNoViolations();
   ```

## Output Format

```markdown
## Accessibility Audit Report

### Summary
- **Components Scanned**: 45
- **Issues Found**: 23
- **Level A Violations**: 8 (critical)
- **Level AA Violations**: 12 (important)
- **Level AAA Suggestions**: 3 (optional)

### Critical Issues (Level A)

#### 1. Missing alt text on images
**WCAG**: 1.1.1 Non-text Content
**Files**: 5 components

| File | Line | Current | Fix |
|------|------|---------|-----|
| Hero.tsx | 12 | `<img src={hero} />` | Add `alt="..."` |
| Card.tsx | 8 | `<img src={thumb} />` | Add `alt="..."` |

#### 2. Non-keyboard accessible elements
**WCAG**: 2.1.1 Keyboard
**Files**: 3 components

| File | Line | Issue | Fix |
|------|------|-------|-----|
| Menu.tsx | 45 | `<div onClick>` | Change to `<button>` |

### Important Issues (Level AA)

#### 3. Low color contrast
**WCAG**: 1.4.3 Contrast Minimum
**Ratio Required**: 4.5:1

| Selector | Current | Ratio | Fix |
|----------|---------|-------|-----|
| .muted-text | #999 on #fff | 2.85:1 | Use #595959 |

### Testing Commands

```bash
# Run automated checks
npx axe http://localhost:3000

# Add to tests
npm install --save-dev jest-axe @axe-core/react
```

### Manual Testing Checklist
- [ ] Navigate entire page with keyboard only
- [ ] Test with screen reader (VoiceOver/NVDA)
- [ ] Zoom to 200% and verify layout
- [ ] Test with high contrast mode
- [ ] Verify focus order is logical
```

## Enhancements

- Integrate with axe-core for automated testing
- Generate jest-axe test file
- Check color contrast programmatically
- Add keyboard navigation testing
- Generate VPAT documentation
- Test with multiple screen readers
- Create accessibility statement template
