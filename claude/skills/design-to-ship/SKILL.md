---
name: design-to-ship
description: End-to-end workflow for building products that look premium and ship fast. Combines design thinking, AI-assisted building, and deployment. Use when user says "build this product", "design and ship", "full product", "build and deploy", "ship this", or when starting a new product from concept to deployment.
---

# Design to Ship

## Philosophy

The goal is not to become a designer OR a developer. The goal is to think in design, build with AI, and ship products that feel right. Design and code are one discipline when you're building products.

## Process

### Phase 1: Define Before Designing

Before any code or design:

1. **State the outcome in one sentence.** What does the user accomplish with this product?
2. **Identify the core interaction.** What is the ONE thing the user does most? That interaction must be flawless.
3. **Set constraints.** Platform, audience, timeline, tech stack. Constraints drive better design.
4. **List what you will NOT build.** Scope control prevents feature creep.

Output: A brief (5-10 lines) that locks scope.

### Phase 2: Design in Code

Skip Figma for initial exploration. Build directly in code. It's faster to iterate on a working prototype than a static mockup.

**Design decisions to make upfront:**
- Typography: Pick one font family. Two maximum (one display, one body).
- Color: One accent color. Neutral base. Maximum 5 total colors.
- Spacing: Pick a base unit (4px or 8px). Everything is a multiple.
- Border radius: Pick one value for containers, one for buttons. Stick to them.
- Shadows: Tinted to background hue. Consistent light direction.

**Build order for maximum design impact:**
1. Typography and color first (biggest visual improvement, lowest effort)
2. Layout and spacing second (structure creates professionalism)
3. Interactions and states third (loading, empty, error, hover, active)
4. Polish and motion last (spring physics, stagger reveals, micro-interactions)

### Phase 3: Build the Core Loop

Implement the core interaction first. Not the landing page. Not the settings. The thing the user came to do.

- Build it as a standalone component
- Make it work perfectly on one screen size first, then responsive
- Add loading, empty, and error states immediately (not later)
- Test with realistic data (no "John Doe", no `$99.99`, no "Lorem ipsum")

### Phase 4: Wrap with Navigation and Context

Once the core works:

1. Add navigation that shows where the user is
2. Add entry points (onboarding, login, landing)
3. Add exit points (success states, confirmations, next steps)
4. Connect pages with smooth transitions, not hard cuts

### Phase 5: Polish Pass

Apply the anti-generic checklist:

**Typography:**
- [ ] No Inter font (use Geist, Outfit, Satoshi, Cabinet Grotesk)
- [ ] Headlines use tight letter-spacing and heavier weight
- [ ] Body text limited to ~65 characters width
- [ ] Numbers use tabular figures or monospace

**Color:**
- [ ] No pure black (#000000) — use off-black or tinted dark
- [ ] No AI purple/blue gradient aesthetic
- [ ] Saturation below 80% on accent colors
- [ ] Consistent warm OR cool gray family, not mixed

**Layout:**
- [ ] No generic 3-card centered feature row
- [ ] Container has max-width (1200-1440px)
- [ ] Full-height sections use min-h-[100dvh] not h-screen
- [ ] Asymmetric or offset layouts where appropriate

**Content:**
- [ ] No generic placeholder names or data
- [ ] No AI copywriting cliches (Elevate, Seamless, Unleash, Next-Gen)
- [ ] No Lorem Ipsum — write real draft copy
- [ ] Sentence case for headers, not Title Case On Every Word

**States:**
- [ ] Loading states with skeleton loaders (no spinners)
- [ ] Empty states that guide the user
- [ ] Error states with clear, actionable messages
- [ ] Hover and active states on all interactive elements

### Phase 6: Ship

Deployment checklist:

1. **Build verification:** `npm run build` (or equivalent) passes with zero errors
2. **Meta tags:** Title, description, og:image, favicon
3. **Performance:** Images optimized, fonts preloaded, no layout shift
4. **Accessibility:** Semantic HTML, focus indicators, alt text, skip-to-content link
5. **Deploy:** Push to Vercel, Netlify, or equivalent. Get a live URL.
6. **Verify:** Test the live URL on mobile and desktop. Both must work.

## Speed vs Quality Tradeoffs

- **Prototype (1-2 hours):** Skip polish pass. Ship the core loop with basic styling. Good for validation.
- **MVP (1-2 days):** Full process but lighter polish. Ship with core features only.
- **Production (1+ week):** Full process with comprehensive polish, edge cases, and testing.

Choose the right level. Over-polishing a prototype wastes time. Under-polishing production loses trust.

## Rules

- Always start from the core interaction, never the landing page
- Design decisions are made in code, not in conversation
- Every screen needs loading, empty, and error states from the start
- Ship to a live URL — local demos don't count
- Test on mobile before calling it done
- Use realistic data throughout — never placeholder garbage
