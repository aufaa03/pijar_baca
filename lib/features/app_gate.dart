// Versi dengan animasi lebih smooth
// import 'package:flutter/foundation.dart';  //untuk debug mode
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pijar_baca/core/providers/initialization_provider.dart';
import 'package:pijar_baca/features/home/presentation/bookshelf_screen.dart';
import 'package:pijar_baca/features/onboarding/presentation/onboarding_screen.dart';

class AppGate extends ConsumerWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final init = ref.watch(appInitializationProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: init.when(
         // Saat sedang loading, tampilkan SplashScreen
        // Key penting agar AnimatedSwitcher tahu widgetnya berbeda
        loading: () => const SplashScreen(key: ValueKey('splash')),

        // Jika ada error, tampilkan ErrorScreen
        error: (err, stack) => ErrorScreen(
          key: const ValueKey('error'),
          error: err.toString(),
        ),

        // Jika selesai, periksa hasil boolean-nya
        data: (hasSeenOnboarding) {
          // Jika sudah pernah lihat onboarding, ke rak buku
          if (hasSeenOnboarding) {
            return const BookshelfScreen(key: ValueKey('bookshelf'));
          }
          // Jika belum, ke halaman onboarding
          else {
            return const OnboardingScreen(key: ValueKey('onboarding'));
          }
            // Ia akan `true` saat kita debug, dan `false` saat aplikasi dirilis. 
            // untuk memaksa menampilkan onboarding screen = debug apk
          // if (kDebugMode) {
          //   // 2. Jika sedang debug, selalu tampilkan OnboardingScreen
          //   print('DEBUG MODE: Menampilkan OnboardingScreen secara paksa.');
          //   return const OnboardingScreen(key: ValueKey('onboarding_debug'));
          // } else {
          //   // 3. Jika tidak, gunakan logika normal
          //   return hasSeenOnboarding
          //       ? const BookshelfScreen(key: ValueKey('bookshelf'))
          //       : const OnboardingScreen(key: ValueKey('onboarding'));
          // }
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with gradient and shadow
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: colorScheme.onPrimary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 32),
              
              // Minimal loading indicator
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              
              // App name with subtle animation
              Text(
                'Pijar Baca',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              
              // Subtle loading text
              Text(
                'Mempersiapkan...',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onBackground.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String error;
  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error illustration
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: colorScheme.error.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.error.withOpacity(0.1),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.sentiment_dissatisfied_rounded,
                  color: colorScheme.error.withOpacity(0.7),
                  size: 48,
                ),
              ),
              const SizedBox(height: 40),
              
              // Error title
              Text(
                'Oops!',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 16),
              
              // Error description
              Text(
                'Terjadi masalah saat memuat aplikasi',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onBackground.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Technical error (collapsible for minimal look)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  error,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      // Retry logic
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Coba Lagi'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}