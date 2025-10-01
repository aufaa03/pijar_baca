import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pijar_baca/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'streak_detail_provider.g.dart';

@riverpod
Future<Map<String, int>> streakDetails(StreakDetailsRef ref) async {
  final data = await isarService.getStreakDetails();

  // ✅ Simpan ke SharedPreferences biar bisa jadi fallback
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('cachedCurrentStreak', data['currentStreak'] ?? 0);
  await prefs.setInt('cachedLongestStreak', data['longestStreak'] ?? 0);

  return data;
}

@riverpod
Future<int> freezeGemCount(FreezeGemCountRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('freezeGemCount') ?? 0;
}

// Provider buat baca streak dari cache
final streakCacheProvider = FutureProvider<Map<String, int>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return {
    'current': prefs.getInt('cachedCurrentStreak') ?? 0,
    'longest': prefs.getInt('cachedLongestStreak') ?? 0,
  };
});
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:pijar_baca/main.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// part 'streak_detail_provider.g.dart';

// @riverpod
// Future<Map<String, int>> streakDetails(StreakDetailsRef ref) {
//   return isarService.getStreakDetails();
// }

// @riverpod
// Future<int> freezeGemCount(FreezeGemCountRef ref) async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getInt('freezeGemCount') ?? 0;
// }