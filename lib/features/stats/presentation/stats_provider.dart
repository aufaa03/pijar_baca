import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pijar_baca/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider untuk data statistik
final totalBooksFinishedProvider = FutureProvider<int>((ref) {
  return isarService.getTotalBooksFinishedThisYear();
});

final readingDaysProvider = FutureProvider<Set<DateTime>>((ref) {
  return isarService.getReadingDays();
});

final readingDaysCountProvider = FutureProvider<int>((ref) async {
  final readingDays = await ref.watch(readingDaysProvider.future);
  return readingDays.length;
});

final averageBooksPerMonthProvider = FutureProvider<double>((ref) async {
  final totalBooks = await ref.watch(totalBooksFinishedProvider.future);
  final currentMonth = DateTime.now().month;
  return currentMonth > 0 ? totalBooks / currentMonth : 0.0;
});

// StateNotifier untuk target membaca
class ReadingTargetNotifier extends StateNotifier<int> {
  ReadingTargetNotifier() : super(24) {
    _loadTarget();
  }

  Future<void> _loadTarget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTarget = prefs.getInt('reading_target');
      if (savedTarget != null) {
        state = savedTarget;
      }
    } catch (e) {
      // Tetap pakai default 24 jika error
      state = 24;
    }
  }

  Future<void> updateTarget(int newTarget) async {
    if (newTarget <= 0) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reading_target', newTarget);
      state = newTarget;
    } catch (e) {
      // Jika error save, tetap update state
      state = newTarget;
    }
  }
}

final readingTargetProvider = StateNotifierProvider<ReadingTargetNotifier, int>((ref) {
  return ReadingTargetNotifier();
});