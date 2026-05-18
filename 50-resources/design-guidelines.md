# Design Guidelines

Last updated: 2026-05-18

---

## Typography

**Font:** Inter

**Letter spacing:** `-0.31px` across the board

---

## Background

**Two surfaces approach:**
- Primary surface: `#FFFFFF` (pure white)
- Secondary surface: `#FCFCFC` (off-white, subtle contrast)

This creates depth and hierarchy without heavy borders or shadows.

---

## Colors

**Palette:** TailwindCSS Neutral

- **Muted text:** Neutral-500 (`#737373`)
- **Emphasized text:** Neutral-800 (`#262626`)
- **Primary text:** Neutral-900 (`#171717`)

**Full Tailwind Neutral scale reference:**
- 50: `#fafafa`
- 100: `#f5f5f5`
- 200: `#e5e5e5`
- 300: `#d4d4d4`
- 400: `#a3a3a3`
- 500: `#737373` ← muted text
- 600: `#525252`
- 700: `#404040`
- 800: `#262626` ← emphasized text
- 900: `#171717`
- 950: `#0a0a0a`

---

## Icons

**Source:** @huge_icons

---

## Usage Examples

### Card Component
```css
.card {
  background: #FFFFFF;
  border: 1px solid #e5e5e5; /* Neutral-200 */
  border-radius: 8px;
  padding: 24px;
}

.card-title {
  color: #262626; /* Neutral-800 */
  font-weight: 600;
  letter-spacing: -0.31px;
}

.card-description {
  color: #737373; /* Neutral-500 */
  letter-spacing: -0.31px;
}
```

### Two-Surface Layout
```css
body {
  background: #FCFCFC; /* Secondary surface */
}

.content-area {
  background: #FFFFFF; /* Primary surface */
  /* Content sits on white cards against the #FCFCFC body */
}
```

---

## Rationale

**Why `-0.31px` letter spacing?**
Inter is designed with slightly wider default tracking. The negative letter spacing tightens it for a more premium, editorial feel.

**Why two background surfaces?**
Using `#FFFFFF` and `#FCFCFC` creates subtle depth without heavy shadows or borders. The 2-step difference (252 vs 255 in RGB) is barely perceptible but adds sophistication.

**Why Tailwind Neutral over Stone/Slate/Gray?**
- Neutral is true gray (no warm/cool bias)
- Works with any brand color
- Stone (`#fafaf9`) is warmer - good for Catone emails but too warm for generic UI

---

## Related

- Catone brand uses Stone palette (`#fafaf9`, `#1c1917`) for warmer, more personal feel
- Milano presentation uses dark theme (`#0a0e27`) with neon accents
- For general UI/products, stick to Neutral with `#FFFFFF`/`#FCFCFC` surfaces
