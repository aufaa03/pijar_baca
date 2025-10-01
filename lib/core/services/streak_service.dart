// Lokasi: lib/features/streak/application/streak_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pijar_baca/main.dart'; // supaya bisa akses isarService

class StreakService {
  /// Hitung detail streak (current & longest)
  Future<Map<String, int>> getStreakDetails() async {
    return await isarService.getStreakDetails();
  }

  /// Ambil jumlah permata beku
  Future<int> getFreezeGemCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('freezeGemCount') ?? 0;
  }

  /// Claim permata beku manual (misal dari reward lain)
  Future<void> addFreezeGem({int count = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('freezeGemCount') ?? 0;
    await prefs.setInt('freezeGemCount', current + count);
  }

  /// Gunakan permata beku untuk menyelamatkan streak
  Future<bool> useFreezeGem() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('freezeGemCount') ?? 0;
    if (current > 0) {
      await prefs.setInt('freezeGemCount', current - 1);
      return true;
    }
    return false;
  }
}
