# Better Person - Habit Tracker Application Specification

## Project Overview

**Better Person** is a comprehensive habit tracking application that helps users improve their daily lives across multiple dimensions: personal growth, work productivity, spiritual devotion, and acts of kindness. The app combines habit tracking, Pomodoro-style focus sessions, worship tracking (Islamic and custom), and daily good deeds recording into a unified experience.

**Technology Stack:**

- Framework: Flutter (SDK ^3.8.0)
- Platform: Web (Chrome optimized)
- Version: 1.0.1
- State Management: Custom controller-based architecture (singleton pattern)
- Data Persistence: Local JSON file storage

---

## Architecture

### Data Flow

```
User Interaction → Screen/Widget → Controller → Model → StorageService → JSON File
                                                      ↓
                                                  Persist to Disk
```

### Core Components

1. **Models** - Data structures with JSON serialization
2. **Controllers** - State management with CRUD operations (extend BaseController<T>)
3. **Screens** - Main navigation destinations
4. **Widgets** - Reusable UI components
5. **Services** - Storage, initialization, auto-checking utilities

---

## Feature Implementation Status

### Legend

- ✅ **IMPLEMENTED** - Feature is fully working
- 🟡 **PARTIAL** - UI exists but logic incomplete
- ❌ **NOT IMPLEMENTED** - Feature is missing
- 📝 **PLANNED** - Mentioned in code but not started

---

## 1. HOME SCREEN

**Route:** `/` (HomeScreen)  
**File:** `lib/components/screens/home_screen.dart`

### ✅ Implemented Features

#### Greeting Section

- Time-aware greeting messages (Good Morning/Afternoon/Evening)
- User name display
- User avatar display
- Auto-creates default user if none exists

#### Main Dashboard (Bento Grid Layout)

- **Today's Progress Card**
  - Overall daily completion percentage
  - Circular progress indicator
  - Status message based on progress
- **Current Streak Card**
  - Consecutive days counter
  - Fire icon indicator
  - Motivational message
- **Deep Work Card**
  - Total focus time accumulated (hours and minutes)
  - Brain icon indicator
  - Time-based formatting
- **Devotion Card**
  - Count of completed devotional habits
  - Lotus icon indicator

#### Key Habits Section

- Displays top 3 habits
- Shows habit title, subtitle, and duration
- Color-coded by category (growth/work/kindness/devotion)
- Left border accent in category color

#### Responsive Design

- Desktop: 2-column bento grid
- Mobile: Stacked single column
- Breakpoint: 600px

### 🟡 Partial Implementation

#### User Statistics

- Data structure exists in User model
- Display logic implemented
- **MISSING:** Real-time calculation from activities
- **MISSING:** Automatic updates when activities complete

#### Habit Display

- Static "top 3" display
- **MISSING:** Dynamic sorting by importance/frequency
- **MISSING:** Habit completion toggle (intentionally disabled - auto-check only)

### ❌ Not Implemented

- Pull-to-refresh daily data
- Habit history view
- Quick action buttons (e.g., "Start Focus Session")
- Daily goal setting
- Motivational quotes/tips
- Progress animations on first load
- Weekly summary preview

---

## 2. FOCUS SCREEN

**Route:** `/focus` (FocusScreen)  
**Files:**

- `lib/components/screens/focus_screen/focus_screen.dart`
- `lib/components/screens/focus_screen/session_manager.dart`
- `lib/components/screens/focus_screen/task_manager.dart`
- `lib/components/screens/focus_screen/focus_dialogs.dart`

### ✅ Implemented Features

#### Timer System

- **Circular progress timer** with animated countdown
- **Timer states:**
  - Idle (not started)
  - Focusing (25-minute work session)
  - On Break (5-minute break)
- **Timer controls:**
  - Start/Resume button
  - Pause button
  - Reset button (when idle)
- **Time display:** MM:SS format
- **Progress ring:** Visual percentage completion
- **Background timer:** Continues running using Dart `Timer.periodic()`
- **State persistence:** Timer state saved across navigation

#### Current Task Display

- Shows active task title
- Task completion checkbox
- Empty state when no current task
- Visual prominence with primary color accent

#### Task Queue ("Up Next")

- List of pending tasks
- Task ordering (sortOrder property)
- Empty state message
- Task promotion: First task becomes current when current completes

#### Completed Tasks Section

- Collapsible section
- Shows all completed tasks
- Task count badge
- Strike-through styling
- Checkmark icons

#### Task Management

- **Add new task:** Text input with "Add Task" button
- **Edit task:** Tap task title to edit inline
- **Delete task:** Swipe-to-delete or delete button
- **Mark complete/incomplete:** Checkbox toggle
- **Task properties:** Title, tags (array), priority (high/medium/low), sortOrder

#### Session Management

- Auto-creates focus session on first load
- Single session per day
- Session contains: currentTaskId, upNextTaskIds array, timer state
- Persists to JSON via FocusSessionController

#### Completion Dialogs

- **Break completion dialog:** "Break's Over!" with motivational message
- **Session completion dialog:** Shows tasks completed, time focused
- Dialog actions: Continue, End Session

#### Auto-Habit Checking

- Completing focus session → Auto-checks "Deep Work Session" habit
- Completing task with "Deep Work" tag → Auto-checks work habit

### 🟡 Partial Implementation

#### Task Drag-and-Drop Reordering

- sortOrder property exists in Task model
- **MISSING:** Actual drag-and-drop UI implementation
- **MISSING:** Reorder method in TaskController

#### Task Tagging System

- Tags array exists in Task model
- **MISSING:** Tag input UI
- **MISSING:** Tag display chips
- **MISSING:** Tag filtering

#### Task Priority

- Priority field exists (high/medium/low)
- **MISSING:** Priority indicator UI
- **MISSING:** Priority-based sorting

### ❌ Not Implemented

- Timer sound notifications
- Browser notification when break/session ends
- Custom timer durations (e.g., 50-min focus, 10-min break)
- Long break after 4 sessions (traditional Pomodoro)
- Session history view
- Daily/weekly focus statistics
- Focus time goals
- Distraction counter
- Task time estimates
- Task categories/projects
- Task due dates
- Task notes/description
- Keyboard shortcuts (spacebar to start/pause)
- Background music/ambient sounds
- Focus mode (hide other apps/notifications)

---

## 3. DEVOTION SCREEN

**Route:** `/devotion` (DevotionScreen)  
**File:** `lib/components/screens/devotion_screen.dart`

### ✅ Implemented Features

#### Tab Navigation

- Two tabs: "Islamic" and "Other"
- Smooth tab switching
- Tab indicator with primary color

#### Islamic Tab

**Next Prayer Hero Card:**

- Displays next upcoming prayer
- Countdown to next prayer (e.g., "in 2h 30m")
- Prayer time display
- Decorative icon

**Daily Shalat Checklist:**

- Five daily prayers: Fajr, Dhuhr, Asr, Maghrib, Isha
- Each prayer shows:
  - Prayer name
  - Scheduled time
  - Completion checkbox
  - Checked timestamp
- Visual states:
  - Next prayer: Primary color border
  - Future prayers: Tertiary color border
  - Completed: Checkmark, muted styling
- Prayer completion tracking

**Sunnah & Dzikir Progress:**

- Progress tracker cards (e.g., "Morning Dzikir 33/33")
- Completion count display
- Progress bar indicator

#### Other Tab

**Custom Devotion Hero Card:**

- Prominent card highlighting custom practices
- Motivational text
- Call-to-action styling

**Custom Devotion List:**

- Displays user-created devotional practices
- Default examples:
  - Morning Meditation (10 min at 6:00 AM)
  - Evening Prayer (15 min at 7:00 PM)
  - Gratitude Journal (5 min at 9:00 PM)
- Each entry shows:
  - Practice name
  - Duration
  - Scheduled time
  - Completion checkbox

**Add Custom Devotion Form:**

- Text input for devotion name
- Time picker for scheduled time
- "Add Devotion" button

### 🟡 Partial Implementation

#### Prayer Times

- Prayer times hardcoded in UI
- **MISSING:** Dynamic prayer time calculation based on location
- **MISSING:** Timezone support
- **MISSING:** Location permission and geolocation

#### Custom Devotion Creation

- UI form exists
- **MISSING:** Form submission handler
- **MISSING:** Validation
- **MISSING:** Connection to CustomDevotionController

#### Dzikir Counter

- Model exists (DzikirEntry)
- Controller exists (DzikirEntryController)
- **MISSING:** Counter UI
- **MISSING:** Increment/decrement buttons
- **MISSING:** Counter reset functionality

#### Quran Reading Tracker

- Model exists (QuranSession)
- Controller exists (QuranSessionController)
- **MISSING:** UI implementation
- **MISSING:** Page number input
- **MISSING:** Progress visualization

### ❌ Not Implemented

- Prayer time notifications
- Adhan (call to prayer) audio
- Qibla direction compass
- Prayer time settings (calculation method, madhab)
- Manual prayer time adjustment
- Prayer statistics (on-time rate, missed prayers)
- Quran reading plan generator
- Quran reading statistics
- Dzikir templates (morning/evening adhkar)
- Dhikr audio
- Islamic calendar integration
- Hijri date display
- Custom devotion reminders
- Devotion streak tracking
- Reflection/journal for each practice
- Devotion categories/tags

---

## 4. KINDNESS SCREEN

**Route:** `/kindness` (KindnessScreen)  
**File:** `lib/components/screens/kindness_screen.dart`

### ✅ Implemented Features

#### Header Section

- Prominent heading: "How did you help today?"
- Motivational subtext: "Small acts create ripples of positive change"
- Inviting, warm design

#### Quick Ideas Card

- **Predefined kindness act chips** (6 default options):
  1. Gave a compliment
  2. Helped a colleague
  3. Held the door open
  4. Listened actively
  5. Donated to charity
  6. Sent a thoughtful message
- Chip selection toggles (tap to select/deselect)
- Visual feedback on selection (filled vs outlined)
- Multi-select capability

#### Impact Counter Card

- **Weekly acts counter** (e.g., "14 Acts of kindness this week")
- Heart icon indicator
- **Progress bar** towards weekly goal
- **Motivational message** based on progress
- Visual celebration when goal reached

#### Reflection Card

- **Free-text textarea** for detailed description
- Placeholder text: "Describe your act of kindness..."
- Multi-line input support
- Character limit (if any)
- **"Log Kindness" button** to save entry

#### Responsive Design

- Desktop: 2-column grid for Quick Ideas + Impact Counter, full-width Reflection
- Mobile: Stacked single column layout
- Breakpoint: 600px

### 🟡 Partial Implementation

#### Kindness Logging

- UI form exists
- KindnessLog model and controller exist
- **MISSING:** Form submission handler
- **MISSING:** Save to KindnessLogController
- **MISSING:** Clear form after submission
- **MISSING:** Success feedback/confirmation

#### Weekly Statistics

- Display logic exists
- **MISSING:** Real calculation from KindnessLog entries
- **MISSING:** Date range filtering (current week)
- **MISSING:** Automatic counter updates

#### Quick Ideas Selection

- Selection state managed in UI
- **MISSING:** Persist selected acts to log entry
- **MISSING:** Link selection to KindnessAct model

### ❌ Not Implemented

- Custom kindness act creation
- Kindness act categories
- Photo attachment for acts
- Share kindness acts on social media
- Kindness streak tracking
- Monthly/yearly kindness statistics
- Kindness impact visualization (map, network graph)
- Kindness reminders/prompts
- Gratitude journal integration
- Community feed (see others' acts - privacy respecting)
- Kindness challenges/goals
- Badge system for kindness milestones
- Export kindness log
- Search/filter past acts
- Kindness calendar view
- Impact stories/testimonials

---

## 5. STATISTICS SCREEN

**Route:** `/statistics` (StatisticsScreen)  
**File:** `lib/components/screens/statistics_screen.dart`

### ✅ Implemented Features

#### Growth Score Card

- **Large percentage display** (e.g., "85%")
- Circular progress ring with animated fill
- Eco/leaf icon indicator
- **Trend indicator** with +/- percentage and arrow
- Status message based on score
- Color-coded (primary color for good, warning for poor)

#### Daily Consistency Chart

- **7-day bar chart** (Monday through Sunday)
- Vertical bars showing completion ratios (0-100%)
- Animated bar growth on page load
- Current day highlighted with primary color
- Past days in muted color
- Grid lines for easy reading
- Day labels below bars

#### Activity Breakdown Cards

- **Three category cards:**
  1. **Work Focus**
     - Hours tracked this week
     - Brain icon
     - Trend indicator (up/down arrow with percentage)
     - Secondary color border
  2. **Ibadah/Devotion**
     - Consistency percentage
     - Lotus icon
     - Trend indicator
     - Tertiary color border
  3. **Kindness**
     - Total acts count
     - Heart icon
     - Trend indicator
     - Primary color border

- Responsive grid layout (row on desktop, column on mobile)

#### Recent Badges Section

- **Horizontal scrollable badge list**
- Badge cards showing:
  - Badge icon (circular, color-coded)
  - Badge name (e.g., "Focus Master", "Early Bird", "Helper")
  - Achievement description
  - Achievement date
- **Default badges:**
  - Focus Master: "Tracked 10 hours of deep work"
  - Early Bird: "Started work at 5 AM for 5 days"
  - Helper: "Completed 10 acts of kindness"

#### Visual Design

- Card-based layout with consistent spacing
- Color-coded elements matching category themes
- Subtle shadows and rounded corners
- Progress indicators throughout

### 🟡 Partial Implementation

#### All Statistics are Hardcoded

- Display UI is complete and polished
- **MISSING:** Real data calculations from controllers
- **MISSING:** Date range selection (current week)
- **MISSING:** Time-based aggregation logic
- **MISSING:** Trend calculation (week-over-week comparison)

#### Growth Score Calculation

- Formula/algorithm not defined
- **MISSING:** Weighting of different activities
- **MISSING:** Scoring logic

#### Daily Consistency Data

- **MISSING:** Pull data from habit completions
- **MISSING:** Calculate daily completion rates

#### Badge System

- Badge model exists
- **MISSING:** Badge earning logic
- **MISSING:** Badge criteria definitions
- **MISSING:** Badge unlock notifications
- **MISSING:** Badge progress tracking

### ❌ Not Implemented

- Date range selector (week/month/year/all-time)
- Detailed charts (line graphs, pie charts)
- Category drill-down views
- Export statistics as PDF/CSV
- Compare periods (this week vs last week)
- Goal setting and tracking
- Detailed habit history
- Focus session breakdown (by task/project)
- Prayer time statistics (on-time rate, missed prayers)
- Kindness impact metrics
- Custom statistics views
- Data insights and suggestions
- Performance predictions
- Share statistics
- Leaderboards (if multi-user)

---

## 6. DATA MODELS

**Location:** `lib/models/`

### Core Models

#### User Model

**File:** `lib/models/user.dart`

```dart
class User {
  String id;
  String name;
  String? avatarUrl;
  int streak;                    // Consecutive days
  int dailyProgress;             // Percentage (0-100)
  int totalHabitsDone;
  double totalFocusHours;
  int totalKindActs;
  int growthScore;               // Percentage (0-100)
  DateTime createdAt;
  DateTime updatedAt;
}
```

**Status:** ✅ Fully implemented with JSON serialization

---

#### Habit Model

**File:** `lib/models/habit.dart`

```dart
enum HabitCategory { growth, work, kindness, devotion }

class Habit {
  String id;
  String title;
  String subtitle;
  String duration;               // Human-readable (e.g., "15 min")
  HabitCategory category;
  bool isCompleted;
  DateTime? completedAt;
  DateTime createdAt;
}
```

**Color Mapping:**

- growth → Primary color
- work → Secondary color
- kindness → Primary color
- devotion → Tertiary color

**Status:** ✅ Fully implemented  
**Note:** Habits auto-check via HabitAutoChecker, not manually toggleable

---

#### Task Model

**File:** `lib/models/task.dart`

```dart
enum TaskPriority { high, medium, low }

class Task {
  String id;
  String title;
  List<String> tags;
  TaskPriority priority;
  bool isCompleted;
  int sortOrder;                 // For ordering in queue
  DateTime? completedAt;
  DateTime createdAt;
}
```

**Status:** ✅ Fully implemented  
**Partial:** Priority and tags not used in UI

---

#### FocusSession Model

**File:** `lib/models/focus_session.dart`

```dart
enum TimerState { idle, focusing, onBreak }

class FocusSession {
  String id;
  String? currentTaskId;
  List<String> upNextTaskIds;    // Ordered array
  int timerDuration;             // Seconds
  int elapsed;                   // Seconds
  TimerState timerState;
  DateTime createdAt;

  // Computed properties
  double get progress;
  int get remaining;
  String get timerDisplay;       // "MM:SS"
}
```

**Status:** ✅ Fully implemented with timer logic

---

#### Prayer Model

**File:** `lib/models/prayer.dart`

```dart
enum PrayerName { fajr, dhuhr, asr, maghrib, isha }

class Prayer {
  String id;
  PrayerName name;
  TimeOfDay scheduledTime;
  bool isChecked;
  DateTime? checkedAt;
  DateTime date;                 // Which day this prayer belongs to
}
```

**Status:** ✅ Fully implemented  
**Partial:** Scheduled times are hardcoded, not location-based

---

#### Spiritual Models

**QuranSession** (`lib/models/quran_session.dart`)

```dart
class QuranSession {
  String id;
  int pagesRead;
  int goalPages;
  DateTime date;
}
```

**Status:** ✅ Model exists, ❌ UI not implemented

**DzikirEntry** (`lib/models/dzikir_entry.dart`)

```dart
class DzikirEntry {
  String id;
  String type;                   // "morning", "evening", "custom"
  int count;
  int targetCount;
  DateTime date;
}
```

**Status:** ✅ Model exists, ❌ UI not implemented

**CustomDevotion** (`lib/models/custom_devotion.dart`)

```dart
class CustomDevotion {
  String id;
  String name;
  String duration;
  TimeOfDay scheduledTime;
  bool isCompleted;
  DateTime? completedAt;
  DateTime createdAt;
}
```

**Status:** ✅ Model exists, 🟡 UI exists but handler missing

**SpiritualMoment** (`lib/models/spiritual_moment.dart`)

```dart
class SpiritualMoment {
  String id;
  String type;                   // "meditation", "prayer", "reflection"
  int durationMinutes;
  DateTime scheduledTime;
  bool isCompleted;
  DateTime createdAt;
}
```

**Status:** ✅ Model exists, ❌ Not used in UI

---

#### Kindness Models

**KindnessAct** (`lib/models/kindness_act.dart`)

```dart
class KindnessAct {
  String id;
  String title;
  bool isSelected;

  static List<KindnessAct> getDefaultActs() {
    // Returns 6 predefined acts
  }
}
```

**Status:** ✅ Fully implemented, used in UI

**KindnessLog** (`lib/models/kindness_log.dart`)

```dart
class KindnessLog {
  String id;
  List<String> selectedActIds;
  String reflection;
  DateTime date;
}

class WeeklyKindnessStats {
  int totalActs;
  int weeklyGoal;
  double get progress;
}
```

**Status:** ✅ Model exists, 🟡 Not connected to UI form

---

#### Statistics Models

**Badge** (`lib/models/badge.dart`)

```dart
class Badge {
  String id;
  String name;
  String description;
  IconData icon;
  Color color;
  DateTime earnedAt;
}
```

**Status:** ✅ Model exists, ❌ Earning logic not implemented

**GrowthScore** (`lib/models/growth_score.dart`)

```dart
class GrowthScore {
  double score;                  // 0-100
  double trend;                  // +/- percentage
  DateTime weekStartDate;
}
```

**Status:** ✅ Model exists, ❌ Calculation not implemented

**ActivitySummary** (`lib/models/activity_summary.dart`)

```dart
class ActivitySummary {
  String category;               // "work", "devotion", "kindness"
  double value;
  String unit;                   // "hours", "acts", "%"
  double trend;
  DateTime weekStartDate;
}
```

**Status:** ✅ Model exists, ❌ Aggregation not implemented

**DailyConsistencyRecord** (`lib/models/daily_consistency.dart`)

```dart
class DailyConsistencyRecord {
  DateTime date;
  double completionRate;         // 0-1
}
```

**Status:** ✅ Model exists, ❌ Calculation not implemented

---

## 7. CONTROLLERS (STATE MANAGEMENT)

**Location:** `lib/controllers/`

### BaseController<T> (Abstract)

**File:** `lib/controllers/base_controller.dart`

Generic CRUD controller that all other controllers extend.

**Key Features:**

- Singleton pattern enforcement
- File-based persistence via StorageService
- Generic type-safe operations
- Automatic JSON serialization

**Core Methods:**

```dart
abstract class BaseController<T> {
  Future<void> init();                           // Load from disk
  List<T> getAll();
  T? getById(String id);
  Future<T> create(T item);
  Future<T> update(String id, T item);
  Future<void> delete(String id);
  Future<T> updateFields(String id, Map<String, dynamic> fields);
  Future<void> updateMany(List<String> ids, Map<String, dynamic> fields);
  Future<void> deleteMany(List<String> ids);
  List<T> findWhere(bool Function(T) predicate);
  T? findFirst(bool Function(T) predicate);
  Future<void> persist();                        // Save to disk
}
```

**Status:** ✅ Fully implemented and tested

---

### Implemented Controllers

#### UserController

**File:** `lib/controllers/user_controller.dart`  
**Storage Key:** `users`  
**Status:** ✅ Fully implemented

**Additional Methods:**

- `getCurrentUser()` - Returns first user or creates default
- `updateStreak(int days)` - Update streak counter
- `updateDailyProgress(int percentage)` - Update daily progress
- `incrementTotalHabitsDone()` - Increment habit counter
- `addFocusHours(double hours)` - Add focus time
- `incrementKindActs()` - Increment kindness counter

---

#### HabitController

**File:** `lib/controllers/habit_controller.dart`  
**Storage Key:** `habits`  
**Status:** ✅ Fully implemented

**Additional Methods:**

- `getByCategory(HabitCategory category)` - Filter by category
- `markComplete(String id)` - Mark habit as complete
- `markIncomplete(String id)` - Unmark habit
- `resetDaily()` - Reset all habits (for new day)

**Integration:** Works with HabitAutoChecker for automatic completion

---

#### TaskController

**File:** `lib/controllers/task_controller.dart`  
**Storage Key:** `tasks`  
**Status:** ✅ Fully implemented

**Additional Methods:**

- `toggleComplete(String id)` - Toggle completion status
- `reorderTasks(List<String> orderedIds)` - Update sortOrder
- `getIncomplete()` - Get pending tasks
- `getCompleted()` - Get finished tasks

**Integration:** Used by FocusScreen for task management

---

#### FocusSessionController

**File:** `lib/controllers/focus_session_controller.dart`  
**Storage Key:** `focus_sessions`  
**Status:** ✅ Fully implemented

**Additional Methods:**

- `getTodaySession()` - Get or create today's session
- `startTimer()` - Begin focus timer
- `pauseTimer()` - Pause timer
- `resetTimer()` - Reset to idle
- `updateTimerState(TimerState state)` - Change state
- `setCurrentTask(String taskId)` - Set active task
- `promoteNextTask()` - Move first upNext to current
- `addToQueue(String taskId)` - Add task to upNext
- `removeFromQueue(String taskId)` - Remove from upNext

**Integration:** Core controller for Focus screen functionality

---

#### PrayerController

**File:** `lib/controllers/prayer_controller.dart`  
**Storage Key:** `prayers`  
**Status:** ✅ Fully implemented

**Additional Methods:**

- `getTodayPrayers()` - Get today's 5 prayers
- `getNextPrayer()` - Get upcoming prayer
- `checkPrayer(String id)` - Mark prayer complete
- `uncheckPrayer(String id)` - Unmark prayer
- `initializeDailyPrayers()` - Create 5 prayers for today

**Integration:** Used by Devotion screen Islamic tab

---

#### KindnessActController

**File:** `lib/controllers/kindness_act_controller.dart`  
**Storage Key:** `kindness_acts`  
**Status:** ✅ Fully implemented

**Additional Methods:**

- `toggleSelection(String id)` - Select/deselect act
- `getSelected()` - Get selected acts

**Integration:** Used by Kindness screen for quick ideas

---

#### KindnessLogController

**File:** `lib/controllers/kindness_log_controller.dart`  
**Storage Key:** `kindness_logs`  
**Status:** ✅ Model and controller implemented, 🟡 Not connected to UI

**Additional Methods:**

- `getTodayLog()` - Get today's log entry
- `getWeekStats()` - Calculate weekly statistics
- `logKindness(List<String> actIds, String reflection)` - Save log entry

**Missing:** Form submission handler in UI

---

#### CustomDevotionController

**File:** `lib/controllers/custom_devotion_controller.dart`  
**Storage Key:** `custom_devotions`  
**Status:** ✅ Fully implemented, 🟡 Not connected to UI

**Additional Methods:**

- `markComplete(String id)` - Mark devotion complete
- `markIncomplete(String id)` - Unmark devotion

**Missing:** Add devotion form handler

---

#### QuranSessionController

**File:** `lib/controllers/quran_session_controller.dart`  
**Storage Key:** `quran_sessions`  
**Status:** ✅ Implemented, ❌ UI not built

**Additional Methods:**

- `getTodaySession()` - Get or create today's session
- `updateProgress(int pages)` - Update pages read

---

#### DzikirEntryController

**File:** `lib/controllers/dzikir_entry_controller.dart`  
**Storage Key:** `dzikir_entries`  
**Status:** ✅ Implemented, ❌ UI not built

**Additional Methods:**

- `getTodayEntry(String type)` - Get today's dzikir by type
- `incrementCount(String id)` - Increment counter
- `resetDaily()` - Reset for new day

---

#### SpiritualMomentController

**File:** `lib/controllers/spiritual_moment_controller.dart`  
**Storage Key:** `spiritual_moments`  
**Status:** ✅ Implemented, ❌ Not used

---

#### StatisticsController

**File:** `lib/controllers/statistics_controller.dart`  
**Storage Key:** Multiple (badges, growth_scores, activity_summaries, daily_consistency)  
**Status:** ✅ Controller exists, ❌ Calculation logic not implemented

**Additional Methods:**

- `getBadges()` - Get earned badges
- `getGrowthScore()` - Get current growth score
- `getActivitySummaries()` - Get weekly activity breakdown
- `getDailyConsistency(DateTime weekStart)` - Get 7-day chart data

**Missing:**

- Badge earning logic
- Growth score calculation algorithm
- Real-time statistics aggregation

---

## 8. SERVICES & UTILITIES

### StorageService (Singleton)

**File:** `lib/utils/storage_service.dart`

Handles all file I/O operations for data persistence.

**Methods:**

```dart
class StorageService {
  Future<void> save(String key, List<Map<String, dynamic>> data);
  Future<List<Map<String, dynamic>>> load(String key);
  Future<void> delete(String key);
  Future<bool> exists(String key);
  Future<void> clearAll();
}
```

**File Structure:**

- Uses `path_provider` to get app documents directory
- Each controller stores data as `{key}.json`
- Example files: `habits.json`, `tasks.json`, `prayers.json`

**Status:** ✅ Fully implemented and working

---

### HabitAutoChecker

**File:** `lib/utils/habit_auto_checker.dart`

Automatically checks habits when certain activities complete.

**Triggers:**

- Focus session completes → Check "Deep Work Session" habit
- Task with "Deep Work" tag completes → Check work habit
- All prayers checked → Check devotion habit
- Kindness log saved → Check "Daily Impact" habit
- Quran session completes → Check Quran habit

**Methods:**

```dart
class HabitAutoChecker {
  static void checkWorkHabit();
  static void checkDevotionHabit();
  static void checkKindnessHabit();
  static void checkQuranHabit();
  static void resetDailyHabits();
}
```

**Status:** ✅ Logic implemented, 🟡 Some integrations incomplete

---

### ControllerInitializer

**File:** `lib/utils/controller_initializer.dart`

Initializes all controllers on app startup.

**Method:**

```dart
class ControllerInitializer {
  static Future<void> initializeAll();
}
```

**Process:**

1. Called in `main()` before runApp()
2. Calls `init()` on each controller
3. Each controller loads data from StorageService
4. Ensures data is ready before UI renders

**Status:** ✅ Fully implemented

---

## 9. DESIGN SYSTEM

**File:** `lib/components/theme/habit_focus_theme.dart`

### Color Palette

**Primary Colors:**

```dart
primary: Color(0xFF0F5238)           // Deep forest green - Growth, completion
primaryContainer: Color(0xFFB8E6D0)
onPrimary: Color(0xFFFFFFFF)
```

**Secondary Colors:**

```dart
secondary: Color(0xFF2A6485)         // Steel blue - Work focus, cognitive tasks
secondaryContainer: Color(0xFFB8D4E6)
onSecondary: Color(0xFFFFFFFF)
```

**Tertiary Colors:**

```dart
tertiary: Color(0xFF634019)          // Dusty ochre - Religious routines, kindness
tertiaryContainer: Color(0xFFE6D0B8)
onTertiary: Color(0xFFFFFFFF)
```

**Background & Surface:**

```dart
background: Color(0xFFF8F9FA)        // Soft off-white
surface: Color(0xFFFFFFFF)           // Pure white
surfaceContainerLowest: Color(0xFFFFFFFF)
surfaceContainerLow: Color(0xFFF1F3F4)
surfaceContainer: Color(0xFFEBEDEE)
surfaceContainerHigh: Color(0xFFE5E7E8)
surfaceContainerHighest: Color(0xFFE1E3E4)
```

**Outline & Borders:**

```dart
outline: Color(0xFF707973)           // Text secondary, dividers
outlineVariant: Color(0xFFBFC9C1)    // Subtle borders
```

**Status Colors:**

```dart
error: Color(0xFFBA1A1A)
onError: Color(0xFFFFFFFF)
```

### Typography

**Font Family:** Default (Manrope suggested in README, not configured in code)

**Text Styles:**

```dart
headlineLarge:   32px, weight 700, letterSpacing -0.64
headlineMedium:  24px, weight 600
headlineSmall:   20px, weight 600
bodyLarge:       18px, weight 400
bodyMedium:      16px, weight 400
bodySmall:       14px, weight 400
labelLarge:      14px, weight 600
labelMedium:     14px, weight 500
labelSmall:      12px, weight 500
```

### Spacing System

```dart
spacingBase: 8.0         // Base unit
mobilePadding: 20.0      // Screen edge padding
stackGap: 16.0           // Gap between cards in vertical stack
sectionGap: 40.0         // Gap between major sections
```

### Border Radius

```dart
defaultRadius: 8.0       // Small elements (buttons, chips)
cardRadius: 12.0         // Cards, containers
```

### Shadows

```dart
ambientShadow: BoxShadow(
  offset: Offset(0, 4),
  blurRadius: 40,
  color: Color.fromRGBO(0, 0, 0, 0.04)
)
```

Very subtle elevation for a calm, uncluttered feel.

### Card Styling Pattern

```dart
- Background: surface (white)
- Left border: 4px solid category color
- Border radius: 12px
- Padding: 20-24px
- Shadow: ambientShadow
```

### Category Color Mapping

```dart
growth → primary (green)
work → secondary (blue)
kindness → primary (green)
devotion → tertiary (ochre)
```

**Status:** ✅ Fully implemented and consistent across app

---

## 10. NAVIGATION & ROUTING

**Files:**

- `lib/routes/app_routes.dart` - Route definitions
- `lib/routes/route_shell.dart` - Bottom navigation wrapper

### Route Structure

```dart
AppRoutes.home       → '/'           → HomeScreen
AppRoutes.focus      → '/focus'      → FocusScreen
AppRoutes.devotion   → '/devotion'   → DevotionScreen
AppRoutes.kindness   → '/kindness'   → KindnessScreen
AppRoutes.statistics → '/statistics' → StatisticsScreen
```

### Navigation Pattern

- **Bottom Navigation Bar** on all main screens
- Uses `Navigator.pushReplacementNamed()` (replaces route, no back stack)
- Current route maintained in RouteShell state
- Active tab highlighted with pill-shaped indicator

### Bottom Navigation Design

```dart
Index mapping:
0 → Home (home icon)
1 → Focus (target icon)
2 → Devotion (lotus icon)
3 → Kindness (heart icon)
4 → Statistics (bar chart icon)
```

**Visual States:**

- Active: Filled icon, label visible, primaryContainer background
- Inactive: Outlined icon, no label, transparent background

### Not Implemented Routes

- `/profile` - ProfileScreen exists but not in routes
- `/spiritual` - SpiritualScreen exists but not in routes
- Deep linking
- Query parameters
- Route guards/middleware

**Status:** ✅ Basic navigation implemented, ❌ Some screens not routed

---

## 11. TECHNICAL DEBT & KNOWN ISSUES

### High Priority

1. **Statistics are Hardcoded**
   - Statistics screen displays demo data
   - No real calculation from user activities
   - Need aggregation logic for all metrics

2. **Prayer Times are Static**
   - Prayer times hardcoded in UI
   - Need location-based calculation
   - Need timezone handling

3. **Missing Form Handlers**
   - Kindness log "Log Kindness" button does nothing
   - Custom devotion "Add Devotion" button does nothing
   - Need to wire UI to controllers

4. **No Daily Reset Mechanism**
   - Habits don't auto-reset at midnight
   - Prayers don't regenerate for new day
   - Need scheduler/cron job

5. **Badge System Not Functional**
   - Badge models exist
   - No earning logic implemented
   - No progress tracking

### Medium Priority

6. **Task Reordering UI Missing**
   - sortOrder exists in model
   - No drag-and-drop implementation
   - Manual reorder method needed

7. **Tag System Incomplete**
   - Tags array exists in Task model
   - No UI for adding/displaying tags
   - No tag filtering

8. **Priority System Unused**
   - Priority field exists
   - No visual indicators
   - No priority-based sorting

9. **Growth Score Algorithm Undefined**
   - Display exists
   - No calculation formula
   - Need to define weighting

10. **Quran & Dzikir UI Missing**
    - Models and controllers exist
    - No UI implementation
    - Referenced in Devotion screen but not built

### Low Priority

11. **No Notifications**
    - No timer completion sounds
    - No browser notifications
    - No prayer time reminders

12. **Limited Timer Customization**
    - Fixed 25/5 minute intervals
    - No custom durations
    - No long break (4-session cycle)

13. **Profile/Spiritual Screens Not Routed**
    - Files exist but not accessible
    - Not in bottom navigation

14. **No Data Export**
    - No backup functionality
    - No CSV/JSON export
    - No import from backup

15. **No Onboarding Flow**
    - New users see app immediately
    - No tutorial or setup wizard
    - No preference selection

---

## 12. MISSING FEATURES SUMMARY

### By Screen

**Home Screen:**

- ❌ Pull-to-refresh
- ❌ Habit history view
- ❌ Quick action buttons
- ❌ Daily goals
- ❌ Motivational content
- ❌ Weekly summary

**Focus Screen:**

- ❌ Sound notifications
- ❌ Browser notifications
- ❌ Custom timer durations
- ❌ Long breaks
- ❌ Session history
- ❌ Task drag-and-drop
- ❌ Task tags UI
- ❌ Task priorities UI
- ❌ Task categories/projects
- ❌ Task due dates
- ❌ Keyboard shortcuts

**Devotion Screen:**

- ❌ Dynamic prayer times
- ❌ Adhan audio
- ❌ Qibla compass
- ❌ Prayer notifications
- ❌ Quran reading UI
- ❌ Dzikir counter UI
- ❌ Custom devotion form handler
- ❌ Hijri calendar
- ❌ Prayer statistics

**Kindness Screen:**

- ❌ Form submission handler
- ❌ Real weekly statistics
- ❌ Custom acts creation
- ❌ Photo attachments
- ❌ Share functionality
- ❌ Kindness streak
- ❌ Calendar view
- ❌ Search/filter

**Statistics Screen:**

- ❌ Real data calculations
- ❌ Date range selector
- ❌ Detailed charts
- ❌ Badge earning logic
- ❌ Export statistics
- ❌ Goal tracking
- ❌ Period comparison

### Cross-Cutting Features

- ❌ User authentication
- ❌ Multi-device sync
- ❌ Data backup/restore
- ❌ Dark mode
- ❌ Localization (i18n)
- ❌ Offline-first architecture (partially done with local storage)
- ❌ Analytics/telemetry
- ❌ Error logging/crash reporting
- ❌ Performance monitoring
- ❌ Accessibility improvements
- ❌ Mobile app (iOS/Android)
- ❌ PWA features (install prompt, offline mode)

---

## 13. DEVELOPMENT ROADMAP

### Phase 1: Complete Core Functionality (MVP) - 2-3 weeks

**Priority: Critical**

1. **Wire up missing handlers**
   - Connect Kindness log form to KindnessLogController
   - Connect Custom devotion form to CustomDevotionController
   - Test form validation and error handling

2. **Implement real statistics calculation**
   - Build aggregation logic in StatisticsController
   - Calculate growth score from activity data
   - Calculate weekly activity summaries
   - Build daily consistency data from habits
   - Wire statistics screen to real data

3. **Implement daily reset system**
   - Build scheduler for midnight reset
   - Reset habits daily
   - Regenerate prayers for new day
   - Clear/archive yesterday's data

4. **Build badge system**
   - Define badge criteria (JSON config or database)
   - Implement earning logic
   - Add badge checking to activity completion
   - Add badge unlock notifications

5. **Dynamic prayer times**
   - Integrate prayer time calculation library (e.g., adhan.dart)
   - Request location permission
   - Calculate based on user location and timezone
   - Add prayer time settings UI

**Deliverable:** Fully functional habit tracker with all screens working

---

### Phase 2: Enhanced Features - 2-3 weeks

**Priority: High**

6. **Complete Devotion screen features**
   - Build Quran reading tracker UI
   - Build Dzikir counter UI
   - Add prayer statistics view
   - Add devotion streak tracking

7. **Task management improvements**
   - Implement drag-and-drop task reordering
   - Build tag input and display UI
   - Add priority visual indicators
   - Implement task filtering by tags/priority

8. **Notifications system**
   - Timer completion sounds
   - Browser notifications for timers
   - Prayer time reminders
   - Custom devotion reminders

9. **Data persistence improvements**
   - Implement data backup to file
   - Implement data restore from backup
   - Add export to CSV/JSON
   - Add data validation and migration

10. **User settings screen**
    - Build profile/settings UI
    - Timer duration customization
    - Weekly kindness goal setting
    - Notification preferences
    - Theme preferences (prep for dark mode)

**Deliverable:** Feature-rich app with enhanced usability

---

### Phase 3: Polish & Optimization - 1-2 weeks

**Priority: Medium**

11. **UI/UX improvements**
    - Add loading states
    - Add empty states with helpful messages
    - Add error states with recovery actions
    - Improve form validation feedback
    - Add animations and transitions

12. **Performance optimization**
    - Optimize JSON file reads/writes
    - Implement lazy loading for large lists
    - Add pagination for history views
    - Optimize timer updates (reduce redraws)

13. **Accessibility**
    - Add semantic labels for screen readers
    - Ensure keyboard navigation works
    - Improve color contrast
    - Add focus indicators

14. **Testing**
    - Write unit tests for controllers
    - Write unit tests for models
    - Write widget tests for key screens
    - Add integration tests for critical flows

**Deliverable:** Production-ready, polished application

---

### Phase 4: Advanced Features - 3-4 weeks

**Priority: Nice-to-have**

15. **Authentication & Sync**
    - User registration/login
    - Cloud data sync
    - Multi-device support
    - Conflict resolution

16. **Social features**
    - Community kindness feed (optional, privacy-focused)
    - Share achievements
    - Kindness challenges

17. **Advanced statistics**
    - Detailed charts and visualizations
    - Custom date ranges
    - Period comparison
    - Trends and predictions
    - Export reports

18. **Mobile apps**
    - Build iOS app
    - Build Android app
    - Add mobile-specific features (notifications, widgets)

19. **Gamification**
    - More badges and achievements
    - Leaderboards (optional)
    - Daily challenges
    - Milestone celebrations

**Deliverable:** Full-featured platform with social and advanced features

---

## 14. FILE STRUCTURE REFERENCE

### Key Entry Points

```
lib/
├── main.dart                                    # App entry point, calls ControllerInitializer
│
├── models/                                      # Data models (15 files)
│   ├── models.dart                              # Barrel export
│   ├── user.dart                                # User profile and stats
│   ├── habit.dart                               # Habit tracking
│   ├── task.dart                                # Focus session tasks
│   ├── focus_session.dart                       # Pomodoro session state
│   ├── prayer.dart                              # Islamic prayer tracking
│   ├── quran_session.dart                       # Quran reading tracker
│   ├── dzikir_entry.dart                        # Dhikr counter
│   ├── custom_devotion.dart                     # Custom devotional practices
│   ├── spiritual_moment.dart                    # Meditation/reflection
│   ├── kindness_act.dart                        # Kindness act definitions
│   ├── kindness_log.dart                        # Daily kindness log
│   ├── badge.dart                               # Achievement badges
│   ├── growth_score.dart                        # Weekly growth metric
│   ├── activity_summary.dart                    # Category activity data
│   └── daily_consistency.dart                   # Daily completion rates
│
├── controllers/                                 # State management (16 files)
│   ├── controllers.dart                         # Barrel export
│   ├── base_controller.dart                     # Generic CRUD base class
│   ├── user_controller.dart                     # User data management
│   ├── habit_controller.dart                    # Habit operations
│   ├── task_controller.dart                     # Task CRUD
│   ├── focus_session_controller.dart            # Timer and session state
│   ├── prayer_controller.dart                   # Prayer tracking
│   ├── quran_session_controller.dart            # Quran progress
│   ├── dzikir_entry_controller.dart             # Dhikr counting
│   ├── custom_devotion_controller.dart          # Custom devotions
│   ├── spiritual_moment_controller.dart         # Spiritual practices
│   ├── kindness_act_controller.dart             # Kindness acts
│   ├── kindness_log_controller.dart             # Kindness logging
│   └── statistics_controller.dart               # Statistics and badges
│
├── routes/                                      # Navigation
│   ├── app_routes.dart                          # Route definitions
│   └── route_shell.dart                         # Bottom nav wrapper
│
├── components/
│   ├── theme/
│   │   └── habit_focus_theme.dart               # Complete design system
│   │
│   ├── screens/                                 # Main screens
│   │   ├── home_screen.dart                     # Dashboard with progress
│   │   ├── focus_screen/                        # Work focus (complex)
│   │   │   ├── focus_screen.dart                # Main focus UI
│   │   │   ├── session_manager.dart             # Timer logic
│   │   │   ├── task_manager.dart                # Task CRUD UI
│   │   │   └── focus_dialogs.dart               # Completion dialogs
│   │   ├── devotion_screen.dart                 # Islamic + custom devotions
│   │   ├── kindness_screen.dart                 # Daily kindness tracking
│   │   ├── statistics_screen.dart               # Weekly stats and charts
│   │   ├── profile_screen.dart                  # ⚠️ Exists but not routed
│   │   └── spiritual_screen.dart                # ⚠️ Exists but not routed
│   │
│   └── widgets/                                 # Reusable components
│       ├── habit_focus_app_bar.dart             # Custom app bar
│       ├── habit_focus_bottom_nav.dart          # Bottom navigation
│       ├── section_card.dart                    # Generic card container
│       ├── progress_ring.dart                   # Circular progress indicator
│       ├── habit_card.dart                      # Habit display card
│       ├── daily_progress_bar.dart              # Linear progress bar
│       ├── home/                                # Home screen widgets
│       │   ├── greeting_section.dart
│       │   ├── progress_card.dart
│       │   └── key_habits_section.dart
│       └── focus/                               # Focus screen widgets
│           ├── timer_display.dart
│           ├── task_item.dart
│           └── session_controls.dart
│
└── utils/                                       # Utilities
    ├── storage_service.dart                     # JSON file persistence
    ├── controller_initializer.dart              # Startup initialization
    └── habit_auto_checker.dart                  # Auto-check habits logic
```

---

## 15. QUICK REFERENCE

### What's Working ✅

- All 5 main screens with complete UI
- Bottom navigation between screens
- Focus timer with Pomodoro functionality
- Task management (add, edit, delete, complete)
- Prayer tracking UI (Islamic tab)
- Custom devotion display
- Kindness act selection UI
- Statistics display with charts
- Data persistence (JSON files)
- Responsive layouts (mobile/desktop)
- Complete design system

### What Needs Work 🟡

- Connect Kindness log form to controller
- Connect Custom devotion form to controller
- Calculate real statistics from data
- Implement badge earning logic
- Build Quran reading tracker UI
- Build Dzikir counter UI
- Add task drag-and-drop reordering
- Add task tags and priority UI
- Calculate dynamic prayer times

### What's Missing ❌

- Daily reset scheduler
- Notifications (timer, prayers)
- User authentication
- Data backup/export
- Dark mode
- Mobile apps (iOS/Android)
- Onboarding flow
- Settings/profile screen access

---

### Project Structure

- Start in `lib/main.dart`
- Review `lib/components/theme/habit_focus_theme.dart` for design system
- Check `lib/models/` for data structures
- Check `lib/controllers/` for business logic
- Review screens in `lib/components/screens/`

### Making Changes

1. Models define data structure (add JSON serialization)
2. Controllers handle business logic (extend BaseController)
3. Update UI to use controller methods
4. Changes persist automatically via StorageService

### Testing

```bash
# Run tests
flutter test

# Run specific test file
flutter test test/controllers/habit_controller_test.dart
```

---

## 17. CONCLUSION

**Better Person** is a well-architected Flutter habit tracking application with a solid foundation. The app successfully combines multiple personal development dimensions (work, spirituality, kindness) into a cohesive experience with a thoughtful design system.

### Strengths

- Clean MVC-inspired architecture
- Comprehensive data models covering all features
- Reusable controller pattern with generic base class
- Complete UI implementation for core screens
- Thoughtful "Mindful Growth" design system
- File-based persistence for offline-first experience
- Sophisticated focus timer with state management

### Current State

The application is **~70% complete** in terms of core functionality:

- ✅ UI Layer: 95% complete
- ✅ Data Layer: 90% complete
- 🟡 Business Logic: 60% complete
- ❌ Advanced Features: 20% complete

### Immediate Next Steps (MVP Completion)

1. Wire form handlers (Kindness log, Custom devotion)
2. Implement real statistics calculations
3. Build daily reset system
4. Implement badge earning logic
5. Add dynamic prayer time calculation

### Long-term Vision

With Phase 1-2 implementation (4-6 weeks), this becomes a production-ready habit tracking application. Phase 3-4 additions (4-6 weeks more) would create a feature-rich personal growth platform competitive with commercial offerings.

The codebase demonstrates good Flutter practices and is well-positioned for continued development, testing, and deployment.

---

**Document Version:** 1.0  
**Last Updated:** 2026-06-15  
**Status:** Complete specification based on current codebase analysis
