import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pijar_baca/core/services/isar_service.dart';
import 'package:pijar_baca/core/services/notification_service.dart';
import 'package:pijar_baca/features/app_gate.dart';
import 'package:google_fonts/google_fonts.dart';

final isarService = IsarService();
final notificationService = NotificationService();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await notificationService.init(); // cukup init sekali
  // await isarService.checkAndUpdateStreak();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6D4C41),
        background: const Color(0xFFF0EAD6),
        surface: const Color(0xFFFAF8F0),
        onBackground: const Color(0xFF3E2723),
        onSurface: const Color(0xFF3E2723),
        primary: const Color(0xFF6D4C41),
        onPrimary: Colors.white,
        secondary: const Color(0xFF8D6E63),
        onSecondary: Colors.white,
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Pijar Baca',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.latoTextTheme(baseTheme.textTheme).copyWith(
          headlineMedium: GoogleFonts.lora(
            textStyle: baseTheme.textTheme.headlineMedium?.copyWith(
              color: baseTheme.colorScheme.onBackground,
            ),
            fontWeight: FontWeight.bold,
          ),
          titleLarge: GoogleFonts.lora(
            textStyle: baseTheme.textTheme.titleLarge?.copyWith(
              color: baseTheme.colorScheme.onBackground,
            ),
          ),
          titleMedium: GoogleFonts.lato(
            textStyle: baseTheme.textTheme.titleMedium?.copyWith(
              color: baseTheme.colorScheme.onBackground.withOpacity(0.8),
            ),
          ),
          bodyMedium: GoogleFonts.lato(
            textStyle: baseTheme.textTheme.bodyMedium?.copyWith(
              color: baseTheme.colorScheme.onBackground,
            ),
          ),
          bodySmall: GoogleFonts.lato(
            textStyle: baseTheme.textTheme.bodySmall?.copyWith(
              color: baseTheme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          color: baseTheme.colorScheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: baseTheme.colorScheme.background,
          foregroundColor: baseTheme.colorScheme.onBackground,
          centerTitle: true,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: baseTheme.colorScheme.secondary.withOpacity(0.1),
          labelStyle: TextStyle(color: baseTheme.colorScheme.secondary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: baseTheme
                .colorScheme
                .primary, // Latar belakang utama (coklat tua)
            foregroundColor: baseTheme.colorScheme.onPrimary, // Teks putih
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            elevation: 2, // Beri sedikit bayangan agar menonjol
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                baseTheme.colorScheme.surface, // Latar belakang terang (krem)
            foregroundColor: baseTheme
                .colorScheme
                .primary, // Teks berwarna utama (coklat tua)
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            elevation: 1, // Bayangan lebih tipis
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: baseTheme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: baseTheme.colorScheme.onBackground.withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: baseTheme.colorScheme.onBackground.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: baseTheme.colorScheme.primary,
              width: 2,
            ),
          ),
          labelStyle: TextStyle(
            color: baseTheme.colorScheme.onBackground.withOpacity(0.7),
          ),
          hintStyle: TextStyle(
            color: baseTheme.colorScheme.onBackground.withOpacity(0.5),
          ),
          fillColor: baseTheme.colorScheme.surface,
          filled: true,
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: baseTheme.colorScheme.primary,
          linearTrackColor: baseTheme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      home: const AppGate(),
    );
  }
}
