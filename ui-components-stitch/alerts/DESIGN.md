# Design System Specification: Intelligence & Oversight

## 1. Overview & Creative North Star: "The Digital Sentinel"
The Creative North Star for this design system is **The Digital Sentinel**. 

We are moving away from the "friendly SaaS" aesthetic. This system is designed for high-stakes decision-making where information density is a feature, not a bug. It avoids the "template" look by utilizing a monochromatic, structural base that allows critical data points to emerge with surgical precision. 

The experience is built on **Intentional Asymmetry** and **Tonal Depth**. We prioritize a "heads-up display" (HUD) feel—sophisticated, authoritative, and whisper-quiet—until a crisis occurs. By using extreme typographic scales (pairing massive displays with micro-labels), we create an editorial rhythm that guides the eye through complex global intelligence without the need for clunky boxes or dividers.

---

## 2. Colors & Surface Logic
The palette is rooted in a "Void-Black" philosophy. We use the deep charcoal base to minimize ocular strain during long monitoring sessions.

### Surface Hierarchy & The "No-Line" Rule
**Explicit Instruction:** Do not use 1px solid borders to define sections. All containment must be achieved through background shifts or spacing.
- **Base Layer:** Use `surface` (#0e0e0e) for the primary application background.
- **Nesting:** Place a `surface-container-low` (#131313) for secondary regions.
- **Emphasis:** Use `surface-container-high` (#1f2020) for interactive elements or high-priority data cards.
- **The "Glass & Gradient" Rule:** For floating panels or modal overlays, use `surface-container-highest` with a 70% opacity and a `24px` backdrop-blur. Apply a subtle linear gradient from `primary-container` to `surface` at a 45-degree angle to give main CTAs a "machined metal" luster.

### Functional Accents
- **Crisis/Risk:** Use `tertiary` (#ff7162) and `tertiary-container` (#f9362c) for critical alerts.
- **Positive/Stability:** Use `secondary` (#17b64a) for growth and stability metrics.
- **System Neutral:** Use `primary` (#c6c6c7) for structural UI and `on-surface-variant` (#acabaa) for metadata.

---

## 3. Typography: Editorial Authority
We utilize two typefaces: **Inter** for data integrity and **Space Grotesk** for technical labeling.

- **Display (Inter):** Used for "Big Number" metrics. `display-lg` (3.5rem) should be used for global risk scores to provide an immediate, undeniable focal point.
- **Headlines (Inter):** `headline-sm` (1.5rem) uses semi-bold weights to anchor news feeds.
- **Labels (Space Grotesk):** `label-md` and `label-sm` are the "workhorses." Use these for micro-charts, coordinates, and timestamps. Space Grotesk’s tabular qualities lend a "terminal" feel that reinforces the platform's intelligence-grade nature.
- **Hierarchy through Contrast:** Pair a `display-sm` value with a `label-sm` immediately below it. This high-contrast pairing eliminates the need for "Section Title" headers.

---

## 4. Elevation & Depth: Tonal Layering
Traditional shadows have no place here. Depth is achieved through light, not shadow.

- **The Layering Principle:** To "lift" a card, shift the color from `surface-container` to `surface-bright`.
- **Ambient Glow:** If a floating element requires a shadow, use a `10%` opacity of `primary-dim` with a `40px` blur. It should feel like a soft glow from the screen rather than a drop shadow.
- **The "Ghost Border":** For high-density data tables where boundaries are strictly required for legibility, use `outline-variant` (#484848) at **15% opacity**. It should be felt, not seen.
- **Interaction:** On hover or tap, an element should transition from `surface-container-low` to `surface-container-highest` to provide tactile feedback without changing the layout geometry.

---

## 5. Components & Data Density

### Cards & Intelligence Modules
- **Rule:** No borders. No dividers.
- **Structure:** Use `surface-container-low` for the card body. Use `4 (0.9rem)` internal padding. 
- **Separation:** Content blocks within a card are separated by `2 (0.4rem)` or `3 (0.6rem)` of vertical whitespace.

### Global Risk Indicators (Pills)
- **Status:** Use `full` roundedness. 
- **Styling:** Small-scale (`label-sm`). For a "Crisis" state, use a `tertiary-container` background with `on-tertiary-container` text. Apply a subtle pulse animation to the background opacity (100% to 70%) for active crises.

### Buttons
- **Primary:** `primary` background with `on-primary` text. Radius: `md (0.375rem)`.
- **Secondary:** `outline` ghost style with `primary` text.
- **Tactile feedback:** All buttons use a 0.2s ease-in-out transition on background-color.

### High-Density Micro-Charts
- **Sparklines:** Stroke width of `1.5px`. Use `secondary` for upward trends and `tertiary` for downward. 
- **The Grid:** Background grid lines in micro-charts must use `outline-variant` at 5% opacity.

### Global Map Interface
- **Base:** Monochromatic dark map. Landmasses in `surface-container-high`, water in `surface`.
- **Hotspots:** Use `tertiary` glows to indicate conflict or risk zones. Use `backdrop-blur` on labels over the map to ensure legibility without obscuring geographic data.

---

## 6. Do’s and Don’ts

### Do
- **Do** embrace "White Space as a Divider." Use the spacing scale (`8`, `12`, `16`) to create distinct content groupings.
- **Do** use `tabular-nums` in CSS for all data points to prevent "jumping" text during real-time updates.
- **Do** use `surface-bright` for active states in navigation to create a "lit from within" effect.

### Don’t
- **Don’t** use pure `#000000` except for the `surface-container-lowest` in extreme high-contrast needs. It kills the depth of the charcoal base.
- **Don’t** use rounded corners larger than `xl (0.75rem)`. This platform is a tool, not a toy; keep the geometry sharp and professional.
- **Don’t** use standard "Warning" icons. Use typographic indicators (e.g., [!] or [VULN]) in `Space Grotesk` to maintain the terminal aesthetic.

### Accessibility Note
While we prioritize high-density and dark modes, ensure that all `on-surface` and `on-background` text maintains a contrast ratio of at least 4.5:1 against their respective containers. Use `primary-fixed` for any critical text that must remain legible regardless of surface shifts.