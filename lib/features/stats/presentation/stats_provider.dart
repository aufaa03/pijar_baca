import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pijar_baca/main.dart';

part 'stats_provider.g.dart';

@riverpod
Future<int> totalBooksFinished(TotalBooksFinishedRef ref) {
  return isarService.getTotalBooksFinishedThisYear();
}

@riverpod
Future<Set<DateTime>> readingDays(ReadingDaysRef ref) {
  return isarService.getReadingDays();
}