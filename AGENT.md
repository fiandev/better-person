# Better Person - Mindful Habit Tracking App

## Project Overview

This is a **Flutter web application** for mindful habit tracking. Better Person helps users build and maintain daily habits across three life pillars:

- **Growth (Daily Habits)** - represented by Primary (deep green)
- **Work Focus** - represented by Secondary (steel blue)
- **Kindness & Spirituality** - represented by Tertiary (ochre)

**SDK:** Flutter ^3.44.1 

## Directory Structure

```
|better-person/
├── lib
│   ├── components
│   │   ├── screens
│   │   │   ├── focus_screen.dart
│   │   │   ├── home_screen.dart
│   │   │   ├── ibadah_screen.dart
│   │   │   ├── kindness_screen.dart
│   │   │   ├── profile_screen.dart
│   │   │   ├── spiritual_screen.dart
│   │   │   └── statistics_screen.dart
│   │   ├── theme
│   │   │   └── habit_focus_theme.dart
│   │   └── widgets
│   │       ├── daily_progress_bar.dart
│   │       ├── habit_card.dart
│   │       ├── habit_focus_app_bar.dart
│   │       ├── habit_focus_bottom_nav.dart
│   │       ├── progress_ring.dart
│   │       └── section_card.dart
│   ├── controllers
│   ├── main.dart
│   └── routes
    ├── app_routes.dart
    └── route_shell.dart

```

## Navigation

The app uses an internal bottom navigation bar (`Better PersonBottomNav`) to switch between screens. There is no URL-based routing or Flutter Navigator routing.

### How it works

1. `lib/main.dart` renders `HomeScreen` directly as the `home` widget of `MaterialApp`
2. The `Better PersonBottomNav` widget handles screen switching within the app
3. `Better PersonTheme.themeData` is applied on `MaterialApp`

## Pages

| Page | Reference Folder | Description |
|------|-----------------|-------------|
| Home (Beranda) | `reference/beranda_Better Person/` | Main dashboard with daily habit overview |
| Focus (Fokus Kerja) | `reference/fokus_kerja/` | Work focus timer with circular progress |
| Ibadah (Rutinitas Ibadah) | `reference/rutinitas_ibadah/` | Religious routine tracker |
| Spiritual (Rutinitas Spiritual) | `reference/rutinitas_spiritual/` | Spiritual routine tracker |
| Kindness (Catatan Kebaikan) | `reference/catatan_kebaikan/` | Daily kindness journal/notes |
| Statistics (Statistik Mingguan) | `reference/statistik_mingguan/` | Weekly statistics and progress |

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
- **Better Person App Bar** - Shared top bar with user avatar, 'Better Person' title, settings icon
- **Better Person Bottom Nav** - 5-item bottom navigation (Home, Focus, Ibadah, Kindness, Profile)

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter SDK | ^3.8.0 | Framework |
| cupertino_icons | ^1.0.8 | iOS-style icons |

## Build & Run

```bash
# Install dependencies
flutter pub get

# Analyze code for errors/warnings
flutter analyze
```

## Rules
1. always run flutter analyze every change code
