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
        title: const Text("🔥 Detail Streak"),
        centerTitle: true,
        backgroundColor: Colors.orange.shade400,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: streakCacheAsync.when(
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
                    return ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _streakCard(
                          title: "Streak Saat Ini",
                          value: streakData['current'] ?? 0,
                          subtitle: "Hari Berturut-turut",
                          icon: Icons.local_fire_department,
                          iconColor: Colors.orange,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _streakCard(
                                title: "Rekor Terpanjang",
                                value: streakData['longest'] ?? 0,
                                subtitle: "Hari",
                                icon: Icons.star,
                                iconColor: Colors.amber,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _streakCard(
                                title: "Permata Beku",
                                value: freezeGemCount,
                                subtitle: "💎",
                                icon: Icons.ac_unit,
                                iconColor: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            "✨ Dapatkan 1 Permata Beku 💎 setiap mencapai streak 7 hari. "
                            "Gunakan untuk melindungi streak jika melewatkan membaca sehari!",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text("Error freeze gems: $err"),
                );
              },
              loading: () => _loadingState(currentStreak, longestStreak),
              error: (err, _) => Text("Error streak: $err"),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text("Error cache: $err"),
        ),
      ),
    );
  }

  Widget _streakCard({
    required String title,
    required int value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            // 🔥 Animasi angka dari 0 → value
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: value),
              duration: const Duration(seconds: 1),
              builder: (context, val, _) {
                return Text(
                  "$val",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),

            const SizedBox(height: 6),
            Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _loadingState(int current, int longest) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("🔥 $current Hari (cached)"),
          Text("🏆 Rekor: $longest"),
          const SizedBox(height: 12),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
