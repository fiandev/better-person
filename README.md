# HabitFocus (Better Person)

A mindful habit tracking app for building daily habits across three life pillars: Growth, Work Focus, and Kindness & Spirituality.

## Features

HabitFocus provides six screens to help users track and maintain their daily habits:

| Screen | Description |
|--------|-------------|
| Home (Beranda) | Main dashboard with daily habit overview and progress |
| Focus (Fokus Kerja) | Work focus timer with circular progress indicator |
| Ibadah (Rutinitas Ibadah) | Religious routine tracker |
| Spiritual (Rutinitas Spiritual) | Spiritual routine tracker |
| Kindness (Catatan Kebaikan) | Daily kindness journal and notes |
| Statistics (Statistik Mingguan) | Weekly statistics and progress charts |

Navigation between screens is handled by the bottom navigation bar within the app.

## Tech Stack

- **Framework:** Flutter ^3.8.0
- **Platform:** Web (Chrome)
- **Dependencies:** cupertino_icons ^1.0.8
- **State management:** Local state only (no external packages)

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Analyze code for errors/warnings
flutter analyze
```

## Design System

HabitFocus uses the "Mindful Growth" design system:

- **Primary:** `#0f5238` (deep forest green) - growth habits, completion states
- **Secondary:** `#2a6485` (steel blue) - work focus, cognitive tasks
- **Tertiary:** `#634019` (dusty ochre) - religious routines, daily kindness
- **Background:** `#f8f9fa` (soft off-white)
- **Typography:** Manrope font family
- **Spacing:** 8px base unit
- **Shapes:** 8px border radius default

## Project Structure

```
lib/
├── main.dart              # App entry point (renders HomeScreen directly)
└── habit_focus/
    ├── theme/             # Mindful Growth theme data
    ├── widgets/           # Shared reusable widgets
    └── screens/           # Individual screen implementations
```
