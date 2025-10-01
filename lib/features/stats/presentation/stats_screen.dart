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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dasbor Statistik'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // === Kartu Statistik Utama ===
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    value: totalBooksValue.when(
                      data: (total) => total.toString(),
                      loading: () => '...',
                      error: (e, s) => '!',
                    ),
                    label: 'Buku Selesai Tahun Ini',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // === Kalender Membaca ===
          Text(
            'Kalender Membaca',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: readingDaysValue.when(
                data: (readingDays) {
                  return TableCalendar(
                    focusedDay: DateTime.now(),
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    calendarFormat: CalendarFormat.month,
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekendStyle: TextStyle(color: Colors.redAccent),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        final normalizedDay = DateTime(day.year, day.month, day.day);
                        if (readingDays.contains(normalizedDay)) {
                          return Positioned(
                            bottom: 2,
                            child: Container(
                              width: 8,
                              height: 8,
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
                loading: () => const Center(
                  heightFactor: 5,
                  child: CircularProgressIndicator(),
                ),
                error: (e, s) => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('Gagal memuat data kalender'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
