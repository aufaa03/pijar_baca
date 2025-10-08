import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:pijar_baca/features/home/presentation/bookshelf_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Selamat Datang di\nPijar Baca",
      subtitle: "Aplikasi personal untuk melacak, mengelola, dan membangun kebiasaan membaca buku Anda secara konsisten dan menyenangkan.",
      lottieAsset: 'assets/lottie/books.json', // Ganti dengan path Lottie Anda
      color: Colors.blue,
    ),
    OnboardingPage(
      title: "Jaga Apimu\nTetap Menyala",
      subtitle: "Jangan biarkan api kebiasaanmu padam. Dapatkan Permata Beku 💎 sebagai hadiah untuk melindungi pencapaianmu.",
      lottieAsset: 'assets/lottie/Flame_animation.json', // Ganti dengan path Lottie Anda
      color: Colors.orange,
    ),
    OnboardingPage(
      title: "Fitur Cerdas di\nUjung Jari",
      subtitle: "Scan ISBN, rekomendasi AI, dan kuis interaktif untuk pengalaman membaca yang lebih dalam dan personal.",
      lottieAsset: 'assets/lottie/Live_chatbot.json', // Ganti dengan path Lottie Anda
      color: Colors.purple,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onIntroEnd(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const BookshelfScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: TextButton(
                  onPressed: () => _onIntroEnd(context),
                  child: Text(
                    'Lewati',
                    style: TextStyle(
                      color: colorScheme.onBackground.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Page View Content
            Expanded(
              flex: 4,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPageContent(page, index);
                },
              ),
            ),

            // Bottom Section
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Column(
                  children: [
                    // Page Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index 
                                ? _pages[index].color 
                                : colorScheme.onBackground.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ).animate(delay: (index * 100).ms).fadeIn(duration: 300.ms);
                      }),
                    ),

                    const Spacer(),

                    // Next/Done Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          if (_currentPage == _pages.length - 1) {
                            _onIntroEnd(context);
                          } else {
                            _pageController.nextPage(
                              duration: 500.ms,
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: _pages[_currentPage].color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1 ? 'Mulai Membaca' : 'Lanjut',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ).animate(delay: 300.ms).slideY(
                        begin: 0.5,
                        end: 0,
                        duration: 400.ms,
                        curve: Curves.easeOut,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(OnboardingPage page, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Illustration
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.color.withOpacity(0.1),
            ),
            child: Center(
              child: Lottie.asset(
                page.lottieAsset,
                width: 180,
                height: 180,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback sederhana jika Lottie tidak tersedia
                  return Icon(
                    Icons.auto_stories_rounded,
                    size: 80,
                    color: page.color,
                  );
                },
              ),
            ),
          ).animate(
            delay: 100.ms,
          ).scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 600.ms,
            curve: Curves.elasticOut,
          ),

          const SizedBox(height: 60),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: colorScheme.onBackground,
              height: 1.2,
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 500.ms).slideY(
            begin: 0.3,
            end: 0,
            duration: 500.ms,
            curve: Curves.easeOut,
          ),

          const SizedBox(height: 20),

          // Subtitle
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colorScheme.onBackground.withOpacity(0.6),
              height: 1.5,
            ),
          ).animate(delay: 300.ms).fadeIn(duration: 600.ms).slideY(
            begin: 0.3,
            end: 0,
            duration: 600.ms,
            curve: Curves.easeOut,
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String lottieAsset;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.lottieAsset,
    required this.color,
  });
}