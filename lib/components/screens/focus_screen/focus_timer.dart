import 'dart:async';

import '../../../models/models.dart';

/// Runs a focus or break countdown based on wall-clock time.
///
/// Elapsed time is derived from [FocusSession.timerStartedAt] rather than being
/// counted per tick, so the timer keeps running while the screen is closed or
/// the app is reopened.
class FocusTimer {
  Timer? _timer;

  bool get isRunning => _timer != null;

  /// Starts ticking for [session], emitting elapsed time on every second and
  /// invoking the matching completion callback once the duration is reached.
  void start(
    FocusSession session, {
    required void Function(Duration elapsed) onTick,
    required void Function() onBreakComplete,
    required void Function() onSessionComplete,
  }) {
    stop();

    final anchor =
        session.timerStartedAt ?? DateTime.now().subtract(session.elapsed);
    final elapsedNow = DateTime.now().difference(anchor);

    // The session may have finished while the screen was closed.
    if (elapsedNow >= session.timerDuration) {
      onTick(session.timerDuration);
      _finish(session, onBreakComplete, onSessionComplete);
      return;
    }

    // Sync with the wall clock immediately, then tick once per second.
    onTick(elapsedNow);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final elapsed = DateTime.now().difference(anchor);
      if (elapsed >= session.timerDuration) {
        onTick(session.timerDuration);
        _finish(session, onBreakComplete, onSessionComplete);
        return;
      }
      onTick(elapsed);
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _finish(
    FocusSession session,
    void Function() onBreakComplete,
    void Function() onSessionComplete,
  ) {
    stop();
    if (session.timerState == TimerState.onBreak) {
      onBreakComplete();
    } else {
      onSessionComplete();
    }
  }
}
