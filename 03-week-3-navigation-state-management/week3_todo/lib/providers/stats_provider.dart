import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notifier ini memuat tiga nilai statistik dan melempar error bila simulasi gagal.
class StatsNotifier extends AsyncNotifier<List<String>> {
  // Jeda dan peluang gagal dipisahkan agar perilaku notifier dapat diuji konsisten.
  Future<void> waitForResponse() =>
      Future<void>.delayed(const Duration(seconds: 2));

  bool get shouldFail => Random().nextDouble() < 0.3;

  @override
  Future<List<String>> build() async {
    // Simulasikan waktu tunggu jaringan sebelum menentukan hasil permintaan.
    await waitForResponse();

    // Simulasikan kegagalan pada sekitar 30% permintaan.
    if (shouldFail) {
      throw StateError('Terjadi kesalahan saat mengambil statistik.');
    }

    // Kembalikan tiga statistik ketika permintaan berhasil.
    return const [
      'Total pengguna: 1.250',
      'Pesanan hari ini: 86',
      'Pendapatan bulan ini: Rp 12.500.000',
    ];
  }
}

// Provider ini menjadi satu-satunya sumber state asinkron untuk halaman statistik.
final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<String>>(StatsNotifier.new);
