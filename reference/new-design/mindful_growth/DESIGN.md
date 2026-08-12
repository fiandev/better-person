---
name: Mindful Growth
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
  secondary: '#2a6485'
  on-secondary: '#ffffff'
  secondary-container: '#a2d8ff'
  on-secondary-container: '#245f80'
  tertiary: '#634019'
  on-tertiary: '#ffffff'
  tertiary-container: '#7e572e'
  on-tertiary-container: '#ffd1a7'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#b1f0ce'
  primary-fixed-dim: '#95d4b3'
  on-primary-fixed: '#002114'
  on-primary-fixed-variant: '#0e5138'
  secondary-fixed: '#c7e7ff'
  secondary-fixed-dim: '#97cdf3'
  on-secondary-fixed: '#001e2e'
  on-secondary-fixed-variant: '#034c6c'
  tertiary-fixed: '#ffdcbd'
  tertiary-fixed-dim: '#f0bd8b'
  on-tertiary-fixed: '#2c1600'
  on-tertiary-fixed-variant: '#623f18'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
typography:
  headline-lg:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Manrope
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-padding-mobile: 1.25rem
  container-padding-desktop: 2.5rem
  stack-gap: 1rem
  section-gap: 2.5rem
---

## Brand & Style
The design system is built on a foundation of **Minimalism** infused with **Organic Modernism**. It aims to reduce cognitive load for users seeking clarity and discipline in their daily routines. The aesthetic is intentionally quiet, using ample whitespace and a restricted palette to create a "digital sanctuary" for habit formation.

The target audience consists of individuals seeking intentionality in their work, spiritual life, and interpersonal kindness. The UI evokes a sense of calm, stability, and progress through subtle transitions and soft visual cues rather than loud notifications. Every element is designed to feel grounded and essential, avoiding decorative clutter in favor of functional elegance.

## Colors
The palette utilizes nature-inspired tones to represent different life pillars:
- **Primary (Deep Forest Green):** Used for growth-oriented habits and successful completion states. It represents vitality and "Daily Habits."
- **Secondary (Steel Blue):** Dedicated to "Work Focus" and cognitive tasks. It provides a cooling, professional contrast.
- **Tertiary (Dusty Ochre):** A warm neutral used for "Religious Routines (Ibadah)" and "Daily Kindness (Kebaikan)," evoking a sense of human warmth and spiritual grounding.
- **Backgrounds:** A soft off-white (`#F8F9FA`) and a secondary "Sand" tint (`#FEFAE0`) are used to distinguish container layers without harsh borders.

## Typography
This design system utilizes **Manrope** for all levels. Its geometric yet slightly condensed nature feels modern and professional while remaining approachable. 

- **Headlines:** Set with tighter letter-spacing and heavier weights to provide clear structure to daily views.
- **Body Text:** Generous line-heights are employed to ensure readability during long-form reflection or focus sessions.
- **Labels:** Used for habit categories and metadata, often set in semi-bold for quick scanning.
- **Mobile Scaling:** Large headlines scale down significantly on mobile to prioritize vertical space for list items.

## Layout & Spacing
The layout follows a **Fixed Grid** model on desktop (centered 1200px max-width) and a fluid single-column model on mobile. 

- **Rhythm:** An 8px base unit governs all spacing.
- **White Space:** Intentional "breathing room" is placed between different habit categories (Work vs. Ibadah) to help the user mentally context-switch.
- **Margins:** 20px (1.25rem) side margins on mobile ensure content doesn't feel cramped against the bezel.
- **Grouping:** Use the `stack-gap` (16px) for items within a list and `section-gap` (40px) to separate the major pillars of the app.

## Elevation & Depth
The design system avoids heavy shadows, instead using **Tonal Layers** and **Soft Ambient Occlusion**.

- **Surface Levels:** The base background is the lowest level. Cards sit on a "Surface" layer which uses a white fill with an extremely subtle, wide-spread shadow (40px blur, 4% opacity).
- **Interactions:** When a habit is "checked," the card should physically feel like it settles into the background, achieved by removing the shadow and applying a slight inner-tint of the category color.
- **Overlays:** Modals and bottom sheets use a backdrop blur (12px) to maintain the sense of place while focusing on the specific task.

## Shapes
The shape language is consistently **Rounded**, reflecting the "soft" and "mindful" brand personality. 

- **Standard Elements:** Buttons, input fields, and cards use a 0.5rem (8px) radius.
- **Progress Indicators:** Circular rings and pill-shaped progress bars are used to visualize completion.
- **Iconography:** Icons should be drawn with rounded caps and corners to match the UI's softness. Avoid sharp 90-degree angles.

## Components
- **Habit Cards:** High-contrast white containers. The left border or a small corner indicator should use the category color (Green for Growth, Blue for Work, Ochre for Kindness).
- **Interactive Checkbox:** Large, custom-styled circles. Upon selection, they should fill with the primary color and trigger a subtle haptic-like scale animation.
- **Focus Timer:** A minimal, large-scale typography display of time, surrounded by a thin, secondary-colored circular progress ring.
- **Chips:** Used for "Mood Tags" or "Reflection Categories." These use a low-opacity fill of the primary color with matching text.
- **Buttons:** Primary buttons are solid green; secondary buttons are outlined with 1px borders. Text inside buttons is always semi-bold for legibility.
- **Daily Progress Bar:** A thin, persistent bar at the top of the interface that fills as the total "Habit Score" increases for the day.