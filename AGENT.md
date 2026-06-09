# HabitFocus - Mindful Habit Tracking App

## Project Overview

This is a **Flutter web application** for mindful habit tracking. HabitFocus helps users build and maintain daily habits across three life pillars:

- **Growth (Daily Habits)** - represented by Primary (deep green)
- **Work Focus** - represented by Secondary (steel blue)
- **Kindness & Spirituality** - represented by Tertiary (ochre)

**SDK:** Flutter ^3.8.0  
**Package name:** `core`  
**Platform:** Web (Chrome)

## Directory Structure

```
better-person/
├── lib/
│   ├── main.dart                    # App entry point with route map
│   └── habit_focus/                 # HabitFocus habit tracking app
│       ├── theme/
│       │   └── habit_focus_theme.dart       # ThemeData based on Mindful Growth design system
│       ├── widgets/
│       │   ├── habit_card.dart              # Reusable habit card with category color indicator
│       │   ├── progress_ring.dart           # Circular progress indicator
│       │   ├── daily_progress_bar.dart      # Top-of-screen daily completion bar
│       │   ├── habit_focus_app_bar.dart     # Shared app bar with avatar and brand text
│       │   ├── habit_focus_bottom_nav.dart  # Custom 5-item bottom navigation
│       │   └── section_card.dart            # Generic container card with optional border
│       └── screens/
│           ├── home_screen.dart             # Home/dashboard
│           ├── focus_screen.dart            # Work focus timer
│           ├── ibadah_screen.dart           # Religious routines
│           ├── spiritual_screen.dart        # Spiritual routines
│           ├── kindness_screen.dart         # Kindness journal
│           └── statistics_screen.dart       # Weekly stats
├── reference/                       # HTML mockups for HabitFocus
│   ├── mindful_growth/DESIGN.md     # Design system specification
│   ├── beranda_habitfocus/          # Home/dashboard page mockup
│   ├── fokus_kerja/                 # Work focus timer page mockup
│   ├── rutinitas_ibadah/            # Religious routine page mockup
│   ├── rutinitas_spiritual/         # Spiritual routine page mockup
│   ├── catatan_kebaikan/            # Daily kindness notes page mockup
│   └── statistik_mingguan/          # Weekly statistics page mockup
├── web/                             # Flutter web entrypoint (index.html)
├── pubspec.yaml                     # Project manifest and dependencies
└── analysis_options.yaml            # Dart analyzer configuration
```

## Routing Mechanism

The app uses **URL query parameters** for routing. There is no Flutter Navigator-based routing.

### How it works

1. `lib/main.dart` defines a `routes` map: `Map<String, Widget Function()>`
2. Keys are path strings like `"/habit_focus/screen_name"`
3. The app reads the path from `Uri.base.queryParameters["path"]`
4. It looks up the matching builder function and renders the widget
5. If no match is found, the HomeScreen is shown as the default

### URL format

```
http://localhost:PORT/?path=/habit_focus/home
http://localhost:PORT/?path=/habit_focus/focus
```

All routes use `HabitFocusTheme.themeData` applied directly on `MaterialApp`.

## Pages

| Page | Reference Folder | Route Path | Description |
|------|-----------------|------------|-------------|
| Home (Beranda) | `reference/beranda_habitfocus/` | `/habit_focus/home` | Main dashboard with daily habit overview |
| Focus (Fokus Kerja) | `reference/fokus_kerja/` | `/habit_focus/focus` | Work focus timer with circular progress |
| Ibadah (Rutinitas Ibadah) | `reference/rutinitas_ibadah/` | `/habit_focus/ibadah` | Religious routine tracker |
| Spiritual (Rutinitas Spiritual) | `reference/rutinitas_spiritual/` | `/habit_focus/spiritual` | Spiritual routine tracker |
| Kindness (Catatan Kebaikan) | `reference/catatan_kebaikan/` | `/habit_focus/kindness` | Daily kindness journal/notes |
| Statistics (Statistik Mingguan) | `reference/statistik_mingguan/` | `/habit_focus/statistics` | Weekly statistics and progress |

## Design System: Mindful Growth

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

## Component Breakdown

Each page is composed of shared widgets:

- **Habit Card** - White container with category-colored left border, checkbox, title, and streak info
- **Progress Ring** - Thin circular ring (secondary color) showing time/completion
- **Daily Progress Bar** - Persistent thin bar at screen top showing daily habit score
- **Section Card** - Generic container card with ambient shadow and optional left border color
- **HabitFocus App Bar** - Shared top bar with user avatar, 'HabitFocus' title, settings icon
- **HabitFocus Bottom Nav** - 5-item bottom navigation (Home, Focus, Ibadah, Kindness, Profile)

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter SDK | ^3.8.0 | Framework |
| cupertino_icons | ^1.0.8 | iOS-style icons |

## Build & Run

```bash
# Install dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome

# Analyze code for errors/warnings
flutter analyze

# Access a specific page
# Open browser to: http://localhost:PORT/?path=/habit_focus/home
```

## Conventions

- Each widget is a standalone `StatelessWidget` or `StatefulWidget` in its own file
- Use `const` constructors with `super.key` parameter
- Private helper widgets use underscore prefix: `_HelperName`
- Use `Theme.of(context)` for styling
- Follow Material Design 3 patterns
- No external state management (local state only)
- No new packages should be added without explicit approval
