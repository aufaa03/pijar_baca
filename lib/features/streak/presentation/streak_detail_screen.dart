import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pijar_baca/features/streak/presentation/streak_detail_provider.dart';

class DetailStreakScreen extends ConsumerWidget {
  const DetailStreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakCacheAsync = ref.watch(streakCacheProvider);
    final streakDetailsAsync = ref.watch(streakDetailsProvider);
    final freezeGemAsync = ref.watch(freezeGemCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Streak Saya"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: streakCacheAsync.when(
        data: (cached) {
          final currentStreak = cached['current'] ?? 0;
          final longestStreak = cached['longest'] ?? 0;

          return streakDetailsAsync.when(
            data: (fresh) {
              final streakData = {
                'current': fresh['current'] ?? currentStreak,
                'longest': fresh['longest'] ?? longestStreak,
              };

              return freezeGemAsync.when(
                data: (freezeGemCount) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        _buildHeaderSection(context, streakData['current'] ?? 0),
                        
                        const SizedBox(height: 32),
                        
                        // Stats Grid
                        _buildStatsGrid(
                          context,
                          currentStreak: streakData['current'] ?? 0,
                          longestStreak: streakData['longest'] ?? 0,
                          freezeGems: freezeGemCount,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Info Section
                        _buildInfoSection(context),
                      ],
                    ),
                  );
                },
                loading: () => _buildLoadingState(currentStreak, longestStreak),
                error: (err, _) => _buildErrorState("Error loading freeze gems: $err"),
              );
            },
            loading: () => _buildLoadingState(currentStreak, longestStreak),
            error: (err, _) => _buildErrorState("Error loading streak: $err"),
          );
        },
        loading: () => _buildLoadingState(0, 0),
        error: (err, _) => _buildErrorState("Error loading cache: $err"),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, int currentStreak) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Animated Fire Icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (value * 0.4),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getStreakColor(context, currentStreak).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStreakIcon(currentStreak),
                      size: 40,
                      color: _getStreakColor(context, currentStreak),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Streak Count
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: currentStreak),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) {
              return Text(
                "$value",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
          
          const SizedBox(height: 8),
          
          Text(
            "Hari Berturut-turut",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Motivational Text
          Text(
            _getMotivationalText(currentStreak),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context, {
    required int currentStreak,
    required int longestStreak,
    required int freezeGems,
  }) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard(
          context,
          title: "Rekor Terpanjang",
          value: longestStreak,
          subtitle: "Hari",
          icon: Icons.emoji_events_rounded,
          iconColor: Colors.amber.shade600,
        ),
        _buildStatCard(
          context,
          title: "Permata Beku",
          value: freezeGems,
          subtitle: "Diamond",
          icon: Icons.diamond_rounded,
          iconColor: Colors.blue.shade500,
        ),
        _buildStatCard(
          context,
          title: "Level Streak",
          value: _getStreakLevel(currentStreak),
          subtitle: _getStreakLevelName(currentStreak),
          icon: Icons.auto_awesome_rounded,
          iconColor: Colors.purple.shade500,
        ),
        _buildStatCard(
          context,
          title: "Pencapaian",
          value: _getAchievementCount(currentStreak),
          subtitle: "Unlocked",
          icon: Icons.workspace_premium_rounded,
          iconColor: Colors.green.shade600,
        ),
      ],
    );
  }

 Widget _buildStatCard(
  BuildContext context, {
  required String title,
  required int value,
  required String subtitle,
  required IconData icon,
  required Color iconColor,
}) {
  return Container(
    constraints: const BoxConstraints(
      minHeight: 120, // TAMBAHKAN CONSTRAINTS
    ),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(8), // DIKURANGI
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6), // DIKURANGI
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 26, color: iconColor), // DIKURANGI
          ),
          const SizedBox(height: 8), // DIKURANGI
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(milliseconds: 800),
            builder: (context, val, child) {
              return Text(
                "$val",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16, // DIKURANGI
                ),
              );
            },
          ),
          const SizedBox(height: 2), // DIKURANGI
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
              fontSize: 10, // DIKURANGI
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 0), // DIHAPUS
          Text(
            subtitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              fontSize: 8, // DIKURANGI
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Tips Streak",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Baca setiap hari untuk mempertahankan streak! Dapatkan 1 Permata Beku 💎 setiap mencapai streak 7 hari. "
            "Gunakan permata untuk melindungi streak jika kamu melewatkan membaca sehari.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(int current, int longest) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Memuat data streak..."),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "Terjadi kesalahan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Color _getStreakColor(BuildContext context, int streak) {
    if (streak == 0) return Colors.grey.shade400;
    if (streak <= 3) return Colors.orange.shade400;
    if (streak <= 7) return Colors.orange.shade600;
    if (streak <= 14) return Colors.red.shade500;
    return Colors.red.shade700;
  }

  IconData _getStreakIcon(int streak) {
    if (streak == 0) return Icons.emoji_events_outlined;
    if (streak <= 3) return Icons.local_fire_department_outlined;
    if (streak <= 7) return Icons.local_fire_department;
    return Icons.whatshot_rounded;
  }

  String _getMotivationalText(int streak) {
    if (streak == 0) return "Mulai streak membaca pertamamu hari ini!";
    if (streak == 1) return "Langkah awal yang bagus! Teruskan!";
    if (streak <= 3) return "Kamu sedang dalam perjalanan! Pertahankan!";
    if (streak <= 7) return "Luar biasa! Streak mingguan hampir tercapai!";
    if (streak <= 14) return "Fantastis! Kamu konsisten membaca!";
    return "Legendaris! Kamu adalah pembaca sejati! 🔥";
  }

  int _getStreakLevel(int streak) {
    if (streak == 0) return 0;
    if (streak <= 3) return 1;
    if (streak <= 7) return 2;
    if (streak <= 14) return 3;
    if (streak <= 30) return 4;
    return 5;
  }

  String _getStreakLevelName(int streak) {
    if (streak == 0) return "Pemula";
    if (streak <= 3) return "Pembaca";
    if (streak <= 7) return "Rajin";
    if (streak <= 14) return "Konsisten";
    if (streak <= 30) return "Expert";
    return "Legenda";
  }

  int _getAchievementCount(int streak) {
    int count = 0;
    if (streak >= 1) count++;
    if (streak >= 3) count++;
    if (streak >= 7) count++;
    if (streak >= 14) count++;
    if (streak >= 30) count++;
    return count;
  }
}