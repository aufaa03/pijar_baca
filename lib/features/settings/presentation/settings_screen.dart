// Lokasi: lib/features/settings/presentation/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:pijar_baca/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSavedTime();
  }

  Future<void> _loadSavedTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('reminderHour') ?? 20;
    final minute = prefs.getInt('reminderMinute') ?? 0;
    setState(() {
      _selectedTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reminderHour', picked.hour);
      await prefs.setInt('reminderMinute', picked.minute);

      await notificationService.scheduleDailyReminder();

      setState(() {
        _selectedTime = picked;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pengingat diubah ke ${_selectedTime.format(context)}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Waktu Pengingat Harian'),
            subtitle: Text('Notifikasi akan dikirim setiap hari pukul ${_selectedTime.format(context)}'),
            onTap: () => _selectTime(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Periksa Izin Notifikasi'),
            subtitle: const Text('Pastikan aplikasi memiliki izin yang dibutuhkan.'),
            onTap: () async {
              final bool granted = await notificationService.requestAllPermissions();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(granted
                        ? 'Terima kasih! Semua izin sudah diberikan.'
                        : 'Beberapa izin penting ditolak.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}