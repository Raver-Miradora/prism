# Design System Specification: The Authoritative Canvas

## 1. Overview & Creative North Star
### Creative North Star: "The Digital Registry"
This design system rejects the "standard government portal" aesthetic in favor of a high-end editorial experience. It is built on the principle of **The Digital Registry**: a space that feels as authoritative as a heavy linen document and as precise as a modern architectural blueprint.

We move beyond a "template" look by utilizing **Intentional Asymmetry**. Instead of centering everything in rigid blocks, we use the spacing scale to create wide, breathable margins on one side and dense, information-rich clusters on the other. By layering surfaces rather than drawing lines, we create a UI that feels "carved" out of light and shadow, evoking a sense of permanence, trust, and modern governance.

---

## 2. Color Theory & Surface Logic
The palette is rooted in deep institutional tones, but its application is purely contemporary.

### The "No-Line" Rule
**Explicit Instruction:** You are prohibited from using 1px solid borders to section off content. In this system, boundaries are defined by **Background Color Shifts**. 
- To separate a sidebar from a main feed, use `surface-container-low` (#f3f4f5) against the `background` (#f8f9fa).
- To highlight a specific data point, use a `surface-container-highest` (#e1e3e4) "island" inside a lower-tier container.

### Surface Hierarchy & Nesting
Treat the UI as a physical stack of fine stationery.
*   **Base:** `surface` (#f8f9fa) – The desk.
*   **Primary Container:** `surface-container-low` (#f3f4f5) – The folder.
*   **Interactive Element:** `surface-container-lowest` (#ffffff) – The active document.

### The "Glass & Gradient" Rule
To prevent the navy blue (`primary`) from feeling "flat" or "dated," use a subtle **Directional Glow**.
- **Signature CTA Gradient:** Linear (135deg) from `primary` (#00003c) to `primary_container` (#000080). This provides a "ink-on-silk" sheen that feels premium.
- **Glassmorphism:** For floating navigation or modals, use `surface` at 85% opacity with a `backdrop-blur` of 12px. This ensures the government aesthetic remains "airy" and not bureaucratic.

---

## 3. Typography: The Editorial Voice
We use a dual-sans serif approach to balance institutional authority with modern readability.

*   **Display & Headlines (Public Sans):** Chosen for its geometric stability. Use `display-lg` (3.5rem) with tight letter-spacing (-0.02em) for high-impact landing moments. Headlines should feel like newspaper headers—bold, black, and immovable.
*   **Body & Labels (Inter):** The workhorse. Inter’s high x-height ensures that complex government data remains legible at `body-sm` (0.75rem).
*   **Hierarchy Tip:** Always pair a `headline-sm` in `primary` color with a `label-md` in `on_surface_variant` (#464653) to create an "Editorial Subtitle" effect.

---

## 4. Elevation & Depth
We convey importance through **Tonal Layering**, not structural scaffolding.

### The Layering Principle
Avoid "drop shadows" for standard cards. Instead, place a `surface_container_lowest` card on a `surface_container` background. The slight shift in hex code creates a "soft lift" that is easier on the eyes and feels more integrated.

### Ambient Shadows
When an element must float (e.g., a "Clock-In" FAB), use an **Ambient Glow**:
- **Color:** A tinted version of `on_surface` (e.g., #191C1D at 6% opacity).
- **Spread:** Large blur (20px - 40px), 0px spread, and a 4px Y-offset. It should look like a soft shadow cast by an overhead gallery light.

### The "Ghost Border" Fallback
If accessibility requirements demand a container edge, use the **Ghost Border**:
- **Token:** `outline_variant` (#c6c5d5) at **15% opacity**. It should be felt, not seen.

---

## 5. Components & Primitive Styling

### Buttons (The "Seal")
- **Primary:** Gradient fill (Navy Primary to Primary Container), `sm` (0.25rem) or `md` (0.75rem) roundedness. No border.
- **Secondary:** `surface_container_highest` fill with `on_surface` text.
- **Success (Clock-In):** Use `tertiary_fixed_dim` (#66dd8b) for the background to signify "Active/Go" status without the harshness of a pure neon green.

### Inputs (The "Form")
- **Default State:** Use `surface_container_high` (#e7e8e9) with a 2px bottom-weighted "Ghost Border."
- **Focus State:** Transition the bottom border to `primary` (#00003c) and slightly lighten the internal fill.
- **Error:** Use `error` (#ba1a1a) text but keep the container fill soft (`error_container` at 50% opacity).

### Cards & Lists (The "Ledger")
- **Rule:** Absolute prohibition of horizontal dividers. 
- **Execution:** Use **Negative Space**. Separate list items using `spacing-4` (1rem). If items must be grouped, use a subtle background shift (alternating `surface` and `surface_container_low`).

---

## 6. Do’s and Don’ts

| Do | Don't |
| :--- | :--- |
| Use `surface_container` tiers to create hierarchy. | Use 1px black or grey borders to separate sections. |
| Use `Public Sans` for bold, authoritative titles. | Use "System Default" fonts for high-level headlines. |
| Apply `full` (9999px) roundedness for Chips and Badges. | Use sharp 90-degree corners for interactive buttons. |
| Use `8.0 (2rem)` spacing to let data breathe. | Cram data tables into tight, border-heavy grids. |
| Use `Ambient Shadows` (low opacity, high blur). | Use "Standard" MD3 shadows with high-opacity blacks. |

## 7. Signature Interaction: The "Institutional Slide"
When transitioning between views (e.g., from a dashboard to a detailed report), do not use a "Fade." Instead, use a **Staggered Slide**:
1. The `surface` background remains static.
2. The `headline` slides in from the left (40px offset).
3. The content cards slide in from the bottom (20px offset) with a 100ms delay between each. 
*This reinforces the "Digital Registry" metaphor—as if a librarian is laying out documents on a desk for the user.*