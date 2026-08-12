---
name: Mindful Growth Finance
colors:
  surface: '#f8f9fa'
  surface-dim: '#d9dadb'
  surface-bright: '#f8f9fa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f5'
  surface-container: '#edeeef'
  surface-container-high: '#e7e8e9'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#404943'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f2'
  outline: '#707973'
  outline-variant: '#bfc9c1'
  surface-tint: '#2c694e'
  primary: '#0f5238'
  on-primary: '#ffffff'
  primary-container: '#2d6a4f'
  on-primary-container: '#a8e7c5'
  inverse-primary: '#95d4b3'
  secondary: '#3e6750'
  on-secondary: '#ffffff'
  secondary-container: '#bdeacd'
  on-secondary-container: '#426b54'
  tertiary: '#274f3d'
  on-tertiary: '#ffffff'
  tertiary-container: '#3f6754'
  on-tertiary-container: '#b8e3cb'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#b1f0ce'
  primary-fixed-dim: '#95d4b3'
  on-primary-fixed: '#002114'
  on-primary-fixed-variant: '#0e5138'
  secondary-fixed: '#c0edd0'
  secondary-fixed-dim: '#a4d1b4'
  on-secondary-fixed: '#002112'
  on-secondary-fixed-variant: '#264f39'
  tertiary-fixed: '#c1ecd4'
  tertiary-fixed-dim: '#a5d0b9'
  on-tertiary-fixed: '#002114'
  on-tertiary-fixed-variant: '#274e3d'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
typography:
  display-currency:
    fontFamily: Manrope
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-md:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Work Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Work Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-data:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.05em
  headline-lg-mobile:
    fontFamily: Manrope
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  container-padding-mobile: 16px
  container-padding-desktop: 32px
  gutter: 24px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style
The design system evolves into the financial space by balancing fiscal responsibility with emotional well-being. The brand personality is calm, intentional, and nurturing, moving away from the high-stress, "hustle-culture" aesthetics of traditional fintech. 

The style utilizes **Minimalism** with a **Tactile** twist. Heavy whitespace and a limited palette ensure clarity, while soft shadows and subtle depth on interactive elements make the interface feel grounded and reliable. The goal is to reduce cognitive load during financial decision-making, evoking a sense of "financial breathing room."

## Colors
The palette is anchored by the primary green (`#2d6a4f`), representing growth and stability. To support financial patterns, we introduce specific semantic tokens:

- **Income (Emerald):** Used for deposits, positive balances, and growth trends. It is brighter than the primary brand green to signal a "gain" state.
- **Expense (Rose):** A soft but clear red used for withdrawals, negative trends, and warnings. It is chosen to be legible against light surfaces without inducing panic.
- **Neutral/Surface:** We use a high-brightness off-white for backgrounds to keep the UI feeling airy and "soft."

## Typography
The typography system prioritizes legibility of numerical data. 

- **Manrope** is used for headlines and currency displays to provide a modern, refined look. 
- **Work Sans** handles body copy and transactional descriptions, providing a grounded and professional feel. 
- **JetBrains Mono** is utilized for transaction timestamps, account numbers, and data labels to ensure tabular alignment and a technical, precise character.

## Layout & Spacing
The design system employs a **Fluid Grid** model. On mobile, we use a 4-column layout; on desktop, a 12-column layout with a maximum content width of 1200px.

Spacing follows a 4px base unit. Vertical rhythm in financial lists (transactions) should use the `stack-sm` (8px) spacing between items to maintain high information density while preserving clarity. Wallet cards should have `stack-lg` (32px) margins to emphasize their importance as the primary dashboard anchor.

## Elevation & Depth
Depth is conveyed through **Tonal Layers** and **Ambient Shadows**. 

- **Base Level (Level 0):** The primary background (`#f8f9fa`).
- **Surface Level (Level 1):** Interactive cards and input containers use a pure white background with a very soft, diffused shadow (Blur: 12px, Opacity: 4%, Color: `#1b4332`).
- **Elevated Level (Level 2):** Hover states and active modals increase shadow spread and slightly tint the shadow with the primary green to suggest the element is "growing" toward the user.

## Shapes
We use a **Rounded** shape language to reinforce the "Mindful" brand. Standard UI components like buttons and inputs use a 0.5rem (8px) radius. Larger containers, specifically "Wallet Cards," use the `rounded-xl` (1.5rem / 24px) setting to create a friendly, distinct appearance that stands out from standard utility blocks.

## Components

### Wallet Cards
Wallet cards are the centerpiece of the financial system. They must use the `rounded-xl` radius and a subtle gradient background (Primary Green to Tertiary Green). Text on these cards should be high-contrast white. Include a "Label-Data" element for the last four digits of the account number.

### Category Selector
A hybrid component combining a dropdown with an integrated search bar. 
- **Inactive:** Displays the current category icon and name.
- **Active:** Opens a search field at the top. 
- **Empty State:** If a search yields no results, a "Create New [Search Term]" button appears at the bottom of the list, styled with a dashed border and the `primary_color_hex`.

### Buttons
- **Primary:** Solid `#2d6a4f` with white text.
- **Secondary:** Ghost style with `#2d6a4f` borders.
- **Actionable Icons:** Used for "Quick Add" transactions, these should be circular (pill-shaped) with an elevation of Level 2.

### Transaction Lists
Use a horizontal layout with a 40px circular icon on the left (using the semantic Income/Expense colors as a light background tint), the description in "Body-MD," and the amount on the right in "Label-Data."