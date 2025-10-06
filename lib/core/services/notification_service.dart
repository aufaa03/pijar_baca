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
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: androidSettings);
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

  Future<void> scheduleDailyReminder() async {
    // Pastikan semua izin sudah diberikan sebelum menjadwalkan
    final bool permissionsGranted = await requestAllPermissions();
    if (!permissionsGranted) return; // Hentikan jika izin ditolak

    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('reminderHour') ?? 20;
    final minute = prefs.getInt('reminderMinute') ?? 0;
    final scheduledDate = _nextInstanceOfTime(hour, minute);

    await _notifications.zonedSchedule(
      0, // ID unik untuk notifikasi ini
      'Waktunya Membaca! 🔥', // Judul Notifikasi
      'Jangan biarkan apimu padam. Yuk, baca beberapa halaman hari ini.', // Isi Notifikasi
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reading_reminder_channel', // ID Channel
          'Pengingat Membaca', // Nama Channel
          channelDescription: 'Mengingatkan untuk membaca setiap hari.', // Deskripsi Channel
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFF6D4C41),
          playSound: true,
          // icon: 'reading',
          // icon: 'stack_of_books',
        ),
      ),
      payload: 'open_bookshelf',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}