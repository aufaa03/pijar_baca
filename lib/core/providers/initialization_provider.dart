import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pijar_baca/main.dart';

part 'initialization_provider.g.dart';

@riverpod
Future<void> appInitialization(AppInitializationRef ref) async {
  // Lakukan semua tugas berat di sini
  await dotenv.load(fileName: ".env");
  await isarService.init();
  await notificationService.init();
  await isarService.checkAndUpdateStreak();
  // await notificationService.scheduleDailyReminder();
  // Tambahkan proses inisialisasi lain di sini jika ada
}