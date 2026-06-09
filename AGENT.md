# Better Person - Flutter Widget Showcase & HabitFocus App

## Project Overview

This is a **Flutter web application** that serves two purposes:

1. **Widget Showcase** - A collection of 164+ standalone demo widgets organized by category, rendered via URL-based routing.
2. **HabitFocus App** - A habit tracking application built using the "Mindful Growth" design system, with reference HTML mockups in the `reference/` folder.

**SDK:** Flutter ^3.8.0  
**Package name:** `core`  
**Platform:** Web (Chrome)

## Directory Structure

```
better-person/
├── lib/                          # Flutter source code
│   ├── main.dart                 # App entry point with route map
│   ├── animation/                # Animation demos (hero, shimmer, stagger, etc.)
│   ├── calendar/                 # Calendar widgets (month view, booking slots)
│   ├── chat/                     # Chat UI demos
│   ├── communication/            # Video/voice call screens
│   ├── core/                     # Basic widgets (buttons, loading, toasts)
│   ├── dashboard/                # Admin dashboards, KPIs, charts
│   ├── ecommerce/                # E-commerce flows (cart, checkout, products)
│   ├── education/                # Learning screens (courses, quizzes)
│   ├── finance/                  # Finance widgets (wallet, transactions)
│   ├── food/                     # Restaurant and food delivery UIs
│   ├── forms/                    # Form variants (sign-in, sign-up, OTP, etc.)
│   ├── gallery/                  # Image galleries and viewers
│   ├── health/                   # Fitness and health trackers
│   ├── info/                     # Info pages (about, FAQ, team)
│   ├── layouts/                  # Layout patterns (masonry, sliver, split)
│   ├── media/                    # Media players (music, video, podcast)
│   ├── must_haves/               # Common app pages (onboarding, settings, profile)
│   ├── navigation/               # Navigation patterns (bottom nav, rail)
│   ├── notifications/            # Notification UIs
│   ├── overlays/                 # Bottom sheets, dialogs, snackbars
│   ├── pricing/                  # Pricing cards and paywalls
│   ├── profile/                  # Profile and account settings
│   ├── search/                   # Search UIs
│   ├── social/                   # Social media widgets
│   ├── states/                   # Empty states, errors, splash
│   ├── travel/                   # Travel booking UIs
│   ├── utilities/                # Utility apps (calculator, weather, notes)
│   └── habit_focus/              # [NEW] HabitFocus habit tracking app
│       ├── theme/                # Mindful Growth theme data
│       ├── widgets/              # Shared reusable widgets
│       └── screens/              # Individual HabitFocus screens
├── reference/                    # HTML mockups for HabitFocus
│   ├── mindful_growth/DESIGN.md  # Design system specification
│   ├── beranda_habitfocus/       # Home/dashboard page mockup
│   ├── fokus_kerja/              # Work focus timer page mockup
│   ├── rutinitas_ibadah/         # Religious routine page mockup
│   ├── rutinitas_spiritual/      # Spiritual routine page mockup
│   ├── catatan_kebaikan/         # Daily kindness notes page mockup
│   └── statistik_mingguan/       # Weekly statistics page mockup
├── web/                          # Flutter web entrypoint (index.html)
├── pubspec.yaml                  # Project manifest and dependencies
└── analysis_options.yaml         # Dart analyzer configuration
```

## Routing Mechanism

The app uses **URL query parameters** for routing. There is no Flutter Navigator-based routing.

### How it works

1. `lib/main.dart` defines a `routes` map: `Map<String, Widget Function()>`
2. Keys are path strings like `"/category/widget_name"`
3. The app reads the path from `Uri.base.queryParameters["path"]`
4. It looks up the matching builder function and renders the widget
5. If no match is found, a "No page found" placeholder is shown

### URL format

```
http://localhost:PORT/?path=/category/widget_name
http://localhost:PORT/?path=/animation/hero_list_view&theme=dark
```

The optional `theme=dark` parameter switches to `ThemeData.dark()`.

### Example route entry

```dart
"/health/fitness_dashboard": () => const FitnessDashboard(),
```

## How to Add New Widgets/Pages

1. **Create the widget file** in the appropriate category folder under `lib/`.
   - Each file exports a single top-level widget (StatelessWidget or StatefulWidget).
   - Use `const` constructors with `super.key`.
   - Private helper widgets use underscore prefix naming (`_HelperWidget`).

2. **Import it in `lib/main.dart`** at the top of the file.

3. **Register the route** in the `routes` map:
   ```dart
   "/category/widget_name": () => const MyWidget(),
   ```

4. **Access it** at: `?path=/category/widget_name`

## HabitFocus App

HabitFocus is a mindful habit tracking application being built inside this widget showcase. It helps users track daily habits across three life pillars:

- **Growth (Daily Habits)** - represented by Primary (deep green)
- **Work Focus** - represented by Secondary (steel blue)
- **Kindness & Spirituality** - represented by Tertiary (ochre)

### Pages (from reference mockups)

| Page | Reference Folder | Route Path | Description |
|------|-----------------|------------|-------------|
| Beranda (Home) | `reference/beranda_habitfocus/` | `/habit_focus/beranda` | Main dashboard with daily habit overview |
| Fokus Kerja | `reference/fokus_kerja/` | `/habit_focus/fokus_kerja` | Work focus timer with circular progress |
| Rutinitas Ibadah | `reference/rutinitas_ibadah/` | `/habit_focus/rutinitas_ibadah` | Religious routine tracker |
| Rutinitas Spiritual | `reference/rutinitas_spiritual/` | `/habit_focus/rutinitas_spiritual` | Spiritual routine tracker |
| Catatan Kebaikan | `reference/catatan_kebaikan/` | `/habit_focus/catatan_kebaikan` | Daily kindness journal/notes |
| Statistik Mingguan | `reference/statistik_mingguan/` | `/habit_focus/statistik_mingguan` | Weekly statistics and progress |

### Design System: Mindful Growth

Full specification: [`reference/mindful_growth/DESIGN.md`](reference/mindful_growth/DESIGN.md)

**Colors:**
- Primary: `#0f5238` (deep forest green) - growth habits, completion states
- Secondary: `#2a6485` (steel blue) - work focus, cognitive tasks
- Tertiary: `#634019` (dusty ochre) - religious routines, daily kindness
- Background: `#f8f9fa` (soft off-white)

**Typography:** Manrope font family
- Headlines: 32px/26px mobile, weight 700, tight letter-spacing
- Body: 16-18px, weight 400, generous line-height
- Labels: 12-14px, weight 500-600

**Spacing:** 8px base unit
- Mobile margins: 20px (1.25rem)
- Stack gap (within lists): 16px (1rem)
- Section gap (between pillars): 40px (2.5rem)

**Shapes:** Rounded with 8px (0.5rem) default radius

**Elevation:** Soft ambient shadows (0 4px 40px rgba(0,0,0,0.04)), no heavy drop shadows

### lib/habit_focus/ Structure

```
lib/habit_focus/
├── theme/
│   └── habit_focus_theme.dart       # ThemeData based on Mindful Growth design system
├── widgets/
│   ├── habit_card.dart              # Reusable habit card with category color indicator
│   ├── progress_ring.dart           # Circular progress indicator
│   ├── daily_progress_bar.dart      # Top-of-screen daily completion bar
│   ├── category_chip.dart           # Mood/category tag chips
│   └── section_header.dart          # Section title with consistent styling
└── screens/
    ├── beranda_screen.dart          # Home/dashboard
    ├── fokus_kerja_screen.dart      # Work focus timer
    ├── rutinitas_ibadah_screen.dart  # Religious routines
    ├── rutinitas_spiritual_screen.dart # Spiritual routines
    ├── catatan_kebaikan_screen.dart  # Kindness journal
    └── statistik_mingguan_screen.dart # Weekly stats
```

### Component Breakdown

Each page is composed of shared widgets:

- **Habit Card** - White container with category-colored left border, checkbox, title, and streak info
- **Progress Ring** - Thin circular ring (secondary color) showing time/completion
- **Daily Progress Bar** - Persistent thin bar at screen top showing daily habit score
- **Category Chip** - Low-opacity pill with category color fill and matching text
- **Section Header** - Consistent heading style for grouping habits by pillar
- **Interactive Checkbox** - Large circle that fills with primary color on selection

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter SDK | ^3.8.0 | Framework |
| cupertino_icons | ^1.0.8 | iOS-style icons |
| salomon_bottom_bar | 3.3.2 | Animated bottom navigation |
| concentric_transition | 1.0.3 | Onboarding page transitions |

## Build & Run

```bash
# Install dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome

# Analyze code for errors/warnings
flutter analyze

# Access a specific widget
# Open browser to: http://localhost:PORT/?path=/category/widget_name
```

## Conventions

- Each widget is a standalone `StatelessWidget` or `StatefulWidget` in its own file
- Use `const` constructors with `super.key` parameter
- Private helper widgets use underscore prefix: `_HelperName`
- Use `Theme.of(context)` for styling
- Follow Material Design 3 patterns
- No external state management (local state only)
- No new packages should be added without explicit approval
