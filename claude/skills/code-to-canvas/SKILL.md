---
name: code-to-canvas
description: Bidirectional design-to-code workflow using Figma MCP. Build UI in Claude Code and send to Figma as editable layers, or pull Figma designs back into code. Use when user says "send to Figma", "code to canvas", "Figma MCP", "design to code", "push to Figma", or "sync with Figma".
---

# Code to Canvas

## What This Does

Build working UI in Claude Code, then send it to Figma as fully editable frames with real layers. Or pull Figma designs back into code. The workflow is bidirectional.

What arrives in Figma is NOT a screenshot. It is a real frame with selectable elements, adjustable colors, spacing, and typography. It behaves like something built natively in Figma.

## Prerequisites

The Figma MCP server must be connected. Verify by checking MCP status. If not connected:

```
claude mcp add --transport http figma-remote-mcp https://mcp.figma.com/mcp
```

Restart Claude Code after adding. Use `/mcp` to verify connection status.

## Code to Figma Flow

### Step 1: Build the UI

Generate working HTML and CSS based on user description. Be specific — vague prompts produce vague results.

**Good prompt patterns the user should provide:**
- "Build a SaaS analytics dashboard. Sidebar on left with navigation, top bar with user avatar, main area with 3 metric cards and a line chart below. White background, neutral gray text. Minimal."
- "Build a pricing card with plan name, monthly price, list of 4 features, and CTA button. Rounded corners, white background, subtle border."

**Bad prompt patterns to redirect:**
- "Build a dashboard" — too vague, ask for specifics
- "Make it look nice" — ask for design direction, reference, or mood

### Step 2: Render and Verify

Open the generated UI in browser. Verify it looks correct before sending to Figma. Fix any issues in code first — it's faster to iterate in code than in Figma.

### Step 3: Send to Figma

Use the Figma MCP to push the rendered browser state into Figma as editable layers. The MCP translates HTML/CSS structure into Figma frame hierarchy.

Key points:
- Each HTML element becomes a Figma layer
- CSS properties map to Figma fills, strokes, effects
- Layout structure is preserved as auto-layout frames
- Text remains editable

### Step 4: Refine in Figma (User's Step)

The user can now edit in Figma:
- Adjust colors, spacing, typography
- Rearrange elements
- Add design system components
- Share with team for feedback

## Figma to Code Flow

### Step 1: Get Design Reference

User shares a Figma file or frame via MCP. Read the design using Figma MCP tools to extract:
- Layout structure and hierarchy
- Colors and typography
- Spacing and sizing
- Component patterns

### Step 2: Translate to Code

Convert the Figma design into working code matching the project's stack:
- Use the project's existing framework (React, Next.js, Vue, etc.)
- Use the project's existing styling system (Tailwind, CSS Modules, etc.)
- Match the project's component patterns and naming conventions

### Step 3: Verify Fidelity

Compare the rendered code output against the original Figma design:
- Layout matches
- Colors are accurate (check hex values, not "close enough")
- Typography matches (font, size, weight, line-height, letter-spacing)
- Spacing is consistent with the design

## Maximizing Quality

### Specificity Wins

The more context in the prompt, the less Claude has to guess. Tell Claude:
- Border radius values ("use 8px border radius")
- Color tokens ("neutral gray 100 for card backgrounds")
- Font choices ("use Geist for body, Geist Mono for code")
- Spacing system ("8px base unit")

### Best Use Cases

1. **Early exploration** — describe an interface in plain language, get something concrete to react to. Faster than starting from a blank Figma frame.
2. **Quick iteration** — test a different layout or interaction pattern. Build a variation in code, send to Figma, compare side by side.
3. **Communication** — show a working UI reference instead of describing it. Generate in Claude Code, bring into Figma, share with team.

### Limitations

- Works best on isolated screens or components
- Complex multi-screen flows with transitions produce static frames, not prototypes
- Custom design system components with specific tokens/variants may not match perfectly on first pass — include conventions in the prompt
- Highly interactive components (drag-and-drop, complex animations) render as their static state

## Error Handling

### Figma MCP Not Connected
1. Run `/mcp` to check status
2. If disconnected, click Enter to log in
3. Click "Allow access" when prompted
4. Run `/mcp` again to confirm connection

### Design Doesn't Match Code
- Compare computed CSS values against Figma properties
- Check if Figma design uses auto-layout (maps cleanly to flexbox/grid)
- Check if fonts are available in both environments
- Verify responsive breakpoints match the target viewport

### Layers Not Editable in Figma
- Ensure HTML uses semantic, separable elements (not a single SVG blob)
- Use individual divs/sections for each design element
- Avoid CSS-generated content that won't translate to Figma layers
