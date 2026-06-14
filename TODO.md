# TODO - Focus Screen Critical Bugs

## 🔴 CRITICAL BUG - Tasks Disappearing After Completion

**Status**: UNRESOLVED

**Problem**: When a user checks a task as complete on the Focus Screen, the task card disappears from the view instead of staying visible with a strikethrough.

**Root Cause Analysis Needed**:
1. Check if `getActiveSessions()` is filtering out sessions incorrectly
2. Verify if `_taskController.getById()` is returning null for completed tasks
3. Check if session's `currentTaskId` is being cleared when task is marked complete
4. Verify the session is being persisted correctly after task completion

**Debugging Steps**:
1. Add print statements in `_toggleTaskCompletion` to see task state before/after
2. Add print statements in `_loadData` to see what `getById` returns
3. Check if `getActiveSessions()` is returning the correct session
4. Verify the session's `currentTaskId` value before and after completion

**Expected Behavior**:
- Task should remain visible in the Current Task card
- Task should show with strikethrough decoration when completed
- Checking/unchecking should toggle the completion state without removing the task

**Current Behavior**:
- Task disappears completely from view after checking as complete

---

## ✅ COMPLETED

### Modal Height & Textarea
- Modal is now 40% screen height
- Textarea starts at 3 lines (minLines: 3) and can expand to 5 lines (maxLines: 5)
- Modal slides up from bottom with drag-to-dismiss functionality

### Habit Integration
- Focus session now integrates with HabitController
- Session pulls name from work habits if they exist
- Auto-creates work habit if none exists

### Dummy Data Removal
- Removed hardcoded dummy tasks from `_createDefaultTasks`
- App now uses real user data only

---

## 🔧 INVESTIGATION REQUIRED

### Focus Session State Management
- Review `getActiveSessions()` filter logic - does it exclude idle sessions?
- Review when sessions are created vs retrieved
- Check if multiple sessions are being created accidentally

### Task Controller
- Verify `getById()` returns tasks regardless of completion status
- Confirm `markCompleted()` only updates `isCompleted` field and doesn't delete tasks

### Session Controller
- Check if `update()` is properly persisting the session
- Verify `currentTaskId` isn't being cleared unexpectedly

---

**Priority**: P0 - Blocks core functionality
**Assigned**: AI Developer
**Last Updated**: 2026-06-14
