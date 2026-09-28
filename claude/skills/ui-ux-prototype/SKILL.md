---
name: ui-ux-prototype
description: Generates UI component code with accessibility specs and responsive design
triggers:
  - /ui-ux-prototype
  - /ui-prototype
  - /component
---

# Instructions

When this skill is invoked, generate production-ready UI component code with proper accessibility and responsive design.

## Process

1. **Understand Requirements**:
   - Component type (form, modal, card, navigation, etc.)
   - Framework (React, Vue, Svelte, vanilla HTML/CSS)
   - Styling approach (Tailwind, CSS Modules, styled-components, plain CSS)
   - Interactive behaviors needed

2. **Analyze Existing UI Patterns**:
   - Use Glob to find existing components
   - Read similar components to match project style
   - Identify design system or component library in use
   - Note naming conventions and file structure

3. **Design Component Architecture**:

   **Component Structure**:
   ```
   ComponentName/
   ├── ComponentName.tsx       # Main component
   ├── ComponentName.test.tsx  # Tests
   ├── ComponentName.styles.ts # Styles (if separated)
   ├── ComponentName.types.ts  # TypeScript types
   └── index.ts                # Export barrel
   ```

4. **Generate Component Code**:

   **Accessibility Requirements (WCAG 2.1)**:
   - Semantic HTML elements
   - ARIA labels and roles where needed
   - Keyboard navigation support
   - Focus management
   - Color contrast compliance
   - Screen reader announcements

   **Responsive Design**:
   - Mobile-first breakpoints
   - Flexible layouts (flexbox/grid)
   - Touch-friendly tap targets (44x44px minimum)
   - Responsive typography

   **Example React Component**:
   ```tsx
   interface ButtonProps {
     variant?: 'primary' | 'secondary' | 'ghost';
     size?: 'sm' | 'md' | 'lg';
     isLoading?: boolean;
     children: React.ReactNode;
     onClick?: () => void;
   }

   export const Button: React.FC<ButtonProps> = ({
     variant = 'primary',
     size = 'md',
     isLoading = false,
     children,
     onClick,
     ...props
   }) => {
     return (
       <button
         className={cn(styles.button, styles[variant], styles[size])}
         onClick={onClick}
         disabled={isLoading}
         aria-busy={isLoading}
         {...props}
       >
         {isLoading ? <Spinner aria-hidden="true" /> : null}
         <span className={isLoading ? styles.hidden : undefined}>
           {children}
         </span>
       </button>
     );
   };
   ```

5. **Generate Companion Files**:
   - TypeScript types/interfaces
   - Unit tests with React Testing Library
   - Storybook stories (if project uses Storybook)
   - CSS/style definitions

## Output Format

```markdown
## Component: [Name]

### Files Generated
- `components/[Name]/[Name].tsx`
- `components/[Name]/[Name].test.tsx`
- `components/[Name]/[Name].module.css`

### Accessibility Checklist
- [x] Semantic HTML
- [x] ARIA labels
- [x] Keyboard navigation
- [x] Focus visible states
- [x] Color contrast (AA compliant)

### Usage Example
[Code example]

### Props API
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| ... | ... | ... | ... |
```

## Enhancements

- Generate Storybook stories automatically
- Include dark mode variants
- Add animation/transition states
- Generate CSS custom properties for theming
- Create compound component patterns for complex UIs
- Include loading/error/empty states
- Add RTL (right-to-left) support considerations
