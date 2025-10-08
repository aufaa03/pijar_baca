// Lokasi: lib/core/providers/initialization_provider.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pijar_baca/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'initialization_provider.g.dart';

// UBAH TIPE RETURN DARI Future<void> MENJADI Future<bool>
@riverpod
Future<bool> appInitialization(AppInitializationRef ref) async {
  // Lakukan semua tugas berat di sini
  await dotenv.load(fileName: ".env");
  await isarService.init();
  await notificationService.init();
  await notificationService.scheduleDailyReminder();
  
  // Cek apakah onboarding sudah pernah dilihat
  final prefs = await SharedPreferences.getInstance();
  
  // KEMBALIKAN NILAINYA DI SINI
  return prefs.getBool('hasSeenOnboarding') ?? false;
}