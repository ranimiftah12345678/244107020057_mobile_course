import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_todo/providers/stats_provider.dart';

// Notifier pengujian melewati jeda dan memastikan hasil sukses.
class _SuccessfulStatsNotifier extends StatsNotifier {
  @override
  Future<void> waitForResponse() async {}

  @override
  bool get shouldFail => false;
}

// Notifier pengujian melewati jeda dan memastikan jalur error.
class _FailingStatsNotifier extends StatsNotifier {
  @override
  Future<void> waitForResponse() async {}

  @override
  bool get shouldFail => true;
}

void main() {
  // Pastikan notifier menghasilkan tiga statistik ketika permintaan berhasil.
  test('mengembalikan tiga statistik pada kondisi sukses', () async {
    final container = ProviderContainer(
      overrides: [
        statsProvider.overrideWith(_SuccessfulStatsNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    final stats = await container.read(statsProvider.future);

    expect(stats, hasLength(3));
    expect(stats.first, 'Total pengguna: 1.250');
  });

  // Pastikan kegagalan simulasi diteruskan sebagai error, bukan data kosong.
  test('meneruskan error saat pengambilan statistik gagal', () async {
    final container = ProviderContainer(
      overrides: [
        statsProvider.overrideWith(_FailingStatsNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(statsProvider.future),
      throwsA(isA<StateError>()),
    );
  });
}
