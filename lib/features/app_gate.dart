import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pijar_baca/core/providers/initialization_provider.dart';
import 'package:pijar_baca/features/home/presentation/bookshelf_screen.dart';

class AppGate extends ConsumerWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tonton status provider inisialisasi
    final init = ref.watch(appInitializationProvider);

    return init.when(
      // Saat sedang loading, tampilkan ini
      loading: () => const SplashScreen(),
      // Jika ada error, tampilkan ini
      error: (err, stack) => ErrorScreen(error: err.toString()),
      // Jika selesai, tampilkan halaman utama
      data: (_) => const BookshelfScreen(),
    );
  }
}

// Widget sederhana untuk splash/loading screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Menyiapkan Pijar Baca...'),
          ],
        ),
      ),
    );
  }
}

// Widget sederhana untuk menampilkan error
class ErrorScreen extends StatelessWidget {
  final String error;
  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Terjadi kesalahan fatal:\n$error', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}