# HabitFocus (Better Person)

A mindful habit tracking app for building daily habits across three life pillars: Growth, Work Focus, and Kindness & Spirituality.

## Features

HabitFocus provides six screens to help users track and maintain their daily habits:

| Screen | Route | Description |
|--------|-------|-------------|
| Home (Beranda) | `/habit_focus/home` | Main dashboard with daily habit overview and progress |
| Focus (Fokus Kerja) | `/habit_focus/focus` | Work focus timer with circular progress indicator |
| Ibadah (Rutinitas Ibadah) | `/habit_focus/ibadah` | Religious routine tracker |
| Spiritual (Rutinitas Spiritual) | `/habit_focus/spiritual` | Spiritual routine tracker |
| Kindness (Catatan Kebaikan) | `/habit_focus/kindness` | Daily kindness journal and notes |
| Statistics (Statistik Mingguan) | `/habit_focus/statistics` | Weekly statistics and progress charts |

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

## URL Routing

The app uses URL query parameters for navigation instead of Flutter Navigator:

```
http://localhost:PORT/?path=/habit_focus/home
http://localhost:PORT/?path=/habit_focus/focus
```

If no path is provided or the path is not found, the app defaults to the Home screen.

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
├── main.dart              # App entry point with route map
└── habit_focus/
    ├── theme/             # Mindful Growth theme data
    ├── widgets/           # Shared reusable widgets
    └── screens/           # Individual screen implementations
```
