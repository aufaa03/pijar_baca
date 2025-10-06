import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pijar_baca/features/stats/presentation/stats_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalBooksValue = ref.watch(totalBooksFinishedProvider);
    final readingDaysValue = ref.watch(readingDaysProvider);
    final readingDaysCountValue = ref.watch(readingDaysCountProvider);
    final averageBooksValue = ref.watch(averageBooksPerMonthProvider);
    final targetValue = ref.watch(readingTargetProvider);
    final currentYear = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Membaca'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(context, currentYear, targetValue),
            const SizedBox(height: 24),
            _buildStatsGrid(
              context,
              ref,
              totalBooksValue,
              readingDaysCountValue,
              averageBooksValue,
              targetValue,
            ),
            const SizedBox(height: 32),
            _buildCalendarSection(context, readingDaysValue, currentYear),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    int currentYear,
    int targetValue,
  ) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Tahun $currentYear',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.flag, size: 14, color: Colors.green.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Target: $targetValue',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Progress Membaca',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Lacak perkembangan membaca Anda sepanjang tahun',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<int> totalBooksValue,
    AsyncValue<int> readingDaysCountValue,
    AsyncValue<double> averageBooksValue,
    int targetValue,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Ringkasan',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            InkWell(
              onTap: () => _showEditTargetDialog(context, ref, targetValue),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Edit Target',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10, // Reduced from 12
          childAspectRatio: 1.4, // Increased from 1.3 untuk lebih tinggi
          children: [
            _buildStatCard(
              context,
              title: 'Buku Selesai',
              value: totalBooksValue.value ?? 0,
              subtitle: 'Tahun ini',
              icon: Icons.library_books_rounded,
              iconColor: Theme.of(context).colorScheme.primary,
              isLoading: totalBooksValue.isLoading,
              progress: (totalBooksValue.value ?? 0) / (targetValue),
            ),
            _buildStatCard(
              context,
              title: 'Hari Membaca',
              value: readingDaysCountValue.value ?? 0,
              subtitle: 'Total',
              icon: Icons.calendar_today_rounded,
              iconColor: Colors.green.shade600,
              isLoading: readingDaysCountValue.isLoading,
            ),
            _buildStatCard(
              context,
              title: 'Rata-rata',
              value: averageBooksValue.value?.round() ?? 0,
              subtitle: 'Buku/bulan',
              icon: Icons.trending_up_rounded,
              iconColor: Colors.orange.shade600,
              isLoading: averageBooksValue.isLoading,
            ),
            _buildProgressCard(
              context,
              current: totalBooksValue.value ?? 0,
              target: targetValue,
              isLoading: totalBooksValue.isLoading,
            ),
          ],
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
    required bool isLoading,
    double progress = 0.0,
  }) {
    return Container(
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
        padding: const EdgeInsets.all(12), // Reduced from 16
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5), // Reduced from 6
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: iconColor,
                  ), // Reduced from 18
                ),
                const Spacer(),
                if (isLoading)
                  const SizedBox(
                    width: 12, // Reduced from 14
                    height: 12, // Reduced from 14
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
              ],
            ),
            const SizedBox(height: 8), // Reduced from 10
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: value),
              duration: const Duration(milliseconds: 1000),
              builder: (context, animatedValue, child) {
                return Text(
                  '$animatedValue',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18, // Reduced from 20
                  ),
                );
              },
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
                fontSize: 11, // Reduced from 12
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                fontSize: 9, // Reduced from 10
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (progress > 0 && title == 'Buku Selesai')
              Column(
                children: [
                  const SizedBox(height: 6), // Reduced from 8
                  LinearProgressIndicator(
                    value: progress > 1 ? 1.0 : progress,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.1),
                    color: iconColor,
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 3, // Reduced from 4
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context, {
    required int current,
    required int target,
    required bool isLoading,
  }) {
    final progress = target > 0 ? current / target : 0.0;
    final percentage = (progress * 100).round();

    return Container(
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
        padding: const EdgeInsets.all(12), // Reduced from 16
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5), // Reduced from 6
                  decoration: BoxDecoration(
                    color: Colors.purple.shade600.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.flag_rounded,
                    size: 16,
                    color: Colors.purple.shade600,
                  ), // Reduced from 18
                ),
                const Spacer(),
                if (isLoading)
                  const SizedBox(
                    width: 12, // Reduced from 14
                    height: 12, // Reduced from 14
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
              ],
            ),
            const SizedBox(height: 8), // Reduced from 10
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: percentage),
              duration: const Duration(milliseconds: 1000),
              builder: (context, animatedValue, child) {
                return Text(
                  '$animatedValue%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _getProgressColor(context, progress),
                    fontSize: 18, // Reduced from 20
                  ),
                );
              },
            ),
            const SizedBox(height: 2),
            Text(
              'Progress Target',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
                fontSize: 11, // Reduced from 12
              ),
            ),
            const SizedBox(height: 1),
            Text(
              '$current/$target buku',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                fontSize: 9, // Reduced from 10
              ),
            ),
            const SizedBox(height: 6), // Reduced from 8
            LinearProgressIndicator(
              value: progress > 1 ? 1.0 : progress,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.1),
              color: _getProgressColor(context, progress),
              borderRadius: BorderRadius.circular(4),
              minHeight: 4, // Reduced from 6
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTargetDialog(
    BuildContext context,
    WidgetRef ref,
    int currentTarget,
  ) {
    final TextEditingController controller = TextEditingController(
      text: currentTarget.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.flag_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'Edit Target Membaca',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Atur target jumlah buku yang ingin dibaca dalam setahun',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Target Buku/Tahun',
                hintText: 'Masukkan jumlah buku',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.library_books_outlined),
                suffixText: 'buku',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final newTarget = int.tryParse(controller.text);
              if (newTarget != null && newTarget > 0) {
                // Update target menggunakan StateNotifier
                ref
                    .read(readingTargetProvider.notifier)
                    .updateTarget(newTarget);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Target berhasil diubah menjadi $newTarget buku/tahun',
                    ),
                    backgroundColor: Colors.green.shade500,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Masukkan jumlah buku yang valid (minimal 1)',
                    ),
                    backgroundColor: Colors.red.shade500,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(BuildContext context, double progress) {
    if (progress < 0.3) return Colors.red.shade600;
    if (progress < 0.7) return Colors.orange.shade600;
    if (progress < 1.0) return Colors.blue.shade600;
    return Colors.green.shade600;
  }

  // ... _buildCalendarSection (tetap sama seperti sebelumnya)
  Widget _buildCalendarSection(
    BuildContext context,
    AsyncValue<Set<DateTime>> readingDaysValue,
    int currentYear,
  ) {
    final defaultTextStyle =
        Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    final titleTextStyle =
        Theme.of(context).textTheme.titleMedium ?? const TextStyle();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Kalender Membaca',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${readingDaysValue.value?.length ?? 0} hari',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Hari-hari di mana Anda membaca',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: readingDaysValue.when(
              data: (readingDays) {
                return TableCalendar(
                  focusedDay: DateTime.now(),
                  firstDay: DateTime(currentYear, 1, 1),
                  lastDay: DateTime(currentYear, 12, 31),
                  calendarFormat: CalendarFormat.month,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: titleTextStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left_rounded,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right_rounded,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    headerPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: defaultTextStyle.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    weekendStyle: defaultTextStyle.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.red.shade400,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    weekendTextStyle: TextStyle(color: Colors.red.shade400),
                    defaultTextStyle: defaultTextStyle,
                    outsideTextStyle: defaultTextStyle.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      final normalizedDay = DateTime(
                        day.year,
                        day.month,
                        day.day,
                      );
                      if (readingDays.contains(normalizedDay)) {
                        return Positioned(
                          bottom: 1,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                );
              },
              loading: () => Container(
                height: 400,
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (e, s) => Container(
                height: 200,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat kalender',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
