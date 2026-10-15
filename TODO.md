# TODO — Better Person

> Generated from a full codebase scan (Oct 2026). Status reflects the **actual code**, not SPEC.md (the spec is outdated in several places). Verified implementation notes are included where the spec and code disagree.

Status legend: ☐ todo · 🚧 partially done · ✅ done (per scan)

---

## 1. High Priority — Broken / Unwired Core

### 1.1 Statistics Screen: replace hardcoded data with real calculations 🚧
- File: `lib/components/screens/statistics_screen.dart`
- Screen is 100% hardcoded ("85%", `const _barHeights`, "18h 45m", `const _badges`, `onPressed: () {}`).
- The backend already exists: `lib/controllers/statistics_controller.dart` has `StatisticsService` with real `calculateGrowthScore()` (weights 0.3/0.3/0.2/0.2), `calculateActivitySummaries()`, `calculateDailyConsistency()`, plus Badge/GrowthScore/ActivitySummary/DailyConsistency controllers.
- ☐ Load real growth score into circle + trend
- ☐ Drive 7-day consistency bars from `calculateDailyConsistency()` (highlight actual current day)
- ☐ Drive Work Focus / Ibadah / Kindness summary cards from `calculateActivitySummaries()`
- ☐ Fix fake trend labels in summaries (`'+12.5%'` etc. literals) → compute week-over-week
- ☐ Render earned badges from `BadgeController` (via `badge_config.dart`) instead of `const _badges`
- ☐ Implement or remove "View All" badges button

### 1.2 Islamic Tab: wire Devotion screen to PrayerController 🚧
- File: `lib/components/screens/devotion_screen.dart`
- `_DailyShalatSection` and `_NextPrayerHero` are fully hardcoded ("Asr 15:30", countdown `01:42:15`, "2/5 Completed") and purely display-only.
- Data layer is ready: `PrayerController.initializeDailyPrayers()` already uses `LocationService` (SharedPreferences lat/lon, Mecca default) + `PrayerTimeCalculator` (adhan package, MWL method), and `DailyResetService` regenerates prayers each day.
- ☐ Replace hardcoded cards with `PrayerController.getTodayPrayers()`
- ☐ Next-prayer countdown from real `scheduledTime` + `getNextPrayer()`
- ☐ Add prayer check/uncheck handlers (`checkPrayer` / `uncheckPrayer`) with visual states
- ☐ Call `HabitAutoChecker().onPrayersComplete()` when all 5 prayers checked (currently never invoked)

### 1.3 Streak calculation is fake ☐
- `HomeScreen._createDefaultUser()` hardcodes `streak: 12`, `growthScore: 0.65`. Nothing anywhere recomputes `user.streak`.
- ☐ Implement streak logic (consecutive days with ≥1 completed activity; reset on missed day) in `UserController` or `DailyResetService`
- ☐ Reset hardcoded dev defaults (`streak: 0`, realistic growth score seed)
- ☐ Store `last_activity_date` on User to detect streak breaks

### 1.4 New-user default habits missing 🚧
- `HomeScreen._createDefaultHabits()` is fully commented out — new users get zero habits.
- ☐ Restore default habit seeding (or move it to `ControllerInitializer`) and verify auto-checking works against them

### 1.5 Badge checks only fire on one path 🚧
- `BadgeChecker.checkAndAwardBadges()` is called only from the kindness log path.
- ☐ Call it after: focus session completion, task completion (Deep Work tag), prayer completion, Quran/dzikir progress
- ☐ Add badge unlock feedback on those paths (snackbar shared with kindness path)

---

## 2. Devotion Features — Controllers Idle, No UI

### 2.1 Dzikir counter UI ☐
- `DzikirEntryController` exists (increment, getTodayEntry, resetDaily) but `_SunnahDzikirSection` is a static "Morning Dzikir 33/33" with fake progress.
- ☐ Build counter cards: increment button, live `count/targetCount`, progress bar, reset
- ☐ Seed morning/evening adhkar entries (33×3 tasbih etc.)
- ☐ Wire `HabitAutoChecker` on target reached

### 2.2 Quran reading tracker UI ☐
- `QuranSessionController` exists (getTodaySession, updateProgress); zero UI usage.
- ☐ Build section in Devotion screen: pages-read stepper/input, goal pages, daily progress visualization
- ☐ Call `HabitAutoChecker` Quran hook on goal completion

### 2.3 Location/prayer settings 🚧
- Location is stored in SharedPreferences but there is no UI to view/change it.
- ☐ Add settings entry (in `settings_screen.dart`): set location manually or request geolocation, choose calculation method for `PrayerTimeCalculator`

---

## 3. Focus Screen Improvements

### 3.1 Task drag-and-drop reordering ☐
- `Task.sortOrder` exists and `task_controller.reorderTasks()` exists; no `ReorderableListView` anywhere.
- ☐ Reorderable "Up Next" list → persist via `reorderTasks` → sync `FocusSession.upNextTaskIds`

### 3.2 Task tags UI 🚧
- Tags hardcoded to `['Deep Work']` in `task_manager.dart`.
- ☐ Tag add/remove UI (chips) on task create/edit sheets
- ☐ Tag display on task items
- ☐ Optional tag filter on the queue

### 3.3 Task priority UI 🚧
- `TaskPriority` hardcoded to `.medium`; no indicator, no sorting.
- ☐ Priority selector in create/edit sheet
- ☐ Priority indicator on task items
- ☐ Sort queue by priority within `sortOrder`

### 3.4 Timer customization ☐
- Fixed 25/5 in `session_manager.dart`.
- ☐ Custom focus/break durations (settings screen)
- ☐ Long break after N sessions (traditional Pomodoro cycle)

### 3.5 Focus notifications ☐
- ☐ Timer completion sound (web: just `AudioPlayer` / HTML audio)
- ☐ Browser notification on break/session end (opt-in)

---

## 4. Finance Area Gaps 🚧

The wallet/finance suite (wallet, add wallet, add transaction, transfer, financial analysis, settings) is implemented and wired, with these gaps:

- ☐ **Transaction edit/delete with balance reversal** — deleting/editing a transaction currently does not roll back the wallet balance (looks for no history/edit UI either)
- ☐ **Balance integrity** — add a "recalculate wallet balance from transactions" option in `WalletController`
- ☐ **Transaction history view** — list/filter past transactions (wallet detail or analysis page)
- ☐ **More settings** — `SettingController` only holds currency format; add theme, notifications prefs, timer durations (shared with 3.4), weekly kindness goal
- ☐ Transfer validation edge cases (insufficient balance, same-wallet transfer)

---

## 5. Navigation & Routing Cleanup 🚧

- ☐ **`spiritual_screen.dart` is orphaned** — not imported, not routed. Route it (e.g., inside Devotion) or delete the file
- ☐ **Kindness not in bottom nav** — wallet took index 3; kindness is routed but unreachable from bottom nav. Decide: restore kindness to nav (6 tabs) or add secondary access point (Home quick actions / app bar)
- ☐ Verify `route_shell.dart` index mapping matches the final nav set

---

## 6. Home Screen Polish

- ☐ Re-load data / react to changes when returning to Home (currently loads once in `initState`; deep-work card can go stale after a Focus session)
- ☐ Pull-to-refresh
- ☐ Quick action buttons (Start Focus Session, Log Kindness → deep links)
- ☐ Weekly summary preview
- ☐ Motivational quote/tip of the day
- ☐ Dynamic "Key Habits" ordering (by category importance/completion state) instead of static top 3

---

## 7. Statistics Extensions (after 1.1)

- ☐ Date range selector (week / month / all-time)
- ☐ Period comparison ("this week vs last week") reusing trend calculations
- ☐ Export statistics to CSV/JSON
- ☐ Export kindness log / all data to JSON backup + restore
- ☐ Prayer statistics (on-time rate, missed)
- ☐ Devotion & kindness streak tracking

---

## 8. Settings, Backup, Onboarding

- ☐ Profile settings: name edit, avatar, streak/goals display
- ☐ Weekly kindness goal configurable (currently hardcoded 14 in kindness screen)
- ☐ Data backup/restore (export all `{key}.json`, import + validation)
- ☐ Onboarding flow for first launch (name, default habits, goals)
- ☐ Dark mode prep (theme is light-only)

---

## 9. Cross-Cutting / Technical

- ☐ **Data reactivity** — controllers are pull-based; screens re-read on navigation. Add a light change-listener/notify pattern on `BaseController` (or per-screen reload hooks) to avoid stale UI
- ☐ **Session cleanup** — `getActiveSessions` returns all sessions; multiple sessions per day can accumulate. Archive/limit old sessions
- ☐ **CustomDevotion model drift** — screen omits `duration`; model has `date` instead (spec outdated). Confirm intended shape and align UI + spec
- ☐ File size discipline — biggest file is `statistics_controller.dart` (~706 lines); split `StatisticsService` out of the controllers file (AGENT.md: ≤300 lines)
- Localization (i18n) groundwork
- Accessibility pass (semantic labels, contrast, focus indicators)
- Unit tests: controllers (habit/task/prayer/kindness/statistics), models, `DailyResetService`
- Widget tests: home timer card, kindness form, devotion checklist
- `flutter analyze` must pass with zero warnings before any item is checked off (AGENT.md §6)

---

## Suggested Order of Attack

1. **1.1 Statistics wiring** — backend is done; pure UI work, huge visible payoff
2. **1.2 Islamic tab wiring** — data layer done, wire + add check handlers
3. **1.3 + 1.4 + 1.5** — streak logic, default habits, badge hooks (all auto-check related)
4. **2.1 / 2.2** — Dzikir & Quran UIs (controllers idle)
5. **4 Finance fixes** — delete/edit balance reversal, transaction history
6. **5 Routing cleanup** — spiritual screen, kindness nav access
7. **3 Focus improvements** — drag-drop, tags, priority, durations
8. Then 6 → 7 → 8 → 9 as polish
