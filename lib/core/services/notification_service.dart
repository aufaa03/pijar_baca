// Lokasi: lib/core/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pijar_baca/features/home/presentation/bookshelf_screen.dart';
import 'package:pijar_baca/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Fungsi ini harus berada di luar kelas untuk background callback
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // print('DEBUG: Notifikasi diklik di background: ${notificationResponse.payload}');
}

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );
    await _notifications.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Cek 'payload' untuk menentukan aksi
        if (response.payload == 'open_bookshelf') {
          // Gunakan GlobalKey untuk navigasi
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const BookshelfScreen()),
            (route) => false,
          );
        }
      },
    );

    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<bool> requestAllPermissions() async {
    // Meminta izin notifikasi dasar
    await Permission.notification.request();
    // Meminta izin untuk penjadwalan & alarm
    await Permission.scheduleExactAlarm.request();

    return await Permission.notification.isGranted &&
        await Permission.scheduleExactAlarm.isGranted;
  }

  Future<bool> scheduleDailyReminder() async {
    try {
      // Cek dan minta izin notifikasi
      final bool permissionsGranted = await requestAllPermissions();
      if (!permissionsGranted) {
        print('❌ Izin notifikasi ditolak, tidak bisa menjadwalkan pengingat');
        return false;
      }

      // Ambil waktu dari preferences
      final prefs = await SharedPreferences.getInstance();
      final hour = prefs.getInt('reminderHour') ?? 20;
      final minute = prefs.getInt('reminderMinute') ?? 0;

      final scheduledDate = _nextInstanceOfTime(hour, minute);

      // Batalkan notifikasi yang sudah ada terlebih dahulu
      await _cancelExistingReminder();

      // Jadwalkan notifikasi harian
      await _notifications.zonedSchedule(
        0, // ID unik
        _getMotivationalTitle(), // Judul yang memotivasi
        _getPersonalizedMessage(), // Pesan yang personal
        scheduledDate,
        _getEnhancedNotificationDetails(), // Detail notifikasi yang lebih baik
        payload: 'open_bookshelf',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('✅ Pengingat harian berhasil dijadwalkan pukul $hour:$minute');

      return true;
    } catch (e) {
      print('❌ Gagal menjadwalkan pengingat harian: $e');
      return false;
    }
  }

  Future<void> _cancelExistingReminder() async {
    try {
      await _notifications.cancel(0);
      print('✅ Notifikasi lama dibatalkan');
    } catch (e) {
      print('⚠️ Gagal membatalkan notifikasi lama: $e');
    }
  }

  NotificationDetails _getEnhancedNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reading_reminder_channel',
        '🔥 Pengingat Membaca Harian',
        channelDescription:
            'Mengingatkan Anda untuk membaca setiap hari dan menjaga streak membaca',
        importance: Importance.max,
        priority: Priority.high,
        color: Color(0xFF6D4C41),
        playSound: true,
        enableVibration: true,
        autoCancel: true,
      ),
    );
  }

  String _getMotivationalTitle() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour < 12) {
      return '🌅 Selamat Pagi, Waktunya Membaca!';
    } else if (hour < 15) {
      return '☀️ Selamat Siang, Isi Harimu dengan Buku!';
    } else if (hour < 18) {
      return '🌇 Selamat Sore, Saatnya Relaksasi dengan Buku';
    } else {
      return '🌙 Selamat Malam, Jaga Apimu Tetap Menyala!';
    }
  }

  String _getPersonalizedMessage() {
    final messages = [
      'Jangan biarkan streak-mu padam! Baca 10 menit saja hari ini. 🔥',
      'Buku-bukumu menunggumu! Yuk, lanjutkan perjalanan membacamu. 📚',
      'Membaca hari ini = Streak yang lebih kuat besok! Terus semangat! 💪',
      'Api membacamu butuh bahan bakar! Baca beberapa halaman yuk. ✨',
      'Progress kecil hari ini = Pencapaian besar besok! Tetap konsisten! 🚀',
      'Waktu terbaik untuk membaca adalah sekarang. Jaga momentummu! ⚡',
      'Setiap halaman yang dibaca membawamu lebih dekat ke goals-mu! 🌟',
      'Jangan lewatkan hari ini! Baca buku favoritmu dan jaga streak. 📖',
      'Konsisten adalah kunci! Luangkan waktu sebentar untuk membaca. 🗝️',
      'Membaca adalah investasi untuk dirimu sendiri. Yuk, mulai sekarang! 💎',
      'Satu bab lagi sebelum tidur? Kamu pasti bisa! 🚀'
      'Dunia di dalam bukumu merindukanmu. Ayo kembali berpetualang. 🗺️'
      'Investasi 15 menit untuk membaca hari ini akan sangat berarti. ✨'
      'Jangan putus rantai kebiasaan baikmu. Api streak menunggumu! 🔥'
      'Lelah? Membaca bisa jadi cara terbaik untuk bersantai sejenak. ☕',
      'Lihat kalender di statistikmu, jangan biarkan ada hari yang kosong! 🗓️'
    ];

    final randomIndex = DateTime.now().day % messages.length;
    return messages[randomIndex];
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
