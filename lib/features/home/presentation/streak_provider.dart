import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pijar_baca/main.dart';

part 'streak_provider.g.dart';

@riverpod
Future<int> streakCount(StreakCountRef ref) async {
  final result = await isarService.calculateStreak();
  print("DEBUG >>> streakCount dihitung ulang: $result");
  return result;
}